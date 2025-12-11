package com.oyster.wallet

import cats.effect.IO
import cats.effect.Ref
import cats.implicits._
import com.oyster.domain._

/**
 * WalletRepository - Repository for Wallet persistence
 * Manages storage and retrieval of wallet information
 */
trait WalletRepository {
  def save(wallet: Wallet): IO[Unit]
  def findByCardId(cardId: CardId): IO[Option[Wallet]]
  def listAll(): IO[List[Wallet]]
}

/**
 * InMemoryWalletRepository - In-memory implementation
 * Uses Ref for thread-safe state management
 */
class InMemoryWalletRepository private (
  state: Ref[IO, Map[CardId, Wallet]]
) extends WalletRepository {
  
  override def save(wallet: Wallet): IO[Unit] =
    state.update(wallets => wallets + (wallet.cardId -> wallet))
  
  override def findByCardId(cardId: CardId): IO[Option[Wallet]] =
    state.get.map(_.get(cardId))
  
  override def listAll(): IO[List[Wallet]] =
    state.get.map(_.values.toList)
}

object InMemoryWalletRepository {
  def empty: IO[WalletRepository] =
    Ref.of[IO, Map[CardId, Wallet]](Map.empty)
      .map(ref => new InMemoryWalletRepository(ref))
  
  def withWallets(wallets: List[Wallet]): IO[WalletRepository] =
    Ref.of[IO, Map[CardId, Wallet]](
      wallets.map(w => w.cardId -> w).toMap
    ).map(ref => new InMemoryWalletRepository(ref))
}

/**
 * TransactionRepository - Repository for Transaction history
 * Stores all financial transactions for audit and history
 */
trait TransactionRepository {
  def save(transaction: Transaction): IO[Unit]
  def findByCardId(cardId: CardId): IO[List[Transaction]]
  def findById(id: TransactionId): IO[Option[Transaction]]
  def listAll(): IO[List[Transaction]]
}

/**
 * InMemoryTransactionRepository - In-memory implementation
 */
class InMemoryTransactionRepository private (
  state: Ref[IO, Map[TransactionId, Transaction]]
) extends TransactionRepository {
  
  override def save(transaction: Transaction): IO[Unit] =
    state.update(txs => txs + (transaction.id -> transaction))
  
  override def findByCardId(cardId: CardId): IO[List[Transaction]] =
    state.get.map(
      _.values
        .filter(_.cardId == cardId)
        .toList
        .sortBy(_.timestamp.value.toEpochMilli)
        .reverse // Most recent first
    )
  
  override def findById(id: TransactionId): IO[Option[Transaction]] =
    state.get.map(_.get(id))
  
  override def listAll(): IO[List[Transaction]] =
    state.get.map(_.values.toList)
}

object InMemoryTransactionRepository {
  def empty: IO[TransactionRepository] =
    Ref.of[IO, Map[TransactionId, Transaction]](Map.empty)
      .map(ref => new InMemoryTransactionRepository(ref))
  
  def withTransactions(txs: List[Transaction]): IO[TransactionRepository] =
    Ref.of[IO, Map[TransactionId, Transaction]](
      txs.map(t => t.id -> t).toMap
    ).map(ref => new InMemoryTransactionRepository(ref))
}

/**
 * WalletService - Business logic for wallet management
 * Handles top-ups, balance checks, and transaction history
 * 
 * Key responsibilities:
 * - Top up wallet with validation
 * - Deduct funds for fares
 * - Maintain transaction history
 * - Enforce balance limits
 * 
 * @param walletRepository Repository for wallet state
 * @param transactionRepository Repository for transaction history
 */
