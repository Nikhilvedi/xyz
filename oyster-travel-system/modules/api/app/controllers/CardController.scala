package controllers

import javax.inject._
import play.api.mvc._
import play.api.libs.json._
import scala.concurrent.{ExecutionContext, Future}
import cats.effect.IO
import cats.effect.unsafe.implicits.global
import com.oyster.account.CardService
import com.oyster.domain.{AccountId, CardId}
import models.JsonFormats._
import java.util.UUID

/**
 * CardController - REST API for card management
 * Handles card ordering, activation, blocking, and cancellation
 */
@Singleton
class CardController @Inject()(
  val controllerComponents: ControllerComponents,
  cardService: CardService
)(implicit ec: ExecutionContext) extends BaseController {
  
  private def ioToFuture[A](io: IO[A]): Future[A] = Future(io.unsafeRunSync())
  
  /**
   * Order a new card
   * POST /api/cards
   * Body: {"accountId": "uuid"}
   */
  def orderCard() = Action.async(parse.json) { implicit request =>
    request.body.validate[OrderCardRequest].fold(
      errors => Future.successful(BadRequest(Json.obj("error" -> JsError.toJson(errors)))),
      orderReq => {
        try {
          val accountId = AccountId(UUID.fromString(orderReq.accountId))
          ioToFuture(cardService.orderCard(accountId)).map {
            case Right(card) => Created(Json.toJson(card))
            case Left(error) => BadRequest(Json.obj("error" -> error))
          }
        } catch {
          case _: IllegalArgumentException => 
            Future.successful(BadRequest(Json.obj("error" -> "Invalid account ID format")))
        }
      }
    )
  }
  
  /**
   * Get a card by ID
   * GET /api/cards/:id
   */
  def getCard(id: String) = Action.async { implicit request =>
    try {
      val cardId = CardId(UUID.fromString(id))
      ioToFuture(cardService.getCard(cardId)).map {
        case Right(card) => Ok(Json.toJson(card))
        case Left(error) => NotFound(Json.obj("error" -> error))
      }
    } catch {
      case _: IllegalArgumentException => 
        Future.successful(BadRequest(Json.obj("error" -> "Invalid card ID format")))
    }
  }
  
  /**
   * List all cards
   * GET /api/cards
   */
  def listCards() = Action.async { implicit request =>
    ioToFuture(cardService.listAllCards()).map { cards =>
      Ok(Json.toJson(cards))
    }
  }
  
  /**
   * Activate a card
   * POST /api/cards/:id/activate
   */
  def activateCard(id: String) = Action.async { implicit request =>
    try {
      val cardId = CardId(UUID.fromString(id))
      ioToFuture(cardService.activateCard(cardId)).map {
        case Right(card) => Ok(Json.toJson(card))
        case Left(error) => BadRequest(Json.obj("error" -> error))
      }
    } catch {
      case _: IllegalArgumentException => 
        Future.successful(BadRequest(Json.obj("error" -> "Invalid card ID format")))
    }
  }
  
  /**
   * Block a card
   * POST /api/cards/:id/block
   */
  def blockCard(id: String) = Action.async { implicit request =>
    try {
      val cardId = CardId(UUID.fromString(id))
      ioToFuture(cardService.blockCard(cardId)).map {
        case Right(card) => Ok(Json.toJson(card))
        case Left(error) => BadRequest(Json.obj("error" -> error))
      }
    } catch {
      case _: IllegalArgumentException => 
        Future.successful(BadRequest(Json.obj("error" -> "Invalid card ID format")))
    }
  }
  
  /**
   * Cancel a card
   * POST /api/cards/:id/cancel
   */
  def cancelCard(id: String) = Action.async { implicit request =>
    try {
      val cardId = CardId(UUID.fromString(id))
      ioToFuture(cardService.cancelCard(cardId)).map {
        case Right(card) => Ok(Json.toJson(card))
        case Left(error) => BadRequest(Json.obj("error" -> error))
      }
    } catch {
      case _: IllegalArgumentException => 
        Future.successful(BadRequest(Json.obj("error" -> "Invalid card ID format")))
    }
  }
}
