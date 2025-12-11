package com.oyster.domain

/**
 * FareCalculator - Service for calculating fares based on journey details
 * Pure functional approach: all methods are pure functions with no side effects
 * 
 * This implements a simplified version of London's fare system:
 * - Zone 1 to Zone 1: £2.50
 * - Zone 1 to Zone 2 or Zone 2 to Zone 1: £3.00
 * - Zone 2 to Zone 2: £2.00
 * - Zone 1 to Zone 3 or vice versa: £3.50
 * - Zone 2 to Zone 3 or vice versa: £2.50
 * - Longer journeys: £4.00
 * - Maximum fare (incomplete journey): £5.00
 * - Minimum fare: £1.50 (same zone, adjacent stations)
 */
object FareCalculator {
  
  // Constant fare values
  val MaximumFare: Money = Money.fromDouble(5.00)
  val MinimumFare: Money = Money.fromDouble(1.50)
  
  // Zone-based fares (stored as a map for easy lookup)
  // The tuple (fromZone, toZone) maps to a fare
  private val zoneFares: Map[(Int, Int), Money] = Map(
    (1, 1) -> Money.fromDouble(2.50),
    (1, 2) -> Money.fromDouble(3.00),
    (2, 1) -> Money.fromDouble(3.00),
    (2, 2) -> Money.fromDouble(2.00),
    (1, 3) -> Money.fromDouble(3.50),
    (3, 1) -> Money.fromDouble(3.50),
    (2, 3) -> Money.fromDouble(2.50),
    (3, 2) -> Money.fromDouble(2.50),
    (3, 3) -> Money.fromDouble(2.50)
  )
  
  /**
   * Calculate fare for a completed journey
   * Pure function - same inputs always produce same output
   * 
   * @param from Starting station
   * @param to Destination station
   * @return Calculated fare
   */
  def calculateFare(from: Station, to: Station): Money = {
    // For stations spanning multiple zones, we use the minimum zone
    // This gives passengers the best fare
    val fromZone = from.minZone.number
    val toZone = to.minZone.number
    
    // Look up fare in the map, defaulting to a calculated fare if not found
    zoneFares.getOrElse(
      (fromZone, toZone),
      calculateFareByDistance(fromZone, toZone)
    )
  }
  
  /**
   * Calculate fare based on zone distance
   * Used when specific fare is not in the lookup table
   * 
   * @param fromZone Starting zone number
   * @param toZone Destination zone number
   * @return Calculated fare based on distance
   */
  private def calculateFareByDistance(fromZone: Int, toZone: Int): Money = {
    val distance = Math.abs(fromZone - toZone)
    distance match {
      case 0 => MinimumFare
      case 1 => Money.fromDouble(2.50)
      case 2 => Money.fromDouble(3.50)
      case _ => Money.fromDouble(4.00)
    }
  }
  
  /**
   * Get the maximum fare for an incomplete journey
   * When a passenger doesn't tap out, they're charged the maximum fare
   */
  def maximumFare: Money = MaximumFare
  
  /**
   * Calculate refund amount when journey is corrected
   * If maximum fare was charged but actual fare is less, calculate refund
   * 
   * @param actualFare The correct fare for the journey
   * @param chargedFare The fare that was actually charged
   * @return Refund amount (0 if no refund due)
   */
  def calculateRefund(actualFare: Money, chargedFare: Money): Money = {
    if (chargedFare.amount > actualFare.amount) {
      Money(chargedFare.amount - actualFare.amount)
    } else {
      Money.Zero
    }
  }
  
  /**
   * Check if a fare is valid
   * Ensures fare is within acceptable range
   */
  def isValidFare(fare: Money): Boolean = {
    fare.amount >= MinimumFare.amount && fare.amount <= MaximumFare.amount
  }
}

/**
 * FareRules - Business rules for fare validation and policies
 * Encapsulates domain knowledge about fare policies
 */
object FareRules {
  
  /**
   * Minimum balance required to start a journey
   * Passengers must have at least the maximum fare available
   */
  def minimumBalanceRequired: Money = FareCalculator.MaximumFare
  
  /**
   * Check if a card has sufficient balance to start a journey
   * 
   * @param currentBalance The card's current balance
   * @return Either error message or success
   */
  def validateBalanceForJourney(currentBalance: Money): Either[String, Unit] = {
    if (currentBalance >= minimumBalanceRequired) {
      Right(())
    } else {
      Left(s"Insufficient balance. Minimum required: $minimumBalanceRequired, Current: $currentBalance")
    }
  }
  
  /**
   * Maximum top-up amount allowed per transaction
   */
  val MaxTopUpAmount: Money = Money.fromDouble(100.00)
  
  /**
   * Minimum top-up amount allowed per transaction
   */
  val MinTopUpAmount: Money = Money.fromDouble(1.00)
  
  /**
   * Validate top-up amount
   * 
   * @param amount Amount to top up
   * @return Either error message or validated amount
   */
  def validateTopUpAmount(amount: Money): Either[String, Money] = {
    if (amount < MinTopUpAmount) {
      Left(s"Top-up amount too small. Minimum: $MinTopUpAmount")
    } else if (amount.amount > MaxTopUpAmount.amount) {
      Left(s"Top-up amount too large. Maximum: $MaxTopUpAmount")
    } else {
      Right(amount)
    }
  }
  
  /**
   * Maximum wallet balance allowed
   * Prevents excessive balances for fraud prevention
   */
  val MaxWalletBalance: Money = Money.fromDouble(500.00)
  
  /**
   * Validate that a top-up won't exceed maximum wallet balance
   * 
   * @param currentBalance Current wallet balance
   * @param topUpAmount Amount to add
   * @return Either error or success
   */
  def validateWalletLimit(
    currentBalance: Money,
    topUpAmount: Money
  ): Either[String, Unit] = {
    val newBalance = currentBalance + topUpAmount
    if (newBalance.amount > MaxWalletBalance.amount) {
      Left(s"Top-up would exceed maximum wallet balance of $MaxWalletBalance")
    } else {
      Right(())
    }
  }
}
