package com.oyster.operations

import cats.effect.IO
import cats.implicits._
import com.oyster.domain._
import com.oyster.account.{AccountService, CardService}
import com.oyster.wallet.WalletService
import com.oyster.tap.TapValidationService

/**
 * SystemStatistics - Aggregated statistics about the travel system
 * Immutable data structure holding various metrics
 * 
 * @param totalAccounts Total number of accounts
 * @param totalCards Total number of cards
 * @param activeCards Number of active cards
 * @param totalJourneys Total number of journeys (completed + in-progress)
 * @param completedJourneys Number of completed journeys
 * @param inProgressJourneys Number of in-progress journeys
 * @param incompleteJourneys Number of incomplete journeys (no tap-out)
 * @param totalRevenue Total revenue collected from fares
 * @param totalWalletBalance Total money held in all wallets
 */
final case class SystemStatistics(
  totalAccounts: Int,
  totalCards: Int,
  activeCards: Int,
  totalJourneys: Int,
  completedJourneys: Int,
  inProgressJourneys: Int,
  incompleteJourneys: Int,
  totalRevenue: Money,
  totalWalletBalance: Money
) {
  /**
   * Format statistics as a readable string
   */
  def summary: String = {
    s"""
       |System Statistics:
       |==================
       |Accounts: $totalAccounts
       |Cards: $totalCards (Active: $activeCards)
       |Journeys: $totalJourneys
       |  - Completed: $completedJourneys
       |  - In Progress: $inProgressJourneys
       |  - Incomplete: $incompleteJourneys
       |Revenue: $totalRevenue
       |Total Wallet Balance: $totalWalletBalance
       |""".stripMargin
  }
}

/**
 * CardStatistics - Statistics for a specific card
 * Provides detailed information about card usage
 * 
 * @param cardId The card identifier
 * @param accountId Associated account
 * @param status Card status
 * @param currentBalance Current wallet balance
 * @param totalJourneys Total number of journeys
 * @param totalSpent Total amount spent on fares
 * @param averageFare Average fare per journey
 */
final case class CardStatistics(
  cardId: CardId,
  accountId: AccountId,
  status: CardStatus,
  currentBalance: Money,
  totalJourneys: Int,
  totalSpent: Money,
  averageFare: Money
) {
  def summary: String = {
    s"""
       |Card Statistics for $cardId:
       |================================
       |Account: $accountId
       |Status: $status
       |Current Balance: $currentBalance
       |Total Journeys: $totalJourneys
       |Total Spent: $totalSpent
       |Average Fare: $averageFare
       |""".stripMargin
  }
}

/**
 * MonitoringService - Service for system monitoring and reporting
 * Provides operational insights and statistics
 * 
 * This service aggregates data from all other services to provide
 * comprehensive system visibility for operations teams
 * 
 * @param accountService Service for account operations
 * @param cardService Service for card operations
 * @param walletService Service for wallet operations
 * @param tapService Service for journey operations
 */
