package com.oyster.account

import cats.effect.IO
import cats.effect.unsafe.implicits.global
import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers
import org.scalatest.EitherValues
import com.oyster.domain._

/**
 * Integration tests for AccountService
 * These tests verify the service layer behavior including repository interactions
 */
class AccountServiceSpec extends AnyFlatSpec with Matchers with EitherValues {
  
  // Helper to create a fresh service for each test
  def createService(): AccountService = {
    AccountService.create.unsafeRunSync()
  }
  
  "AccountService.createAccount" should "create a new account" in {
    val service = createService()
    
    val result = service.createAccount(
      email = "test@example.com",
      name = "Test User"
    ).unsafeRunSync()
    
    result.isRight shouldBe true
    result.value.email shouldBe "test@example.com"
    result.value.name shouldBe "Test User"
  }
  
  it should "reject duplicate email addresses" in {
    val service = createService()
    
    // Create first account
    service.createAccount("test@example.com", "User One").unsafeRunSync()
    
    // Try to create second account with same email
    val result = service.createAccount("test@example.com", "User Two").unsafeRunSync()
    
    result.isLeft shouldBe true
    result.left.value should include("already exists")
  }
  
  it should "validate email format" in {
    val service = createService()
    
    val result = service.createAccount("not-an-email", "Test User").unsafeRunSync()
    
    result.isLeft shouldBe true
  }
  
  it should "validate name is non-empty" in {
    val service = createService()
    
    val result = service.createAccount("test@example.com", "").unsafeRunSync()
    
    result.isLeft shouldBe true
  }
  
  "AccountService.getAccount" should "retrieve existing account" in {
    val service = createService()
    
    // Create account
    val created = service.createAccount("test@example.com", "Test User")
      .unsafeRunSync()
      .value
    
    // Retrieve it
    val retrieved = service.getAccount(created.id).unsafeRunSync()
    
    retrieved.isRight shouldBe true
    retrieved.value shouldBe created
  }
  
  it should "return error for non-existent account" in {
    val service = createService()
    
    val result = service.getAccount(AccountId.generate()).unsafeRunSync()
    
    result.isLeft shouldBe true
    result.left.value should include("not found")
  }
  
  "AccountService.getAccountByEmail" should "find account by email" in {
    val service = createService()
    
    // Create account
    service.createAccount("test@example.com", "Test User").unsafeRunSync()
    
    // Find by email
    val result = service.getAccountByEmail("test@example.com").unsafeRunSync()
    
    result.isRight shouldBe true
    result.value.email shouldBe "test@example.com"
  }
  
  it should "be case-insensitive for email" in {
    val service = createService()
    
    // Create with lowercase
    service.createAccount("test@example.com", "Test User").unsafeRunSync()
    
    // Find with mixed case
    val result = service.getAccountByEmail("Test@Example.com").unsafeRunSync()
    
    result.isRight shouldBe true
  }
  
  "AccountService.listAllAccounts" should "return all accounts" in {
    val service = createService()
    
    // Create multiple accounts
    service.createAccount("user1@example.com", "User One").unsafeRunSync()
    service.createAccount("user2@example.com", "User Two").unsafeRunSync()
    service.createAccount("user3@example.com", "User Three").unsafeRunSync()
    
    // List all
    val accounts = service.listAllAccounts().unsafeRunSync()
    
    accounts.length shouldBe 3
    accounts.map(_.email) should contain allOf (
      "user1@example.com",
      "user2@example.com",
      "user3@example.com"
    )
  }
  
  "AccountService.updateAccount" should "update account name" in {
    val service = createService()
    
    // Create account
    val account = service.createAccount("test@example.com", "Old Name")
      .unsafeRunSync()
      .value
    
    // Update name
    val updated = service.updateAccount(
      account.id,
      newName = Some("New Name"),
      newEmail = None
    ).unsafeRunSync()
    
    updated.isRight shouldBe true
    updated.value.name shouldBe "New Name"
    updated.value.email shouldBe "test@example.com"
  }
  
  it should "update account email" in {
    val service = createService()
    
    // Create account
    val account = service.createAccount("old@example.com", "Test User")
      .unsafeRunSync()
      .value
    
    // Update email
    val updated = service.updateAccount(
      account.id,
      newName = None,
      newEmail = Some("new@example.com")
    ).unsafeRunSync()
    
    updated.isRight shouldBe true
    updated.value.email shouldBe "new@example.com"
  }
  
