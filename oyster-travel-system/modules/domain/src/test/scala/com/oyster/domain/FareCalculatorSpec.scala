package com.oyster.domain

import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers

/**
 * Test suite for FareCalculator
 * Tests the core fare calculation logic
 */
class FareCalculatorSpec extends AnyFlatSpec with Matchers {
  
  "FareCalculator.calculateFare" should "calculate correct fare for Zone 1 to Zone 1" in {
    val fare = FareCalculator.calculateFare(Station.Holborn, Station.KingsCross)
    fare shouldBe Money.fromDouble(2.50)
  }
  
  it should "calculate correct fare for Zone 1 to Zone 2" in {
    val fare = FareCalculator.calculateFare(Station.KingsCross, Station.Hammersmith)
    fare shouldBe Money.fromDouble(3.00)
  }
  
  it should "calculate correct fare for Zone 2 to Zone 2" in {
    val fare = FareCalculator.calculateFare(Station.Hammersmith, Station.EarlsCourt)
    fare shouldBe Money.fromDouble(2.00)
  }
  
  it should "calculate correct fare for Zone 1 to Zone 3" in {
    val fare = FareCalculator.calculateFare(Station.KingsCross, Station.Wimbledon)
    fare shouldBe Money.fromDouble(3.50)
  }
  
  it should "use minimum zone for stations spanning multiple zones" in {
    // Earl's Court spans Zone 1 and Zone 2
    val fare = FareCalculator.calculateFare(Station.KingsCross, Station.EarlsCourt)
    // Should use the best fare (Zone 1 to Zone 1)
    fare shouldBe Money.fromDouble(2.50)
  }
  
  "FareCalculator.maximumFare" should "return £5.00" in {
    FareCalculator.maximumFare shouldBe Money.fromDouble(5.00)
  }
  
  "FareCalculator.calculateRefund" should "calculate correct refund when overcharged" in {
    val actualFare = Money.fromDouble(2.50)
    val chargedFare = Money.fromDouble(5.00)
    val refund = FareCalculator.calculateRefund(actualFare, chargedFare)
    refund shouldBe Money.fromDouble(2.50)
  }
  
  it should "return zero refund when not overcharged" in {
    val actualFare = Money.fromDouble(3.00)
    val chargedFare = Money.fromDouble(2.50)
    val refund = FareCalculator.calculateRefund(actualFare, chargedFare)
    refund shouldBe Money.Zero
  }
  
  "FareCalculator.isValidFare" should "accept fares within range" in {
    FareCalculator.isValidFare(Money.fromDouble(2.50)) shouldBe true
    FareCalculator.isValidFare(Money.fromDouble(1.50)) shouldBe true
    FareCalculator.isValidFare(Money.fromDouble(5.00)) shouldBe true
  }
  
  it should "reject fares below minimum" in {
    FareCalculator.isValidFare(Money.fromDouble(1.00)) shouldBe false
  }
  
  it should "reject fares above maximum" in {
    FareCalculator.isValidFare(Money.fromDouble(6.00)) shouldBe false
  }
}

/**
 * Test suite for FareRules
 * Tests business rules for fares and balances
 */
class FareRulesSpec extends AnyFlatSpec with Matchers {
  
  "FareRules.minimumBalanceRequired" should "equal maximum fare" in {
    FareRules.minimumBalanceRequired shouldBe FareCalculator.MaximumFare
  }
  
  "FareRules.validateBalanceForJourney" should "accept sufficient balance" in {
    val result = FareRules.validateBalanceForJourney(Money.fromDouble(10.00))
    result.isRight shouldBe true
  }
  
  it should "reject insufficient balance" in {
    val result = FareRules.validateBalanceForJourney(Money.fromDouble(4.00))
    result.isLeft shouldBe true
  }
  
  "FareRules.validateTopUpAmount" should "accept valid amounts" in {
    val result = FareRules.validateTopUpAmount(Money.fromDouble(20.00))
    result.isRight shouldBe true
  }
  
  it should "reject amounts below minimum" in {
    val result = FareRules.validateTopUpAmount(Money.fromDouble(0.50))
    result.isLeft shouldBe true
  }
  
  it should "reject amounts above maximum" in {
    val result = FareRules.validateTopUpAmount(Money.fromDouble(150.00))
    result.isLeft shouldBe true
  }
  
  "FareRules.validateWalletLimit" should "accept top-ups within limit" in {
    val currentBalance = Money.fromDouble(100.00)
    val topUpAmount = Money.fromDouble(50.00)
    val result = FareRules.validateWalletLimit(currentBalance, topUpAmount)
    result.isRight shouldBe true
  }
  
  it should "reject top-ups exceeding limit" in {
    val currentBalance = Money.fromDouble(480.00)
    val topUpAmount = Money.fromDouble(50.00)
    val result = FareRules.validateWalletLimit(currentBalance, topUpAmount)
    result.isLeft shouldBe true
  }
}