class WalletService(
  walletRepository: WalletRepository,
  transactionRepository: TransactionRepository
) {
  
  /**
   * Create a new wallet for a card
   * Starts with zero balance
   * 
   * @param cardId The card to create wallet for
   * @return Either error or created wallet
   */
  def createWallet(cardId: CardId): IO[Either[String, Wallet]] = {
    walletRepository.findByCardId(cardId).flatMap {
      case Some(_) =>
        IO.pure(Left(s"Wallet already exists for card: $cardId"))
        
      case None =>
        val wallet = Wallet.create(cardId)
        walletRepository.save(wallet).map(_ => Right(wallet))
    }
  }
  
  /**
   * Top up a wallet with specified amount
   * Validates amount and balance limits
   * Records transaction in history
   * 
   * @param cardId The card whose wallet to top up
   * @param amount Amount to add
   * @return Either error or updated wallet
   */
  def topUp(
    cardId: CardId,
    amount: Money
  ): IO[Either[String, Wallet]] = {
    // Validate top-up amount
    FareRules.validateTopUpAmount(amount) match {
      case Left(error) =>
        IO.pure(Left(error))
        
      case Right(_) =>
        // Get current wallet
        walletRepository.findByCardId(cardId).flatMap {
          case None =>
            IO.pure(Left(s"Wallet not found for card: $cardId"))
            
          case Some(wallet) =>
            // Check wallet limit
            FareRules.validateWalletLimit(wallet.balance, amount) match {
              case Left(error) =>
                IO.pure(Left(error))
                
              case Right(_) =>
                // Perform top-up
                val updatedWallet = wallet.topUp(amount)
                
                // Create transaction record
                val transaction = Transaction.topUp(
                  cardId,
                  amount,
                  updatedWallet.balance
                )
                
                // Save both wallet and transaction
                for {
                  _ <- walletRepository.save(updatedWallet)
                  _ <- transactionRepository.save(transaction)
                } yield Right(updatedWallet)
            }
        }
    }
  }
  
  /**
   * Deduct fare from wallet
   * Used by tap validation service
   * Records transaction in history
   * 
   * @param cardId The card to deduct from
   * @param amount Amount to deduct
   * @param journeyDescription Description for the transaction
   * @return Either error or updated wallet
   */
  def deductFare(
    cardId: CardId,
    amount: Money,
    journeyDescription: String
  ): IO[Either[String, Wallet]] = {
    walletRepository.findByCardId(cardId).flatMap {
      case None =>
        IO.pure(Left(s"Wallet not found for card: $cardId"))
        
      case Some(wallet) =>
        // Try to deduct
        wallet.deduct(amount) match {
          case Left(error) =>
            IO.pure(Left(error))
            
          case Right(updatedWallet) =>
            // Create transaction record
            val transaction = Transaction.fareDeduction(
              cardId,
              amount,
              updatedWallet.balance,
              journeyDescription
            )
            
            // Save both
            for {
              _ <- walletRepository.save(updatedWallet)
              _ <- transactionRepository.save(transaction)
            } yield Right(updatedWallet)
        }
    }
  }
  
  /**
   * Get wallet balance for a card
   * 
   * @param cardId The card to check
   * @return Either error or wallet
   */
  def getBalance(cardId: CardId): IO[Either[String, Money]] = {
    walletRepository.findByCardId(cardId).map {
      case Some(wallet) => Right(wallet.balance)
      case None => Left(s"Wallet not found for card: $cardId")
    }
  }
  
  /**
   * Get wallet for a card
   * 
   * @param cardId The card identifier
   * @return Either error or wallet
   */
  def getWallet(cardId: CardId): IO[Either[String, Wallet]] = {
    walletRepository.findByCardId(cardId).map {
      case Some(wallet) => Right(wallet)
      case None => Left(s"Wallet not found for card: $cardId")
    }
  }
  
  /**
   * Get transaction history for a card
   * Returns transactions in reverse chronological order (most recent first)
   * 
   * @param cardId The card to get history for
   * @return List of transactions
   */
  def getTransactionHistory(cardId: CardId): IO[List[Transaction]] = {
    transactionRepository.findByCardId(cardId)
  }
  
  /**
   * Get transaction history with limit
   * 
   * @param cardId The card to get history for
   * @param limit Maximum number of transactions to return
   * @return Limited list of transactions
   */
  def getRecentTransactions(
    cardId: CardId,
    limit: Int
  ): IO[List[Transaction]] = {
    transactionRepository.findByCardId(cardId).map(_.take(limit))
  }
  
  /**
   * Check if card has sufficient balance for a journey
   * 
   * @param cardId The card to check
   * @return Either error or confirmation
   */
  def validateBalanceForJourney(
    cardId: CardId
  ): IO[Either[String, Unit]] = {
    walletRepository.findByCardId(cardId).map {
      case None =>
        Left(s"Wallet not found for card: $cardId")
        
      case Some(wallet) =>
        FareRules.validateBalanceForJourney(wallet.balance)
    }
  }
}

object WalletService {
  /**
   * Create a WalletService with empty repositories
   */
  def create: IO[WalletService] = {
    for {
      walletRepo <- InMemoryWalletRepository.empty
      txRepo <- InMemoryTransactionRepository.empty
    } yield new WalletService(walletRepo, txRepo)
  }
  
  /**
   * Create a WalletService with specific repositories
   */
  def withRepositories(
    walletRepository: WalletRepository,
    transactionRepository: TransactionRepository
  ): WalletService = {
    new WalletService(walletRepository, transactionRepository)
  }
}
