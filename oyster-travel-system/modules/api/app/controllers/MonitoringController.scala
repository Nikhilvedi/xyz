package controllers

import javax.inject._
import play.api.mvc._
import play.api.libs.json._
import scala.concurrent.{ExecutionContext, Future}
import cats.effect.IO
import cats.effect.unsafe.implicits.global
import com.oyster.operations.MonitoringService
import com.oyster.domain.CardId
import models.JsonFormats._
import java.util.UUID

/**
 * MonitoringController - REST API for system monitoring
 * Provides endpoints for system statistics and operational insights
 */
@Singleton
class MonitoringController @Inject()(
  val controllerComponents: ControllerComponents,
  monitoringService: MonitoringService
)(implicit ec: ExecutionContext) extends BaseController {
  
  private def ioToFuture[A](io: IO[A]): Future[A] = Future(io.unsafeRunSync())
  
  /**
   * Get system-wide statistics
   * GET /api/monitoring/stats
   */
  def getSystemStats() = Action.async { implicit request =>
    ioToFuture(monitoringService.getSystemStatistics()).map { stats =>
      Ok(Json.obj(
        "summary" -> stats.summary,
        "totalAccounts" -> stats.totalAccounts,
        "totalCards" -> stats.totalCards,
        "activeCards" -> stats.activeCards,
        "totalJourneys" -> stats.totalJourneys,
        "completedJourneys" -> stats.completedJourneys,
        "incompleteJourneys" -> stats.incompleteJourneys,
        "totalTransactions" -> stats.totalTransactions,
        "totalRevenue" -> stats.totalRevenue.amount
      ))
    }
  }
  
  /**
   * Get statistics for a specific card
   * GET /api/monitoring/cards/:id/stats
   */
  def getCardStats(id: String) = Action.async { implicit request =>
    try {
      val cardId = CardId(UUID.fromString(id))
      ioToFuture(monitoringService.getCardStatistics(cardId)).map {
        case Right(stats) => Ok(Json.obj(
          "summary" -> stats.summary,
          "cardId" -> stats.cardId.value.toString,
          "totalJourneys" -> stats.totalJourneys,
          "completedJourneys" -> stats.completedJourneys,
          "incompleteJourneys" -> stats.incompleteJourneys,
          "totalSpent" -> stats.totalSpent.amount,
          "currentBalance" -> stats.currentBalance.amount
        ))
        case Left(error) => NotFound(Json.obj("error" -> error))
      }
    } catch {
      case _: IllegalArgumentException => 
        Future.successful(BadRequest(Json.obj("error" -> "Invalid card ID format")))
    }
  }
  
  /**
   * Get cards with low balance
   * GET /api/monitoring/low-balance
   */
  def getLowBalanceCards() = Action.async { implicit request =>
    ioToFuture(monitoringService.findLowBalanceCards()).map { cards =>
      val result = cards.map { case (card, balance) =>
        Json.obj(
          "cardId" -> card.id.value.toString,
          "accountId" -> card.accountId.value.toString,
          "balance" -> balance.amount,
          "status" -> card.status.toString
        )
      }
      Ok(Json.toJson(result))
    }
  }
  
  /**
   * Get incomplete journeys
   * GET /api/monitoring/incomplete-journeys
   */
  def getIncompleteJourneys() = Action.async { implicit request =>
    ioToFuture(monitoringService.findIncompleteJourneys()).map { journeys =>
      Ok(Json.toJson(journeys))
    }
  }
}
