package com.oyster.domain

/**
 * TransactionType - Represents different types of financial transactions
 * Sealed trait for exhaustive pattern matching
 */
sealed trait TransactionType

object TransactionType {
  case object TopUp extends TransactionType
  case object FareDeduction extends TransactionType
  case object Refund extends TransactionType
  case object PenaltyFare extends TransactionType
}

/**
 * Transaction - Represents a financial transaction on a wallet
 * Immutable event record following Event Sourcing principles
 * 
 * @param id Unique transaction identifier
 * @param cardId The card this transaction is for
 * @param transactionType Type of transaction
 * @param amount Transaction amount
 * @param balanceAfter Balance after this transaction
 * @param timestamp When the transaction occurred
 * @param description Human-readable description
 */
final case class Transaction(
  id: TransactionId,
  cardId: CardId,
  transactionType: TransactionType,
  amount: Money,
  balanceAfter: Money,
  timestamp: Timestamp,
  description: String
)

object Transaction {
  /**
   * Create a top-up transaction
   */
  def topUp(
    cardId: CardId,
    amount: Money,
    balanceAfter: Money
  ): Transaction = Transaction(
    id = TransactionId.generate(),
    cardId = cardId,
    transactionType = TransactionType.TopUp,
    amount = amount,
    balanceAfter = balanceAfter,
    timestamp = Timestamp.now(),
    description = s"Wallet top-up: $amount"
  )
  
  /**
   * Create a fare deduction transaction
   */
  def fareDeduction(
    cardId: CardId,
    amount: Money,
    balanceAfter: Money,
    journeyDescription: String
  ): Transaction = Transaction(
    id = TransactionId.generate(),
    cardId = cardId,
    transactionType = TransactionType.FareDeduction,
    amount = amount,
    balanceAfter = balanceAfter,
    timestamp = Timestamp.now(),
    description = s"Journey: $journeyDescription - Fare: $amount"
  )
}

/**
 * JourneyStatus - Represents the state of a journey
 */
sealed trait JourneyStatus

object JourneyStatus {
  // Journey started, waiting for tap-out
  case object InProgress extends JourneyStatus
  
  // Journey completed successfully
  case object Completed extends JourneyStatus
  
  // Journey incomplete (no tap-out) - penalty fare applied
  case object Incomplete extends JourneyStatus
}

/**
 * Journey - Represents a travel journey from one station to another
 * Core domain entity for tracking travel
 * 
 * @param id Unique journey identifier
 * @param cardId Card used for this journey
 * @param startStation Station where journey began
 * @param endStation Optional end station (None if journey incomplete)
 * @param tapInTime When the passenger tapped in
 * @param tapOutTime Optional tap-out time
 * @param fare Actual fare charged for this journey
 * @param status Current status of the journey
 */
final case class Journey(
  id: JourneyId,
  cardId: CardId,
  startStation: Station,
  endStation: Option[Station],
  tapInTime: Timestamp,
  tapOutTime: Option[Timestamp],
  fare: Money,
  status: JourneyStatus
) {
  /**
   * Complete the journey by tapping out
   * Pure function returning new Journey instance
   */
  def complete(
    station: Station,
    calculatedFare: Money
  ): Journey = this.copy(
    endStation = Some(station),
    tapOutTime = Some(Timestamp.now()),
    fare = calculatedFare,
    status = JourneyStatus.Completed
  )
  
  /**
   * Mark journey as incomplete (penalty)
   */
  def markIncomplete(penaltyFare: Money): Journey = this.copy(
    fare = penaltyFare,
    status = JourneyStatus.Incomplete
  )
  
  /**
   * Get journey description for display
   */
  def description: String = endStation match {
    case Some(end) => s"${startStation.name} → ${end.name}"
    case None => s"${startStation.name} → (Incomplete)"
  }
}

object Journey {
  /**
   * Start a new journey
   * Initial fare is set to maximum fare (will be adjusted on tap-out)
   */
  def start(
    cardId: CardId,
    station: Station,
    maximumFare: Money
  ): Journey = Journey(
    id = JourneyId.generate(),
    cardId = cardId,
    startStation = station,
    endStation = None,
    tapInTime = Timestamp.now(),
    tapOutTime = None,
    fare = maximumFare,
    status = JourneyStatus.InProgress
  )
}
