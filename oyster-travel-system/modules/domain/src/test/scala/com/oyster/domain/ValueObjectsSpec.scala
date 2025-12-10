package com.oyster.domain

import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers
import org.scalatest.EitherValues

/**
 * Test suite for Money value object
 * Demonstrates testing pure functions and value objects
 */
class MoneySpec extends AnyFlatSpec with Matchers with EitherValues {
  
  "Money.apply" should "create valid Money with non-negative amount" in {
    val money = Money(BigDecimal(10.00))
    money.amount shouldBe BigDecimal(10.00)
  }
  
  it should "throw exception for negative amount" in {
    an[IllegalArgumentException] should be thrownBy {
      Money(BigDecimal(-5.00))
    }
  }
  
  "Money.create" should "return Right for valid amount" in {
    val result = Money.create(BigDecimal(10.00))
    result.isRight shouldBe true
    result.value.amount shouldBe BigDecimal(10.00)
  }
  
  it should "return Left for negative amount" in {
    val result = Money.create(BigDecimal(-5.00))
    result.isLeft shouldBe true
  }
  
  "Money addition" should "correctly add two Money values" in {
    val money1 = Money.fromDouble(10.00)
    val money2 = Money.fromDouble(5.00)
    val result = money1 + money2
    result.amount shouldBe BigDecimal(15.00)
  }
  
  "Money subtraction" should "correctly subtract Money values" in {
    val money1 = Money.fromDouble(10.00)
    val money2 = Money.fromDouble(5.00)
    val result = money1 - money2
    result.amount shouldBe BigDecimal(5.00)
  }
  
  "Money comparison" should "correctly compare Money values" in {
    val money1 = Money.fromDouble(10.00)
    val money2 = Money.fromDouble(5.00)
    
    (money1 >= money2) shouldBe true
    (money2 >= money1) shouldBe false
    (money2 < money1) shouldBe true
  }
  
  "Money.Zero" should "have zero amount" in {
    Money.Zero.amount shouldBe BigDecimal(0)
  }
}

/**
 * Test suite for Zone value object
 */
class ZoneSpec extends AnyFlatSpec with Matchers with EitherValues {
  
  "Zone.create" should "accept valid zone numbers 1-9" in {
    (1 to 9).foreach { num =>
      val result = Zone.create(num)
      result.isRight shouldBe true
      result.value.number shouldBe num
    }
  }
  
  it should "reject zone number 0" in {
    val result = Zone.create(0)
    result.isLeft shouldBe true
  }
  
  it should "reject zone number 10" in {
    val result = Zone.create(10)
    result.isLeft shouldBe true
  }
  
  it should "reject negative zone numbers" in {
    val result = Zone.create(-1)
    result.isLeft shouldBe true
  }
  
  "Zone constants" should "have correct numbers" in {
    Zone.Zone1.number shouldBe 1
    Zone.Zone2.number shouldBe 2
    Zone.Zone3.number shouldBe 3
  }
}

/**
 * Test suite for AccountId
 */
class AccountIdSpec extends AnyFlatSpec with Matchers with EitherValues {
  
  "AccountId.generate" should "create unique IDs" in {
    val id1 = AccountId.generate()
    val id2 = AccountId.generate()
    
    id1 should not equal id2
  }
  
  "AccountId.fromString" should "parse valid UUID string" in {
    val uuid = "550e8400-e29b-41d4-a716-446655440000"
    val result = AccountId.fromString(uuid)
    
    result.isRight shouldBe true
    result.value.toString shouldBe uuid
  }
  
  it should "return Left for invalid UUID string" in {
    val result = AccountId.fromString("not-a-uuid")
    result.isLeft shouldBe true
  }
}
