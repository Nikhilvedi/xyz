package com.oyster.domain

import java.time.Instant
import java.util.UUID

/**
 * Value Objects - Immutable types that wrap primitive values with domain meaning
 * In functional programming, we prefer opaque types over primitives to ensure type safety
 * and prevent accidentally mixing up different types of IDs or values.
 */

/**
 * AccountId - Unique identifier for a customer account
 * Wraps a UUID to ensure type safety - can't accidentally pass a CardId where AccountId is expected
 */
final case class AccountId(value: UUID) extends AnyVal {
  override def toString: String = value.toString
}

object AccountId {
  // Smart constructor - creates a new random AccountId
  // Using cats.effect.IO for effect management in real applications
  def generate(): AccountId = AccountId(UUID.randomUUID())
  
  // Parse from string representation
  def fromString(str: String): Either[String, AccountId] =
    try {
      Right(AccountId(UUID.fromString(str)))
    } catch {
      case _: IllegalArgumentException => Left(s"Invalid AccountId format: $str")
    }
}

/**
 * CardId - Unique identifier for a travel card
 * Represents the physical or virtual card number
 */
final case class CardId(value: UUID) extends AnyVal {
  override def toString: String = value.toString
}

object CardId {
  def generate(): CardId = CardId(UUID.randomUUID())
  
  def fromString(str: String): Either[String, CardId] =
    try {
      Right(CardId(UUID.fromString(str)))
    } catch {
      case _: IllegalArgumentException => Left(s"Invalid CardId format: $str")
    }
}

/**
 * Money - Represents monetary amounts in the system
 * Using BigDecimal for precise decimal arithmetic (important for financial calculations)
 * Immutable value type following functional programming principles
 * 
 * @param amount The monetary amount in the base currency (e.g., pounds)
 */
final case class Money(amount: BigDecimal) extends AnyVal {
  // Add two Money values together - returns a new Money instance (immutability)
  def +(other: Money): Money = Money(this.amount + other.amount)
  
  // Subtract Money values
  def -(other: Money): Money = Money(this.amount - other.amount)
  
  // Check if this amount is greater than or equal to another
  def >=(other: Money): Boolean = this.amount >= other.amount
  
  // Check if this amount is less than another
  def <(other: Money): Boolean = this.amount < other.amount
  
  override def toString: String = f"£${amount}%.2f"
}

object Money {
  // Common values as constants
  val Zero: Money = Money(BigDecimal(0))
  
  // Smart constructor that validates the amount
  def apply(amount: BigDecimal): Money = {
    require(amount >= 0, "Money amount cannot be negative")
    new Money(amount)
  }
  
  // Convenience constructor from Double
  def fromDouble(amount: Double): Money = Money(BigDecimal(amount))
  
  // Safe constructor that returns Either for error handling
  def create(amount: BigDecimal): Either[String, Money] =
    if (amount >= 0) Right(Money(amount))
    else Left(s"Money amount cannot be negative: $amount")
}

/**
 * Zone - Represents a transport zone (e.g., Zone 1, Zone 2)
 * London Underground-style zone system
 */
final case class Zone(number: Int) extends AnyVal {
  override def toString: String = s"Zone $number"
}

object Zone {
  // Validate zone number is within valid range (1-9 for London)
  def create(number: Int): Either[String, Zone] =
    if (number >= 1 && number <= 9) Right(Zone(number))
    else Left(s"Invalid zone number: $number. Must be between 1 and 9")
    
  // Common zones as constants
  val Zone1: Zone = Zone(1)
  val Zone2: Zone = Zone(2)
  val Zone3: Zone = Zone(3)
  val Zone4: Zone = Zone(4)
  val Zone5: Zone = Zone(5)
  val Zone6: Zone = Zone(6)
}

/**
 * StationId - Unique identifier for a station
 */
final case class StationId(value: String) extends AnyVal {
  override def toString: String = value
}

/**
 * TransactionId - Unique identifier for financial transactions
 */
final case class TransactionId(value: UUID) extends AnyVal {
  override def toString: String = value.toString
}

object TransactionId {
  def generate(): TransactionId = TransactionId(UUID.randomUUID())
}

/**
 * JourneyId - Unique identifier for a journey
 */
final case class JourneyId(value: UUID) extends AnyVal {
  override def toString: String = value.toString
}

object JourneyId {
  def generate(): JourneyId = JourneyId(UUID.randomUUID())
}

/**
 * Timestamp wrapper for type safety
 */
final case class Timestamp(value: Instant) extends AnyVal {
  override def toString: String = value.toString
}

object Timestamp {
  def now(): Timestamp = Timestamp(Instant.now())
  
  def fromInstant(instant: Instant): Timestamp = Timestamp(instant)
}