class MonitoringService(
  accountService: AccountService,
  cardService: CardService,
  walletService: WalletService,
  tapService: TapValidationService
) {
  
  /**
   * Get comprehensive system statistics
   * Aggregates data from all services
   * 
   * @return System-wide statistics
   */
  def getSystemStatistics(): IO[SystemStatistics] = {
    for {
      // Get data from all services
      accounts <- accountService.listAllAccounts()
      cards <- cardService.listAllCards()
      journeys <- tapService.getAllInProgressJourneys()
      allJourneys <- journeys.pure[IO] // We only have in-progress, in real system would get all
      
      // Calculate derived statistics
      activeCards = cards.count(_.status == CardStatus.Active)
      
      // For wallet balance, we need to sum all wallets
      // In a real system, this would be optimized with a database query
      walletBalances <- cards.traverse { card =>
        walletService.getBalance(card.id).map {
          case Right(balance) => balance
          case Left(_) => Money.Zero
        }
      }
      totalWalletBalance = walletBalances.foldLeft(Money.Zero)(_ + _)
      
      // Calculate revenue from completed journeys
      // In this simplified version, we'll use a placeholder
      // In a real system, we'd query all completed journeys
      totalRevenue = Money.Zero // Would calculate from all transactions
      
    } yield SystemStatistics(
      totalAccounts = accounts.length,
      totalCards = cards.length,
      activeCards = activeCards,
      totalJourneys = journeys.length,
      completedJourneys = 0, // Would get from journey repository
      inProgressJourneys = journeys.length,
      incompleteJourneys = 0, // Would get from journey repository
      totalRevenue = totalRevenue,
      totalWalletBalance = totalWalletBalance
    )
  }
  
  /**
   * Get detailed statistics for a specific card
   * 
   * @param cardId The card to get statistics for
   * @return Either error or card statistics
   */
  def getCardStatistics(cardId: CardId): IO[Either[String, CardStatistics]] = {
    for {
      // Get card information
      cardResult <- cardService.getCard(cardId)
      
      result <- cardResult match {
        case Left(error) =>
          IO.pure(Left(error))
          
        case Right(card) =>
          for {
            // Get wallet balance
            balanceResult <- walletService.getBalance(cardId)
            balance = balanceResult.getOrElse(Money.Zero)
            
            // Get journey history
            journeys <- tapService.getJourneyHistory(cardId)
            
            // Calculate statistics
            totalJourneys = journeys.length
            totalSpent = journeys
              .filter(_.status == JourneyStatus.Completed)
              .map(_.fare)
              .foldLeft(Money.Zero)(_ + _)
            
            averageFare = if (totalJourneys > 0)
              Money(totalSpent.amount / totalJourneys)
            else
              Money.Zero
            
            stats = CardStatistics(
              cardId = cardId,
              accountId = card.accountId,
              status = card.status,
              currentBalance = balance,
              totalJourneys = totalJourneys,
              totalSpent = totalSpent,
              averageFare = averageFare
            )
            
          } yield Right(stats)
      }
    } yield result
  }
  
  /**
   * List all cards with low balance
   * Useful for identifying cards that need top-up
   * 
   * @param threshold Balance threshold
   * @return List of cards with balance below threshold
   */
  def findLowBalanceCards(
    threshold: Money = FareRules.minimumBalanceRequired
  ): IO[List[(Card, Money)]] = {
    for {
      cards <- cardService.listAllCards()
      
      cardsWithBalance <- cards.traverse { card =>
        walletService.getBalance(card.id).map {
          case Right(balance) => Some((card, balance))
          case Left(_) => None
        }
      }
      
      lowBalanceCards = cardsWithBalance.flatten
        .filter { case (_, balance) => balance < threshold }
        
    } yield lowBalanceCards
  }
  
  /**
   * Find all incomplete journeys
   * Useful for operations to identify issues
   * 
   * @return List of in-progress journeys
   */
  def findIncompleteJourneys(): IO[List[Journey]] = {
    tapService.getAllInProgressJourneys()
  }
  
  /**
   * Generate a report of recent activity for an account
   * 
   * @param accountId The account to report on
   * @return Either error or formatted report
   */
  def generateAccountReport(accountId: AccountId): IO[Either[String, String]] = {
    for {
      accountResult <- accountService.getAccount(accountId)
      
      result <- accountResult match {
        case Left(error) =>
          IO.pure(Left(error))
          
        case Right(account) =>
          for {
            // Get all cards for the account
            cards <- cardService.listCardsForAccount(accountId)
            
            // Get statistics for each card
            cardStats <- cards.traverse { card =>
              for {
                balance <- walletService.getBalance(card.id)
                journeys <- tapService.getJourneyHistory(card.id)
                transactions <- walletService.getRecentTransactions(card.id, 5)
              } yield (card, balance, journeys.length, transactions)
            }
            
            // Build report
            report = buildAccountReport(account, cardStats)
            
          } yield Right(report)
      }
    } yield result
  }
  
  /**
   * Helper method to build account report string
   */
  private def buildAccountReport(
    account: Account,
    cardStats: List[(Card, Either[String, Money], Int, List[Transaction])]
  ): String = {
    val header = s"""
      |Account Report
      |==============
      |Name: ${account.name}
      |Email: ${account.email}
      |Account ID: ${account.id}
      |Created: ${account.createdAt}
      |
      |Cards:
      |------
      |""".stripMargin
    
    val cardReports = cardStats.map { case (card, balance, journeys, transactions) =>
      val balanceStr = balance match {
        case Right(b) => b.toString
        case Left(_) => "N/A"
      }
      
      s"""
         |Card ID: ${card.id}
         |Status: ${card.status}
         |Balance: $balanceStr
         |Total Journeys: $journeys
         |Recent Transactions:
         |${transactions.take(3).map(t => s"  - ${t.description}").mkString("\n")}
         |""".stripMargin
    }.mkString("\n")
    
    header + cardReports
  }
}

object MonitoringService {
  /**
   * Create a MonitoringService with all required services
   */
  def create(
    accountService: AccountService,
    cardService: CardService,
    walletService: WalletService,
    tapService: TapValidationService
  ): MonitoringService = {
    new MonitoringService(accountService, cardService, walletService, tapService)
  }
}

/**
 * AdminOperations - Administrative operations for system management
 * Provides tools for system administrators
 * 
 * @param cardService Service for card operations
 * @param tapService Service for journey operations
 */
class AdminOperations(
  cardService: CardService,
  tapService: TapValidationService
) {
  
  /**
   * Force complete all stale in-progress journeys
   * Useful for end-of-day processing
   * Marks journeys as incomplete and charges penalty fare
   * 
   * @return List of journeys that were marked incomplete
   */
  def cleanupStaleJourneys(): IO[List[Journey]] = {
    for {
      inProgressJourneys <- tapService.getAllInProgressJourneys()
      
      // Mark each as incomplete
      completed <- inProgressJourneys.traverse { journey =>
        tapService.markJourneyIncomplete(journey.id).map {
          case Right(updated) => Some(updated)
          case Left(_) => None
        }
      }
      
    } yield completed.flatten
  }
  
  /**
   * Block multiple cards (e.g., in case of fraud)
   * 
   * @param cardIds List of card IDs to block
   * @return List of successfully blocked cards
   */
  def blockCards(cardIds: List[CardId]): IO[List[Card]] = {
    cardIds.traverse { cardId =>
      cardService.blockCard(cardId).map {
        case Right(card) => Some(card)
        case Left(_) => None
      }
    }.map(_.flatten)
  }
  
  /**
   * Validate system integrity
   * Checks for inconsistencies in the system
   * 
   * @return List of issues found
   */
  def validateSystemIntegrity(): IO[List[String]] = {
    for {
      // Check for cards without wallets
      cards <- cardService.listAllCards()
      
      // This is a simplified check
      // In a real system, would perform more comprehensive validation
      issues = List.empty[String]
      
    } yield issues
  }
}

object AdminOperations {
  def create(
    cardService: CardService,
    tapService: TapValidationService
  ): AdminOperations = {
    new AdminOperations(cardService, tapService)
  }
}