  it should "reject duplicate email on update" in {
    val service = createService()
    
    // Create two accounts
    val account1 = service.createAccount("user1@example.com", "User One")
      .unsafeRunSync()
      .value
    service.createAccount("user2@example.com", "User Two").unsafeRunSync()
    
    // Try to update account1 to use account2's email
    val result = service.updateAccount(
      account1.id,
      newName = None,
      newEmail = Some("user2@example.com")
    ).unsafeRunSync()
    
    result.isLeft shouldBe true
    result.left.value should include("already in use")
  }
}

/**
 * Integration tests for CardService
 */
class CardServiceSpec extends AnyFlatSpec with Matchers with EitherValues {
  
  // Helper to create services with an account
  def createServices(): (AccountService, CardService, Account) = {
    val accountService = AccountService.create.unsafeRunSync()
    val cardService = CardService.create.unsafeRunSync()
    
    val account = accountService.createAccount("test@example.com", "Test User")
      .unsafeRunSync()
      .value
    
    (accountService, cardService, account)
  }
  
  "CardService.orderCard" should "create a card in Pending status" in {
    val (_, cardService, account) = createServices()
    
    val result = cardService.orderCard(account.id).unsafeRunSync()
    
    result.isRight shouldBe true
    result.value.accountId shouldBe account.id
    result.value.status shouldBe CardStatus.Pending
  }
  
  it should "fail for non-existent account" in {
    val (_, cardService, _) = createServices()
    
    val result = cardService.orderCard(AccountId.generate()).unsafeRunSync()
    
    result.isLeft shouldBe true
    result.left.value should include("not found")
  }
  
  "CardService.activateCard" should "activate a Pending card" in {
    val (_, cardService, account) = createServices()
    
    // Order card
    val card = cardService.orderCard(account.id).unsafeRunSync().value
    
    // Activate it
    val result = cardService.activateCard(card.id).unsafeRunSync()
    
    result.isRight shouldBe true
    result.value.status shouldBe CardStatus.Active
  }
  
  it should "fail to activate non-Pending card" in {
    val (_, cardService, account) = createServices()
    
    // Order and activate card
    val card = cardService.orderCard(account.id).unsafeRunSync().value
    cardService.activateCard(card.id).unsafeRunSync()
    
    // Try to activate again
    val result = cardService.activateCard(card.id).unsafeRunSync()
    
    result.isLeft shouldBe true
  }
  
  "CardService.blockCard" should "block a card" in {
    val (_, cardService, account) = createServices()
    
    // Order and activate card
    val card = cardService.orderCard(account.id).unsafeRunSync().value
    cardService.activateCard(card.id).unsafeRunSync()
    
    // Block it
    val result = cardService.blockCard(card.id).unsafeRunSync()
    
    result.isRight shouldBe true
    result.value.status shouldBe CardStatus.Blocked
  }
  
  "CardService.validateCardForTravel" should "accept Active cards" in {
    val (_, cardService, account) = createServices()
    
    // Order and activate card
    val card = cardService.orderCard(account.id).unsafeRunSync().value
    cardService.activateCard(card.id).unsafeRunSync()
    
    // Validate
    val result = cardService.validateCardForTravel(card.id).unsafeRunSync()
    
    result.isRight shouldBe true
  }
  
  it should "reject non-Active cards" in {
    val (_, cardService, account) = createServices()
    
    // Order card (Pending status)
    val card = cardService.orderCard(account.id).unsafeRunSync().value
    
    // Try to validate
    val result = cardService.validateCardForTravel(card.id).unsafeRunSync()
    
    result.isLeft shouldBe true
    result.left.value should include("not active")
  }
  
  "CardService.listCardsForAccount" should "return all cards for account" in {
    val (_, cardService, account) = createServices()
    
    // Order multiple cards
    cardService.orderCard(account.id).unsafeRunSync()
    cardService.orderCard(account.id).unsafeRunSync()
    cardService.orderCard(account.id).unsafeRunSync()
    
    // List cards
    val cards = cardService.listCardsForAccount(account.id).unsafeRunSync()
    
    cards.length shouldBe 3
    cards.forall(_.accountId == account.id) shouldBe true
  }
}
