package com.oyster.tap

import cats.effect.IO
import cats.effect.Ref
import cats.implicits._
import com.oyster.domain._
import com.oyster.wallet.WalletService

/**
 * JourneyRepository - Repository for Journey persistence
 * Stores journey information for travel tracking
 */
trait JourneyRepository {
  def save(journey: Journey): IO[Unit]
  def findById(id: JourneyId): IO[Option[Journey]]
  def findByCardId(cardId: CardId): IO[List[Journey]]
  def findInProgressJourney(cardId: CardId): IO[Option[Journey]]
  def listAll(): IO[List[Journey]]
}

/**
 * InMemoryJourneyRepository - In-memory implementation
 */
class InMemoryJourneyRepository private (
  state: Ref[IO, Map[JourneyId, Journey]]
) extends JourneyRepository {
  
  override def save(journey: Journey): IO[Unit] =
    state.update(journeys => journeys + (journey.id -> journey))
  
  override def findById(id: JourneyId): IO[Option[Journey]] =
    state.get.map(_.get(id))
  
  override def findByCardId(cardId: CardId): IO[List[Journey]] =
    state.get.map(
      _.values
        .filter(_.cardId == cardId)
        .toList
        .sortBy(_.tapInTime.value.toEpochMilli)
        .reverse // Most recent first
    )
  
  override def findInProgressJourney(cardId: CardId): IO[Option[Journey]] =
    state.get.map(
      _.values
        .find(j => j.cardId == cardId && j.status == JourneyStatus.InProgress)
    )
  
  override def listAll(): IO[List[Journey]] =
    state.get.map(_.values.toList)
}

object InMemoryJourneyRepository {
  def empty: IO[JourneyRepository] =
    Ref.of[IO, Map[JourneyId, Journey]](Map.empty)
      .map(ref => new InMemoryJourneyRepository(ref))
  
  def withJourneys(journeys: List[Journey]): IO[JourneyRepository] =
    Ref.of[IO, Map[JourneyId, Journey]](
      journeys.map(j => j.id -> j).toMap
    ).map(ref => new InMemoryJourneyRepository(ref))
}

/**
 * TapValidationService - Core service for handling tap-in and tap-out operations
 * This is the heart of the travel system, managing journey lifecycle
 * 
 * Key responsibilities:
 * - Validate tap-in operations
 * - Handle tap-out and fare calculation
 * - Manage journey state transitions
 * - Coordinate with wallet service for payments
 * 
 * @param journeyRepository Repository for journey state
 * @param walletService Service for wallet operations
 */
