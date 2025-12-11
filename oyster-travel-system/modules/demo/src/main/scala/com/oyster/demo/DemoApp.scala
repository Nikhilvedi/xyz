package com.oyster.demo

import cats.effect.{IO, IOApp, ExitCode}
import cats.implicits._
import com.oyster.domain._
import com.oyster.account.{AccountService, CardService, InMemoryAccountRepository, InMemoryCardRepository}
import com.oyster.wallet.{WalletService, InMemoryWalletRepository, InMemoryTransactionRepository}
import com.oyster.tap.{TapValidationService, InMemoryJourneyRepository}
import com.oyster.operations.{MonitoringService, AdminOperations}

/**
 * DemoApp - Demonstration application for the Oyster Travel System
 * 
 * This application demonstrates the complete functionality of the system:
 * 1. Account creation
 * 2. Card ordering and activation
 * 3. Wallet top-up
 * 4. Journey tap-in and tap-out
 * 5. System monitoring and reporting
 * 
 * Using cats-effect IOApp for:
 * - Pure functional effect management
 * - Automatic resource cleanup
 * - Proper error handling
 * - Safe concurrent execution
 */
object DemoApp extends IOApp {
  
  /**
   * Main entry point
   * IOApp.run returns IO[ExitCode] - the entire application is a pure description
   * Nothing executes until the IO is run by the runtime
   */
  override def run(args: List[String]): IO[ExitCode] = {
    // Build the application and run the demo
    application.as(ExitCode.Success).handleErrorWith { error =>
      IO.println(s"Application error: ${error.getMessage}").as(ExitCode.Error)
    }
  }
  
  /**
   * Main application logic
   * This is a pure description of effects that will be executed
   */
  def application: IO[Unit] = {
    for {
      _ <- IO.println("=" * 60)
      _ <- IO.println("Oyster Travel System - Demo Application")
      _ <- IO.println("=" * 60)
      _ <- IO.println()
      
      // Initialize all services
      _ <- IO.println("Initializing services...")
      services <- initializeServices()
      
      _ <- IO.println("Services initialized successfully!")
      _ <- IO.println()
      
      // Run demo scenarios
      _ <- demoAccountCreation(services)
      _ <- IO.println()
      
      _ <- demoCardOrdering(services)
      _ <- IO.println()
      
      _ <- demoWalletTopUp(services)
      _ <- IO.println()
      
      _ <- demoJourneys(services)
      _ <- IO.println()
      
      _ <- demoMonitoring(services)
      _ <- IO.println()
      
      _ <- IO.println("=" * 60)
      _ <- IO.println("Demo completed successfully!")
      _ <- IO.println("=" * 60)
      
    } yield ()
  }
  
  /**
   * Services container - holds all initialized services
   * Using a case class to group related services
   */
  case class Services(
    accountService: AccountService,
    cardService: CardService,
    walletService: WalletService,
    tapService: TapValidationService,
    monitoringService: MonitoringService,
    adminOps: AdminOperations
  )
  
  /**
   * Initialize all services with their dependencies
   * Demonstrates dependency injection in a functional way
   */
  def initializeServices(): IO[Services] = {
    for {
      // Create repositories
      accountRepo <- InMemoryAccountRepository.empty
      cardRepo <- InMemoryCardRepository.empty
      walletRepo <- InMemoryWalletRepository.empty
      txRepo <- InMemoryTransactionRepository.empty
      journeyRepo <- InMemoryJourneyRepository.empty
      
      // Create services
      accountService = AccountService.withRepository(accountRepo)
      cardService = CardService.withRepositories(cardRepo, accountRepo)
      walletService = WalletService.withRepositories(walletRepo, txRepo)
      tapService = TapValidationService.withRepositories(journeyRepo, walletService)
      monitoringService = MonitoringService.create(
        accountService,
        cardService,
        walletService,
        tapService
      )
      adminOps = AdminOperations.create(cardService, tapService)
      
    } yield Services(
      accountService,
      cardService,
      walletService,
      tapService,
      monitoringService,
      adminOps
    )
  }
  
