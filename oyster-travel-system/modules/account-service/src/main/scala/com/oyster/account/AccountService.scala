package com.oyster.account

import cats.effect.IO
import cats.effect.Ref
import cats.implicits._
import com.oyster.domain._

/**
 * AccountRepository - Repository pattern for Account persistence
 * In functional programming, we use algebraic effects (IO) to manage side effects
 * This trait defines the interface - implementations can be in-memory, database, etc.
 * 
 * Using cats.effect.IO for:
 * - Lazy evaluation (IO describes an effect, doesn't run it immediately)
 * - Composability (can chain IOs together)
 * - Error handling (IO can fail safely)
 * - Resource safety (proper cleanup)
 */
trait AccountRepository {
  /**
   * Save an account to the repository
   * Returns IO[Unit] - an effect that produces Unit when run
   */
  def save(account: Account): IO[Unit]
  
  /**
   * Find an account by its ID
   * Returns IO[Option[Account]] - may or may not find the account
   */
  def findById(id: AccountId): IO[Option[Account]]
  
  /**
   * Find an account by email address
   * Useful for preventing duplicate accounts
   */
  def findByEmail(email: String): IO[Option[Account]]
  
  /**
   * List all accounts
   * Returns all accounts in the system
   */
  def listAll(): IO[List[Account]]
}

/**
 * InMemoryAccountRepository - In-memory implementation of AccountRepository
 * Uses Ref for thread-safe mutable state in a functional way
 * 
 * Ref is a purely functional concurrent mutable reference
 * - Provides atomic updates
 * - Thread-safe
 * - Composable with other IOs
 * 
 * @param state Ref holding the map of accounts
 */
class InMemoryAccountRepository private (
  state: Ref[IO, Map[AccountId, Account]]
) extends AccountRepository {
  
  override def save(account: Account): IO[Unit] =
    // Atomically update the state by adding/updating the account
    state.update(accounts => accounts + (account.id -> account))
  
  override def findById(id: AccountId): IO[Option[Account]] =
    // Get the current state and look up the account
    state.get.map(_.get(id))
  
  override def findByEmail(email: String): IO[Option[Account]] =
    // Get all accounts and find the one with matching email
    state.get.map(_.values.find(_.email.equalsIgnoreCase(email)))
  
  override def listAll(): IO[List[Account]] =
    state.get.map(_.values.toList)
}

object InMemoryAccountRepository {
  /**
   * Create a new empty repository
   * Returns IO[AccountRepository] - construction is an effect
   */
  def empty: IO[AccountRepository] =
    Ref.of[IO, Map[AccountId, Account]](Map.empty)
      .map(ref => new InMemoryAccountRepository(ref))
  
  /**
   * Create a repository with initial accounts
   * Useful for testing or demo scenarios
   */
  def withAccounts(accounts: List[Account]): IO[AccountRepository] =
    Ref.of[IO, Map[AccountId, Account]](
      accounts.map(a => a.id -> a).toMap
    ).map(ref => new InMemoryAccountRepository(ref))
}

/**
 * AccountService - Business logic for account management
 * Orchestrates operations on accounts using the repository
 * 
 * All methods return IO[Either[String, A]] where:
 * - IO wraps the effect (database access, etc.)
 * - Either captures business logic errors (Left) or success (Right)
 * 
 * This pattern separates technical failures (IO failures) from business failures (Either)
 * 
 * @param repository The account repository for persistence
 */
class AccountService(repository: AccountRepository) {
  
  /**
   * Create a new account
   * Validates that email is unique and account data is valid
   * 
   * @param email Customer email
   * @param name Customer name
   * @return Either error message or created account
   */
  def createAccount(
    email: String,
    name: String
  ): IO[Either[String, Account]] = {
    // First, try to create the account (validates email and name)
    Account.create(email, name) match {
      case Left(error) =>
        // Validation failed - return immediately
        IO.pure(Left(error))
        
      case Right(account) =>
        // Validation passed - check if email already exists
        repository.findByEmail(email).flatMap {
          case Some(_) =>
            // Email already exists
            IO.pure(Left(s"Account with email $email already exists"))
            
          case None =>
            // Email is unique - save the account
            repository.save(account).map(_ => Right(account))
        }
    }
  }
  
  /**
   * Get an account by ID
   * 
   * @param id Account identifier
   * @return Either error message or found account
   */
  def getAccount(id: AccountId): IO[Either[String, Account]] =
    repository.findById(id).map {
      case Some(account) => Right(account)
      case None => Left(s"Account not found: $id")
    }
  
  /**
   * Get an account by email
   * 
   * @param email Email address
   * @return Either error message or found account
   */
  def getAccountByEmail(email: String): IO[Either[String, Account]] =
    repository.findByEmail(email).map {
      case Some(account) => Right(account)
      case None => Left(s"Account not found for email: $email")
    }
  
  /**
   * List all accounts in the system
   * Useful for administrative operations
   */
  def listAllAccounts(): IO[List[Account]] =
    repository.listAll()
  
  /**
   * Update account information
   * Currently supports updating name and email
   * 
   * @param accountId ID of account to update
   * @param newName Optional new name
   * @param newEmail Optional new email
   * @return Either error or updated account
   */
  def updateAccount(
    accountId: AccountId,
    newName: Option[String],
    newEmail: Option[String]
  ): IO[Either[String, Account]] = {
    repository.findById(accountId).flatMap {
      case None =>
        IO.pure(Left(s"Account not found: $accountId"))
        
      case Some(account) =>
        // Build updated account
        val updatedName = newName.getOrElse(account.name)
        val updatedEmail = newEmail.getOrElse(account.email)
        
        // Validate new email if changed
        if (newEmail.isDefined && newEmail.get != account.email) {
          repository.findByEmail(updatedEmail).flatMap {
            case Some(_) =>
              IO.pure(Left(s"Email $updatedEmail is already in use"))
            case None =>
              val updated = account.copy(name = updatedName, email = updatedEmail)
              repository.save(updated).map(_ => Right(updated))
          }
        } else {
          val updated = account.copy(name = updatedName)
          repository.save(updated).map(_ => Right(updated))
        }
    }
  }
}

object AccountService {
  /**
   * Create an AccountService with an empty repository
   */
  def create: IO[AccountService] =
    InMemoryAccountRepository.empty.map(repo => new AccountService(repo))
  
  /**
   * Create an AccountService with a specific repository
   */
  def withRepository(repository: AccountRepository): AccountService =
    new AccountService(repository)
}
