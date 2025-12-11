package controllers

import javax.inject._
import play.api.mvc._
import play.api.libs.json._
import scala.concurrent.{ExecutionContext, Future}
import cats.effect.IO
import cats.effect.unsafe.implicits.global
import com.oyster.tap.TapValidationService
import com.oyster.domain.{CardId, Station}
import models.JsonFormats._
import java.util.UUID

/**
 * TapController - REST API for tap-in/tap-out operations
 * Handles journey management and fare calculation
 */
@Singleton
class TapController @Inject()(
  val controllerComponents: ControllerComponents,
  tapService: TapValidationService
)(implicit ec: ExecutionContext) extends BaseController {
  
  private def ioToFuture[A](io: IO[A]): Future[A] = Future(io.unsafeRunSync())
  
  /**
   * Helper to get station by name
   */
  private def getStationByName(name: String): Option[Station] = {
    Station.allStations.find(_.name.equalsIgnoreCase(name))
  }
  
  /**
   * Tap in at a station
   * POST /api/tap/in
   * Body: {"cardId": "uuid", "stationName": "Holborn"}
   */
  def tapIn() = Action.async(parse.json) { implicit request =>
    request.body.validate[TapInRequest].fold(
      errors => Future.successful(BadRequest(Json.obj("error" -> JsError.toJson(errors)))),
      tapInReq => {
        try {
          val cardId = CardId(UUID.fromString(tapInReq.cardId))
          getStationByName(tapInReq.stationName) match {
            case Some(station) =>
              ioToFuture(tapService.tapIn(cardId, station)).map {
                case Right(journey) => Ok(Json.toJson(journey))
                case Left(error) => BadRequest(Json.obj("error" -> error))
              }
            case None =>
              Future.successful(BadRequest(Json.obj("error" -> s"Station not found: ${tapInReq.stationName}")))
          }
        } catch {
          case _: IllegalArgumentException => 
            Future.successful(BadRequest(Json.obj("error" -> "Invalid card ID format")))
        }
      }
    )
  }
  
  /**
   * Tap out at a station
   * POST /api/tap/out
   * Body: {"cardId": "uuid", "stationName": "Earl's Court"}
   */
  def tapOut() = Action.async(parse.json) { implicit request =>
    request.body.validate[TapOutRequest].fold(
      errors => Future.successful(BadRequest(Json.obj("error" -> JsError.toJson(errors)))),
      tapOutReq => {
        try {
          val cardId = CardId(UUID.fromString(tapOutReq.cardId))
          getStationByName(tapOutReq.stationName) match {
            case Some(station) =>
              ioToFuture(tapService.tapOut(cardId, station)).map {
                case Right(journey) => Ok(Json.toJson(journey))
                case Left(error) => BadRequest(Json.obj("error" -> error))
              }
            case None =>
              Future.successful(BadRequest(Json.obj("error" -> s"Station not found: ${tapOutReq.stationName}")))
          }
        } catch {
          case _: IllegalArgumentException => 
            Future.successful(BadRequest(Json.obj("error" -> "Invalid card ID format")))
        }
      }
    )
  }
  
  /**
   * Preview fare between two stations
   * GET /api/tap/preview?from=Holborn&to=EarlsCourt
   */
  def previewFare(from: String, to: String) = Action { implicit request =>
    (getStationByName(from), getStationByName(to)) match {
      case (Some(fromStation), Some(toStation)) =>
        val fare = tapService.previewFare(fromStation, toStation)
        Ok(Json.obj(
          "from" -> fromStation.name,
          "to" -> toStation.name,
          "fare" -> fare.amount
        ))
      case (None, _) =>
        BadRequest(Json.obj("error" -> s"Station not found: $from"))
      case (_, None) =>
        BadRequest(Json.obj("error" -> s"Station not found: $to"))
    }
  }
  
  /**
   * Get journey history for a card
   * GET /api/journeys/:cardId
   */
  def getJourneyHistory(cardId: String) = Action.async { implicit request =>
    try {
      val cid = CardId(UUID.fromString(cardId))
      ioToFuture(tapService.getJourneyHistory(cid)).map { journeys =>
        Ok(Json.toJson(journeys))
      }
    } catch {
      case _: IllegalArgumentException => 
        Future.successful(BadRequest(Json.obj("error" -> "Invalid card ID format")))
    }
  }
}