  /**
   * Demo: Account Creation
   * Shows how to create customer accounts with validation
   */
  def demoAccountCreation(services: Services): IO[Unit] = {
    for {
      _ <- IO.println("--- Demo: Account Creation ---")
      
      // Create first account
      _ <- IO.println("Creating account for Alice...")
      aliceResult <- services.accountService.createAccount(
        email = "alice@example.com",
        name = "Alice Johnson"
      )
      
      alice <- aliceResult match {
        case Right(account) =>
          IO.println(s"✓ Account created: ${account.name} (${account.email})") *>
          IO.println(s"  Account ID: ${account.id}") *>
          IO.pure(account)
        case Left(error) =>
          IO.raiseError(new RuntimeException(s"Failed to create account: $error"))
      }
      
      // Create second account
      _ <- IO.println()
      _ <- IO.println("Creating account for Bob...")
      bobResult <- services.accountService.createAccount(
        email = "bob@example.com",
        name = "Bob Smith"
      )
      
      _ <- bobResult match {
        case Right(account) =>
          IO.println(s"✓ Account created: ${account.name} (${account.email})") *>
          IO.println(s"  Account ID: ${account.id}")
        case Left(error) =>
          IO.println(s"✗ Failed to create account: $error")
      }
      
      // Try to create duplicate (should fail)
      _ <- IO.println()
      _ <- IO.println("Attempting to create duplicate account...")
      dupResult <- services.accountService.createAccount(
        email = "alice@example.com",
        name = "Alice Duplicate"
      )
      
      _ <- dupResult match {
        case Right(_) =>
          IO.println("✗ Unexpected success - duplicate should fail")
        case Left(error) =>
          IO.println(s"✓ Correctly rejected duplicate: $error")
      }
      
    } yield ()
  }
  
  /**
   * Demo: Card Ordering
   * Shows card ordering, activation, and status management
   */
  def demoCardOrdering(services: Services): IO[Unit] = {
    for {
      _ <- IO.println("--- Demo: Card Ordering ---")
      
      // Get Alice's account
      accounts <- services.accountService.listAllAccounts()
      alice = accounts.head
      
      // Order a card
      _ <- IO.println(s"Ordering card for ${alice.name}...")
      cardResult <- services.cardService.orderCard(alice.id)
      
      card <- cardResult match {
        case Right(card) =>
          IO.println(s"✓ Card ordered: ${card.id}") *>
          IO.println(s"  Status: ${card.status}") *>
          IO.pure(card)
        case Left(error) =>
          IO.raiseError(new RuntimeException(s"Failed to order card: $error"))
      }
      
      // Activate the card
      _ <- IO.println()
      _ <- IO.println("Activating card...")
      activateResult <- services.cardService.activateCard(card.id)
      
      activatedCard <- activateResult match {
        case Right(card) =>
          IO.println(s"✓ Card activated") *>
          IO.println(s"  Status: ${card.status}") *>
          IO.pure(card)
        case Left(error) =>
          IO.raiseError(new RuntimeException(s"Failed to activate card: $error"))
      }
      
      // Create wallet for the card
      _ <- IO.println()
      _ <- IO.println("Creating wallet for card...")
      walletResult <- services.walletService.createWallet(activatedCard.id)
      
      _ <- walletResult match {
        case Right(wallet) =>
          IO.println(s"✓ Wallet created") *>
          IO.println(s"  Initial balance: ${wallet.balance}")
        case Left(error) =>
          IO.println(s"✗ Failed to create wallet: $error")
      }
      
    } yield ()
  }
  
  /**
   * Demo: Wallet Top-Up
   * Shows wallet top-up with validation
   */
  def demoWalletTopUp(services: Services): IO[Unit] = {
    for {
      _ <- IO.println("--- Demo: Wallet Top-Up ---")
      
      // Get the card we created
      cards <- services.cardService.listAllCards()
      card = cards.find(_.status == CardStatus.Active).get
      
      // Top up £20
      _ <- IO.println(s"Topping up £20.00 to card ${card.id}...")
      topUpResult <- services.walletService.topUp(
        card.id,
        Money.fromDouble(20.00)
      )
      
      _ <- topUpResult match {
        case Right(wallet) =>
          IO.println(s"✓ Top-up successful") *>
          IO.println(s"  New balance: ${wallet.balance}")
        case Left(error) =>
          IO.println(s"✗ Top-up failed: $error")
      }
      
      // Try to top up too much (should fail)
      _ <- IO.println()
      _ <- IO.println("Attempting to top up £1000 (exceeds maximum)...")
      invalidTopUp <- services.walletService.topUp(
        card.id,
        Money.fromDouble(1000.00)
      )
      
      _ <- invalidTopUp match {
        case Right(_) =>
          IO.println("✗ Unexpected success - should have failed")
        case Left(error) =>
          IO.println(s"✓ Correctly rejected: $error")
      }
      
      // View transaction history
      _ <- IO.println()
      _ <- IO.println("Transaction history:")
      transactions <- services.walletService.getTransactionHistory(card.id)
      _ <- transactions.traverse { tx =>
        IO.println(s"  - ${tx.description} | Balance: ${tx.balanceAfter}")
      }
      
    } yield ()
  }
  
