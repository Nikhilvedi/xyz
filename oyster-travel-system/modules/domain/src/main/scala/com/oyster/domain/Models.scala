package com.oyster.domain

/**
 * Station - Represents a transport station in the system
 * Immutable entity following Domain-Driven Design principles
 * 
 * @param id Unique identifier for the station
 * @param name Human-readable station name
 * @param zones The zones this station belongs to (some stations span multiple zones)
 */
final case class Station(
  id: StationId,
  name: String,
  zones: Set[Zone]
) {
  // Validation in the companion object ensures we never have invalid Station instances
  require(name.nonEmpty, "Station name cannot be empty")
  require(zones.nonEmpty, "Station must belong to at least one zone")
  
  /**
   * Get the lowest zone number for this station
   * Used for fare calculation - passengers pay based on the most favorable zone
   */
  def minZone: Zone = zones.minBy(_.number)
  
  /**
   * Check if this station is in a specific zone
   */
  def isInZone(zone: Zone): Boolean = zones.contains(zone)
  
  override def toString: String = s"$name (${zones.map(_.toString).mkString(", ")})"
}

object Station {
  /**
   * Smart constructor with validation
   * Returns Either for error handling without exceptions
   */
  def create(
    id: StationId,
    name: String,
    zones: Set[Zone]
  ): Either[String, Station] = {
    if (name.trim.isEmpty) Left("Station name cannot be empty")
    else if (zones.isEmpty) Left("Station must belong to at least one zone")
    else Right(Station(id, name.trim, zones))
  }
  
  // Pre-defined stations for demo purposes
  // In a real system, these would be loaded from a database
  val KingsCross: Station = Station(
    StationId("kings-cross"),
    "King's Cross St. Pancras",
    Set(Zone.Zone1)
  )
  
  val Holborn: Station = Station(
    StationId("holborn"),
    "Holborn",
    Set(Zone.Zone1)
  )
  
  val EarlsCourt: Station = Station(
    StationId("earls-court"),
    "Earl's Court",
    Set(Zone.Zone1, Zone.Zone2) // Spans two zones
  )
  
  val Wimbledon: Station = Station(
    StationId("wimbledon"),
    "Wimbledon",
    Set(Zone.Zone3)
  )
  
  val Hammersmith: Station = Station(
    StationId("hammersmith"),
    "Hammersmith",
    Set(Zone.Zone2)
  )
}

/**
 * CardStatus - Represents the current state of a travel card
 * Using sealed trait for exhaustive pattern matching (algebraic data type)
 * Compiler will warn if we don't handle all cases
 */
sealed trait CardStatus

object CardStatus {
  // Card is active and can be used for travel
  case object Active extends CardStatus
  
  // Card has been reported lost or stolen
  case object Blocked extends CardStatus
  
  // Card has been permanently deactivated
  case object Cancelled extends CardStatus
  
  // Card has been ordered but not yet activated
  case object Pending extends CardStatus
}

/**
 * Card - Represents a physical or virtual travel card
 * 
 * @param id Unique card identifier
 * @param accountId The account this card belongs to
 * @param status Current status of the card
 * @param issuedAt When the card was issued
 */
final case class Card(
  id: CardId,
  accountId: AccountId,
  status: CardStatus,
  issuedAt: Timestamp
) {
  /**
   * Check if the card can be used for travel
   * Functional approach: pure function with no side effects
   */
  def isUsable: Boolean = status == CardStatus.Active
  
  /**
   * Block the card (e.g., when reported lost)
   * Returns a new Card instance - immutability principle
   */
  def block(): Card = this.copy(status = CardStatus.Blocked)
  
  /**
   * Activate a pending card
   */
  def activate(): Either[String, Card] =
    status match {
      case CardStatus.Pending => Right(this.copy(status = CardStatus.Active))
      case _ => Left(s"Cannot activate card in status: $status")
    }
  
  /**
   * Cancel the card permanently
   */
  def cancel(): Card = this.copy(status = CardStatus.Cancelled)
}

object Card {
  /**
   * Create a new card for an account
   * Returns a pending card that needs to be activated
   */
  def create(accountId: AccountId): Card = Card(
    id = CardId.generate(),
    accountId = accountId,
    status = CardStatus.Pending,
    issuedAt = Timestamp.now()
  )
}

/**
 * Account - Represents a customer account
 * 
 * @param id Unique account identifier
 * @param email Customer email address
 * @param name Customer name
 * @param createdAt When the account was created
 */
final case class Account(
  id: AccountId,
  email: String,
  name: String,
  createdAt: Timestamp
) {
  require(email.contains("@"), "Invalid email address")
  require(name.nonEmpty, "Name cannot be empty")
}

object Account {
  /**
   * Smart constructor with validation
   */
  def create(
    email: String,
    name: String
  ): Either[String, Account] = {
    if (!email.contains("@")) Left("Invalid email address")
    else if (name.trim.isEmpty) Left("Name cannot be empty")
    else Right(Account(
      id = AccountId.generate(),
      email = email.trim,
      name = name.trim,
      createdAt = Timestamp.now()
    ))
  }
}

/**
 * Wallet - Represents the monetary balance associated with a card
 * 
 * @param cardId The card this wallet belongs to
 * @param balance Current balance
 * @param lastUpdated When the balance was last modified
 */
final case class Wallet(
  cardId: CardId,
  balance: Money,
  lastUpdated: Timestamp
) {
  /**
   * Add money to the wallet
   * Pure function - returns new Wallet instance
   */
  def topUp(amount: Money): Wallet = Wallet(
    cardId = cardId,
    balance = balance + amount,
    lastUpdated = Timestamp.now()
  )
  
  /**
   * Deduct money from the wallet
   * Returns Either for safe error handling
   */
  def deduct(amount: Money): Either[String, Wallet] = {
    if (balance >= amount) {
      Right(Wallet(
        cardId = cardId,
        balance = balance - amount,
        lastUpdated = Timestamp.now()
      ))
    } else {
      Left(s"Insufficient balance. Required: $amount, Available: $balance")
    }
  }
  
  /**
   * Check if wallet has sufficient balance
   */
  def hasSufficientBalance(amount: Money): Boolean = balance >= amount
}

object Wallet {
  /**
   * Create a new wallet for a card with zero balance
   */
  def create(cardId: CardId): Wallet = Wallet(
    cardId = cardId,
    balance = Money.Zero,
    lastUpdated = Timestamp.now()
  )
}
