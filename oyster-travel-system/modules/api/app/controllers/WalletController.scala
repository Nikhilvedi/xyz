package controllers

import javax.inject._
import play.api.mvc._
import play.api.libs.json._
import scala.concurrent.{ExecutionContext, Future}
import cats.effect.IO
import cats.effect.unsafe.implicits.global
import com.oyster.wallet.WalletService
import com.oyster.domain.{CardId, Money}
import models.JsonFormats._
import java.util.UUID

/**
 * WalletController - REST API for wallet operations
 * Handles wallet creation, top-ups, and balance queries
 */
@Singleton
class WalletController @Inject()(
  val controllerComponents: ControllerComponents,
  walletService: WalletService
)(implicit ec: ExecutionContext) extends BaseController {
  
  private def ioToFuture[A](io: IO[A]): Future[A] = Future(io.unsafeRunSync())
  
  /**
   * Create a wallet for a card
   * POST /api/wallets
   * Body: {"cardId": "uuid"}
   */
  def createWallet() = Action.async(parse.json) { implicit request =>
    request.body.validate[CreateWalletRequest].fold(
      errors => Future.successful(BadRequest(Json.obj("error" -> JsError.toJson(errors)))),
      createReq => {
        try {
          val cardId = CardId(UUID.fromString(createReq.cardId))
          ioToFuture(walletService.createWallet(cardId)).map {
            case Right(wallet) => Created(Json.toJson(wallet))
            case Left(error) => BadRequest(Json.obj("error" -> error))
          }
        } catch {
          case _: IllegalArgumentException => 
            Future.successful(BadRequest(Json.obj("error" -> "Invalid card ID format")))
        }
      }
    )
  }
  
  /**
   * Get wallet for a card
   * GET /api/wallets/:cardId
   */
  def getWallet(cardId: String) = Action.async { implicit request =>
    try {
      val cid = CardId(UUID.fromString(cardId))
      ioToFuture(walletService.getWallet(cid)).map {
        case Right(wallet) => Ok(Json.toJson(wallet))
        case Left(error) => NotFound(Json.obj("error" -> error))
      }
    } catch {
      case _: IllegalArgumentException => 
        Future.successful(BadRequest(Json.obj("error" -> "Invalid card ID format")))
    }
  }
  
  /**
   * Top up a wallet
   * POST /api/wallets/:cardId/topup
   * Body: {"amount": 20.00}
   */
  def topUp(cardId: String) = Action.async(parse.json) { implicit request =>
    try {
      val cid = CardId(UUID.fromString(cardId))
      request.body.validate[TopUpRequest].fold(
        errors => Future.successful(BadRequest(Json.obj("error" -> JsError.toJson(errors)))),
        topUpReq => {
          ioToFuture(walletService.topUp(cid, Money.fromDouble(topUpReq.amount))).map {
            case Right(wallet) => Ok(Json.toJson(wallet))
            case Left(error) => BadRequest(Json.obj("error" -> error))
          }
        }
      )
    } catch {
      case _: IllegalArgumentException => 
        Future.successful(BadRequest(Json.obj("error" -> "Invalid card ID format")))
    }
  }
  
  /**
   * Get balance for a card
   * GET /api/wallets/:cardId/balance
   */
  def getBalance(cardId: String) = Action.async { implicit request =>
    try {
      val cid = CardId(UUID.fromString(cardId))
      ioToFuture(walletService.getBalance(cid)).map {
        case Right(balance) => Ok(Json.obj("balance" -> balance.amount))
        case Left(error) => NotFound(Json.obj("error" -> error))
      }
    } catch {
      case _: IllegalArgumentException => 
        Future.successful(BadRequest(Json.obj("error" -> "Invalid card ID format")))
    }
  }
  
  /**
   * Get transaction history for a card
   * GET /api/wallets/:cardId/transactions
   */
  def getTransactions(cardId: String) = Action.async { implicit request =>
    try {
      val cid = CardId(UUID.fromString(cardId))
      ioToFuture(walletService.getTransactionHistory(cid)).map { transactions =>
        Ok(Json.toJson(transactions))
      }
    } catch {
      case _: IllegalArgumentException => 
        Future.successful(BadRequest(Json.obj("error" -> "Invalid card ID format")))
    }
  }
}