  /**
   * Demo: Journey Management
   * Shows tap-in, tap-out, and fare calculation
   */
  def demoJourneys(services: Services): IO[Unit] = {
    for {
      _ <- IO.println("--- Demo: Journey Management ---")
      
      // Get the active card
      cards <- services.cardService.listAllCards()
      card = cards.find(_.status == CardStatus.Active).get
      
      // Journey 1: Holborn to Earl's Court
      _ <- IO.println("Journey 1: Holborn → Earl's Court")
      _ <- IO.println(s"Tapping in at ${Station.Holborn.name}...")
      
      tapInResult <- services.tapService.tapIn(card.id, Station.Holborn)
      journey1 <- tapInResult match {
        case Right(journey) =>
          IO.println(s"✓ Tapped in successfully") *>
          IO.println(s"  Maximum fare held: ${journey.fare}") *>
          IO.pure(journey)
        case Left(error) =>
          IO.raiseError(new RuntimeException(s"Tap-in failed: $error"))
      }
      
      // Check balance after tap-in
      balance1 <- services.walletService.getBalance(card.id)
      _ <- balance1 match {
        case Right(balance) =>
          IO.println(s"  Current balance: $balance")
        case Left(_) =>
          IO.unit
      }
      
      _ <- IO.println()
      _ <- IO.println(s"Tapping out at ${Station.EarlsCourt.name}...")
      
      tapOutResult <- services.tapService.tapOut(card.id, Station.EarlsCourt)
      _ <- tapOutResult match {
        case Right(journey) =>
          IO.println(s"✓ Tapped out successfully") *>
          IO.println(s"  Actual fare: ${journey.fare}") *>
          IO.println(s"  Journey: ${journey.description}")
        case Left(error) =>
          IO.println(s"✗ Tap-out failed: $error")
      }
      
      // Check balance after tap-out
      balance2 <- services.walletService.getBalance(card.id)
      _ <- balance2 match {
        case Right(balance) =>
          IO.println(s"  Current balance: $balance")
        case Left(_) =>
          IO.unit
      }
      
      // Journey 2: King's Cross to Wimbledon
      _ <- IO.println()
      _ <- IO.println("Journey 2: King's Cross → Wimbledon")
      _ <- IO.println(s"Preview fare: ${services.tapService.previewFare(Station.KingsCross, Station.Wimbledon)}")
      
      _ <- services.tapService.tapIn(card.id, Station.KingsCross)
      _ <- IO.println(s"✓ Tapped in at ${Station.KingsCross.name}")
      
      _ <- services.tapService.tapOut(card.id, Station.Wimbledon)
      _ <- IO.println(s"✓ Tapped out at ${Station.Wimbledon.name}")
      
      // Final balance
      finalBalance <- services.walletService.getBalance(card.id)
      _ <- finalBalance match {
        case Right(balance) =>
          IO.println(s"  Final balance: $balance")
        case Left(_) =>
          IO.unit
      }
      
      // Journey history
      _ <- IO.println()
      _ <- IO.println("Journey history:")
      journeys <- services.tapService.getJourneyHistory(card.id)
      _ <- journeys.traverse { j =>
        IO.println(s"  - ${j.description} | Fare: ${j.fare} | Status: ${j.status}")
      }
      
    } yield ()
  }
  
  /**
   * Demo: System Monitoring
   * Shows operational monitoring capabilities
   */
  def demoMonitoring(services: Services): IO[Unit] = {
    for {
      _ <- IO.println("--- Demo: System Monitoring ---")
      
      // Get system statistics
      _ <- IO.println("Generating system statistics...")
      stats <- services.monitoringService.getSystemStatistics()
      _ <- IO.println(stats.summary)
      
      // Get card statistics
      cards <- services.cardService.listAllCards()
      activeCard = cards.find(_.status == CardStatus.Active).get
      
      _ <- IO.println()
      _ <- IO.println("Card statistics:")
      cardStatsResult <- services.monitoringService.getCardStatistics(activeCard.id)
      
      _ <- cardStatsResult match {
        case Right(stats) =>
          IO.println(stats.summary)
        case Left(error) =>
          IO.println(s"Failed to get card statistics: $error")
      }
      
      // Check for low balance cards
      _ <- IO.println()
      _ <- IO.println("Checking for low balance cards...")
      lowBalanceCards <- services.monitoringService.findLowBalanceCards()
      
      _ <- if (lowBalanceCards.isEmpty) {
        IO.println("✓ No low balance cards found")
      } else {
        IO.println(s"Found ${lowBalanceCards.length} cards with low balance:") *>
        lowBalanceCards.traverse { case (card, balance) =>
          IO.println(s"  - Card ${card.id}: $balance")
        }.void
      }
      
    } yield ()
  }
}
