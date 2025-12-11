package com.oyster.account

import cats.effect.IO
import cats.effect.Ref
import cats.implicits._
import com.oyster.domain._

/**
 * CardRepository - Repository for Card persistence
 * Similar to AccountRepository, provides functional interface for card storage
 */
trait CardRepository {
  def save(card: Card): IO[Unit]
  def findById(id: CardId): IO[Option[Card]]
  def findByAccountId(accountId: AccountId): IO[List[Card]]
  def listAll(): IO[List[Card]]
}

/**
 * InMemoryCardRepository - In-memory implementation
 * Uses Ref for thread-safe mutable state
 */
class InMemoryCardRepository private (
  state: Ref[IO, Map[CardId, Card]]
) extends CardRepository {
  
  override def save(card: Card): IO[Unit] =
    state.update(cards => cards + (card.id -> card))
  
  override def findById(id: CardId): IO[Option[Card]] =
    state.get.map(_.get(id))
  
  override def findByAccountId(accountId: AccountId): IO[List[Card]] =
    state.get.map(_.values.filter(_.accountId == accountId).toList)
  
  override def listAll(): IO[List[Card]] =
    state.get.map(_.values.toList)
}

object InMemoryCardRepository {
  def empty: IO[CardRepository] =
    Ref.of[IO, Map[CardId, Card]](Map.empty)
      .map(ref => new InMemoryCardRepository(ref))
  
  def withCards(cards: List[Card]): IO[CardRepository] =
    Ref.of[IO, Map[CardId, Card]](
      cards.map(c => c.id -> c).toMap
    ).map(ref => new InMemoryCardRepository(ref))
}

/**
 * CardService - Business logic for card management
 * Handles card ordering, activation, blocking, and cancellation
 * 
 * @param cardRepository Repository for card persistence
 * @param accountRepository Repository to verify account existence
 */
class CardService(
  cardRepository: CardRepository,
  accountRepository: AccountRepository
) {
  
  /**
   * Order a new card for an account
   * Creates a card in Pending status that needs activation
   * 
   * @param accountId The account to create the card for
   * @return Either error or newly created card
   */
  def orderCard(accountId: AccountId): IO[Either[String, Card]] = {
    // First verify the account exists
    accountRepository.findById(accountId).flatMap {
      case None =>
        IO.pure(Left(s"Account not found: $accountId"))
        
      case Some(_) =>
        // Account exists, create and save the card
        val card = Card.create(accountId)
        cardRepository.save(card).map(_ => Right(card))
    }
  }
  
  /**
   * Activate a pending card
   * 
   * @param cardId The card to activate
   * @return Either error or activated card
   */
  def activateCard(cardId: CardId): IO[Either[String, Card]] = {
    cardRepository.findById(cardId).flatMap {
      case None =>
        IO.pure(Left(s"Card not found: $cardId"))
        
      case Some(card) =>
        // Try to activate the card
        card.activate() match {
          case Left(error) =>
            IO.pure(Left(error))
          case Right(activatedCard) =>
            cardRepository.save(activatedCard).map(_ => Right(activatedCard))
        }
    }
  }
  
  /**
   * Block a card (e.g., when reported lost or stolen)
   * Blocked cards cannot be used for travel
   * 
   * @param cardId The card to block
   * @return Either error or blocked card
   */
  def blockCard(cardId: CardId): IO[Either[String, Card]] = {
    cardRepository.findById(cardId).flatMap {
      case None =>
        IO.pure(Left(s"Card not found: $cardId"))
        
      case Some(card) =>
        val blockedCard = card.block()
        cardRepository.save(blockedCard).map(_ => Right(blockedCard))
    }
  }
  
  /**
   * Cancel a card permanently
   * Cancelled cards cannot be reactivated
   * 
   * @param cardId The card to cancel
   * @return Either error or cancelled card
   */
  def cancelCard(cardId: CardId): IO[Either[String, Card]] = {
    cardRepository.findById(cardId).flatMap {
      case None =>
        IO.pure(Left(s"Card not found: $cardId"))
        
      case Some(card) =>
        val cancelledCard = card.cancel()
        cardRepository.save(cancelledCard).map(_ => Right(cancelledCard))
    }
  }
  
  /**
   * Get a card by ID
   * 
   * @param cardId The card identifier
   * @return Either error or found card
   */
  def getCard(cardId: CardId): IO[Either[String, Card]] = {
    cardRepository.findById(cardId).map {
      case Some(card) => Right(card)
      case None => Left(s"Card not found: $cardId")
    }
  }
  
  /**
   * List all cards for an account
   * 
   * @param accountId The account identifier
   * @return List of cards belonging to the account
   */
  def listCardsForAccount(accountId: AccountId): IO[List[Card]] = {
    cardRepository.findByAccountId(accountId)
  }
  
  /**
   * List all cards in the system
   * Administrative function
   */
  def listAllCards(): IO[List[Card]] = {
    cardRepository.listAll()
  }
  
  /**
   * Check if a card is usable for travel
   * A card must be Active status to be used
   * 
   * @param cardId The card to check
   * @return Either error or confirmation that card is usable
   */
  def validateCardForTravel(cardId: CardId): IO[Either[String, Card]] = {
    cardRepository.findById(cardId).map {
      case None =>
        Left(s"Card not found: $cardId")
        
      case Some(card) if !card.isUsable =>
        Left(s"Card is not active. Current status: ${card.status}")
        
      case Some(card) =>
        Right(card)
    }
  }
}

object CardService {
  /**
   * Create a CardService with empty repositories
   */
  def create: IO[CardService] = {
    for {
      cardRepo <- InMemoryCardRepository.empty
      accountRepo <- InMemoryAccountRepository.empty
    } yield new CardService(cardRepo, accountRepo)
  }
  
  /**
   * Create a CardService with specific repositories
   */
  def withRepositories(
    cardRepository: CardRepository,
    accountRepository: AccountRepository
  ): CardService = {
    new CardService(cardRepository, accountRepository)
  }
}