class TapValidationService(
  journeyRepository: JourneyRepository,
  walletService: WalletService
) {
  
  /**
   * Handle tap-in at a station
   * 
   * Process:
   * 1. Check if card has an in-progress journey (error if yes)
   * 2. Validate wallet has sufficient balance
   * 3. Deduct maximum fare (will be adjusted on tap-out)
   * 4. Create new journey in InProgress status
   * 
   * This follows the Oyster system where maximum fare is held on tap-in
   * and adjusted to actual fare on tap-out
   * 
   * @param cardId The card being tapped
   * @param station The station where tap-in occurs
   * @return Either error or created journey
   */
  def tapIn(
    cardId: CardId,
    station: Station
  ): IO[Either[String, Journey]] = {
    // Check for existing in-progress journey
    journeyRepository.findInProgressJourney(cardId).flatMap {
      case Some(existingJourney) =>
        IO.pure(Left(
          s"Journey already in progress from ${existingJourney.startStation.name}. " +
          s"Please tap out before starting a new journey."
        ))
        
      case None =>
        // Validate sufficient balance
        walletService.validateBalanceForJourney(cardId).flatMap {
          case Left(error) =>
            IO.pure(Left(error))
            
          case Right(_) =>
            // Deduct maximum fare
            val maxFare = FareCalculator.maximumFare
            walletService.deductFare(
              cardId,
              maxFare,
              s"Tap-in at ${station.name} (Maximum fare hold)"
            ).flatMap {
              case Left(error) =>
                IO.pure(Left(error))
                
              case Right(_) =>
                // Create journey
                val journey = Journey.start(cardId, station, maxFare)
                journeyRepository.save(journey).map(_ => Right(journey))
            }
        }
    }
  }
  
  /**
   * Handle tap-out at a station
   * 
   * Process:
   * 1. Find in-progress journey for card
   * 2. Calculate actual fare based on start and end stations
   * 3. Calculate refund (maximum fare - actual fare)
   * 4. Apply refund to wallet
   * 5. Update journey to Completed status
   * 
   * @param cardId The card being tapped
   * @param station The station where tap-out occurs
   * @return Either error or completed journey
   */
  def tapOut(
    cardId: CardId,
    station: Station
  ): IO[Either[String, Journey]] = {
    // Find in-progress journey
    journeyRepository.findInProgressJourney(cardId).flatMap {
      case None =>
        IO.pure(Left(s"No journey in progress for card: $cardId"))
        
      case Some(journey) =>
        // Calculate actual fare
        val actualFare = FareCalculator.calculateFare(
          journey.startStation,
          station
        )
        
        // Calculate refund
        val refund = FareCalculator.calculateRefund(actualFare, journey.fare)
        
        // Apply refund if there is one
        val refundIO: IO[Either[String, Unit]] = 
          if (refund.amount > 0) {
            walletService.topUp(cardId, refund).map(_.map(_ => ()))
          } else {
            IO.pure(Right(()))
          }
        
        refundIO.flatMap {
          case Left(error) =>
            IO.pure(Left(s"Failed to apply refund: $error"))
            
          case Right(_) =>
            // Complete the journey
            val completedJourney = journey.complete(station, actualFare)
            journeyRepository.save(completedJourney).map(_ => Right(completedJourney))
        }
    }
  }
  
  /**
   * Get journey information
   * 
   * @param journeyId The journey identifier
   * @return Either error or journey
   */
  def getJourney(journeyId: JourneyId): IO[Either[String, Journey]] = {
    journeyRepository.findById(journeyId).map {
      case Some(journey) => Right(journey)
      case None => Left(s"Journey not found: $journeyId")
    }
  }
  
  /**
   * Get journey history for a card
   * Returns journeys in reverse chronological order
   * 
   * @param cardId The card identifier
   * @return List of journeys
   */
  def getJourneyHistory(cardId: CardId): IO[List[Journey]] = {
    journeyRepository.findByCardId(cardId)
  }
  
  /**
   * Get current in-progress journey for a card
   * 
   * @param cardId The card identifier
   * @return Option of in-progress journey
   */
  def getCurrentJourney(cardId: CardId): IO[Option[Journey]] = {
    journeyRepository.findInProgressJourney(cardId)
  }
  
  /**
   * Handle incomplete journey (when passenger doesn't tap out)
   * Applies penalty fare (maximum fare is already charged, so no additional charge)
   * 
   * @param journeyId The journey to mark as incomplete
   * @return Either error or updated journey
   */
  def markJourneyIncomplete(journeyId: JourneyId): IO[Either[String, Journey]] = {
    journeyRepository.findById(journeyId).flatMap {
      case None =>
        IO.pure(Left(s"Journey not found: $journeyId"))
        
      case Some(journey) =>
        if (journey.status != JourneyStatus.InProgress) {
          IO.pure(Left(s"Journey is not in progress: $journeyId"))
        } else {
          // Mark as incomplete with penalty fare (maximum fare already charged)
          val incompleteJourney = journey.markIncomplete(FareCalculator.maximumFare)
          journeyRepository.save(incompleteJourney).map(_ => Right(incompleteJourney))
        }
    }
  }
  
  /**
   * Get all in-progress journeys
   * Administrative function to find journeys that haven't been completed
   * 
   * @return List of in-progress journeys
   */
  def getAllInProgressJourneys(): IO[List[Journey]] = {
    journeyRepository.listAll().map(
      _.filter(_.status == JourneyStatus.InProgress)
    )
  }
  
  /**
   * Calculate fare between two stations (preview without making a journey)
   * Useful for showing users expected fare
   * 
   * @param from Starting station
   * @param to Destination station
   * @return Calculated fare
   */
  def previewFare(from: Station, to: Station): Money = {
    FareCalculator.calculateFare(from, to)
  }
}

object TapValidationService {
  /**
   * Create a TapValidationService with empty repository
   * Requires an existing WalletService
   */
  def create(walletService: WalletService): IO[TapValidationService] = {
    InMemoryJourneyRepository.empty.map { repo =>
      new TapValidationService(repo, walletService)
    }
  }
  
  /**
   * Create a TapValidationService with specific repositories
   */
  def withRepositories(
    journeyRepository: JourneyRepository,
    walletService: WalletService
  ): TapValidationService = {
    new TapValidationService(journeyRepository, walletService)
  }
}
