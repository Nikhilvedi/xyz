package com.oyster.domain

import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers
import org.scalatest.EitherValues

/**
 * Test suite for Station domain model
 */
class StationSpec extends AnyFlatSpec with Matchers with EitherValues {
  
  "Station" should "have non-empty name" in {
    an[IllegalArgumentException] should be thrownBy {
      Station(StationId("test"), "", Set(Zone.Zone1))
    }
  }
  
  it should "belong to at least one zone" in {
    an[IllegalArgumentException] should be thrownBy {
      Station(StationId("test"), "Test Station", Set.empty)
    }
  }
  
  "Station.create" should "create valid station" in {
    val result = Station.create(
      StationId("test"),
      "Test Station",
      Set(Zone.Zone1)
    )
    result.isRight shouldBe true
  }
  
  it should "reject empty name" in {
    val result = Station.create(
      StationId("test"),
      "",
      Set(Zone.Zone1)
    )
    result.isLeft shouldBe true
  }
  
  it should "trim whitespace from name" in {
    val result = Station.create(
      StationId("test"),
      "  Test Station  ",
      Set(Zone.Zone1)
    )
    result.isRight shouldBe true
    result.value.name shouldBe "Test Station"
  }
  
  "Station.minZone" should "return lowest zone number" in {
    val station = Station(
      StationId("test"),
      "Multi-zone Station",
      Set(Zone.Zone1, Zone.Zone2, Zone.Zone3)
    )
    station.minZone shouldBe Zone.Zone1
  }
  
  "Station.isInZone" should "correctly identify zones" in {
    val station = Station(
      StationId("test"),
      "Test Station",
      Set(Zone.Zone1, Zone.Zone2)
    )
    
    station.isInZone(Zone.Zone1) shouldBe true
    station.isInZone(Zone.Zone2) shouldBe true
    station.isInZone(Zone.Zone3) shouldBe false
  }
}

/**
 * Test suite for Card domain model
 */
class CardSpec extends AnyFlatSpec with Matchers with EitherValues {
  
  "Card.create" should "create card with Pending status" in {
    val accountId = AccountId.generate()
    val card = Card.create(accountId)
    
    card.accountId shouldBe accountId
    card.status shouldBe CardStatus.Pending
  }
  
  "Card.isUsable" should "return true for Active cards" in {
    val card = Card.create(AccountId.generate()).copy(status = CardStatus.Active)
    card.isUsable shouldBe true
  }
  
  it should "return false for non-Active cards" in {
    val card1 = Card.create(AccountId.generate()) // Pending
    card1.isUsable shouldBe false
    
    val card2 = card1.block() // Blocked
    card2.isUsable shouldBe false
    
    val card3 = card1.cancel() // Cancelled
    card3.isUsable shouldBe false
  }
  
  "Card.activate" should "activate Pending card" in {
    val card = Card.create(AccountId.generate())
    val result = card.activate()
    
    result.isRight shouldBe true
    result.value.status shouldBe CardStatus.Active
  }
  
  it should "fail to activate non-Pending card" in {
    val card = Card.create(AccountId.generate()).copy(status = CardStatus.Active)
    val result = card.activate()
    
    result.isLeft shouldBe true
  }
  
  "Card.block" should "change status to Blocked" in {
    val card = Card.create(AccountId.generate()).copy(status = CardStatus.Active)
    val blocked = card.block()
    
    blocked.status shouldBe CardStatus.Blocked
  }
  
  "Card.cancel" should "change status to Cancelled" in {
    val card = Card.create(AccountId.generate()).copy(status = CardStatus.Active)
    val cancelled = card.cancel()
    
    cancelled.status shouldBe CardStatus.Cancelled
  }
}

/**
 * Test suite for Account domain model
 */
class AccountSpec extends AnyFlatSpec with Matchers with EitherValues {
  
  "Account" should "require valid email" in {
    an[IllegalArgumentException] should be thrownBy {
      Account(
        AccountId.generate(),
        "not-an-email",
        "Test User",
        Timestamp.now()
      )
    }
  }
  
  it should "require non-empty name" in {
    an[IllegalArgumentException] should be thrownBy {
      Account(
        AccountId.generate(),
        "test@example.com",
        "",
        Timestamp.now()
      )
    }
  }
  
  "Account.create" should "create valid account" in {
    val result = Account.create("test@example.com", "Test User")
    
    result.isRight shouldBe true
    result.value.email shouldBe "test@example.com"
    result.value.name shouldBe "Test User"
  }
  
  it should "reject invalid email" in {
    val result = Account.create("not-an-email", "Test User")
    result.isLeft shouldBe true
  }
  
  it should "reject empty name" in {
    val result = Account.create("test@example.com", "")
    result.isLeft shouldBe true
  }
  
  it should "trim whitespace" in {
    val result = Account.create("  test@example.com  ", "  Test User  ")
    result.isRight shouldBe true
    result.value.email shouldBe "test@example.com"
    result.value.name shouldBe "Test User"
  }
}

/**
 * Test suite for Wallet domain model
 */
class WalletSpec extends AnyFlatSpec with Matchers with EitherValues {
  
  "Wallet.create" should "create wallet with zero balance" in {
    val cardId = CardId.generate()
    val wallet = Wallet.create(cardId)
    
    wallet.cardId shouldBe cardId
    wallet.balance shouldBe Money.Zero
  }
  
  "Wallet.topUp" should "increase balance" in {
    val wallet = Wallet.create(CardId.generate())
    val updated = wallet.topUp(Money.fromDouble(20.00))
    
    updated.balance shouldBe Money.fromDouble(20.00)
  }
  
  it should "maintain immutability" in {
    val wallet = Wallet.create(CardId.generate())
    val updated = wallet.topUp(Money.fromDouble(20.00))
    
    wallet.balance shouldBe Money.Zero
    updated.balance shouldBe Money.fromDouble(20.00)
  }
  
  "Wallet.deduct" should "decrease balance when sufficient" in {
    val wallet = Wallet.create(CardId.generate()).topUp(Money.fromDouble(20.00))
    val result = wallet.deduct(Money.fromDouble(5.00))
    
    result.isRight shouldBe true
    result.value.balance shouldBe Money.fromDouble(15.00)
  }
  
  it should "fail when insufficient balance" in {
    val wallet = Wallet.create(CardId.generate()).topUp(Money.fromDouble(5.00))
    val result = wallet.deduct(Money.fromDouble(10.00))
    
    result.isLeft shouldBe true
  }
  
  "Wallet.hasSufficientBalance" should "correctly check balance" in {
    val wallet = Wallet.create(CardId.generate()).topUp(Money.fromDouble(10.00))
    
    wallet.hasSufficientBalance(Money.fromDouble(5.00)) shouldBe true
    wallet.hasSufficientBalance(Money.fromDouble(10.00)) shouldBe true
    wallet.hasSufficientBalance(Money.fromDouble(15.00)) shouldBe false
  }
}
