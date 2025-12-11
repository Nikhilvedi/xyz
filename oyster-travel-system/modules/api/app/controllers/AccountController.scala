package controllers

import javax.inject._
import play.api.mvc._
import play.api.libs.json._
import scala.concurrent.{ExecutionContext, Future}
import cats.effect.IO
import cats.effect.unsafe.implicits.global
import com.oyster.account.AccountService
import com.oyster.domain.AccountId
import models.JsonFormats._
import java.util.UUID

/**
 * AccountController - REST API for account management
 * Handles HTTP requests for account operations and converts between
 * Play Framework's Future-based API and cats-effect IO
 */
@Singleton
class AccountController @Inject()(
  val controllerComponents: ControllerComponents,
  accountService: AccountService
)(implicit ec: ExecutionContext) extends BaseController {
  
  /**
   * Helper to convert IO to Future for Play Framework
   */
  private def ioToFuture[A](io: IO[A]): Future[A] = {
    Future(io.unsafeRunSync())
  }
  
  /**
   * Create a new account
   * POST /api/accounts
   * Body: {"email": "user@example.com", "name": "John Doe"}
   */
  def createAccount() = Action.async(parse.json) { implicit request =>
    request.body.validate[CreateAccountRequest].fold(
      errors => Future.successful(BadRequest(Json.obj("error" -> JsError.toJson(errors)))),
      createReq => {
        ioToFuture(accountService.createAccount(createReq.email, createReq.name)).map {
          case Right(account) => Created(Json.toJson(account))
          case Left(error) => BadRequest(Json.obj("error" -> error))
        }
      }
    )
  }
  
  /**
   * Get an account by ID
   * GET /api/accounts/:id
   */
  def getAccount(id: String) = Action.async { implicit request =>
    try {
      val accountId = AccountId(UUID.fromString(id))
      ioToFuture(accountService.getAccount(accountId)).map {
        case Right(account) => Ok(Json.toJson(account))
        case Left(error) => NotFound(Json.obj("error" -> error))
      }
    } catch {
      case _: IllegalArgumentException => 
        Future.successful(BadRequest(Json.obj("error" -> "Invalid account ID format")))
    }
  }
  
  /**
   * List all accounts
   * GET /api/accounts
   */
  def listAccounts() = Action.async { implicit request =>
    ioToFuture(accountService.listAllAccounts()).map { accounts =>
      Ok(Json.toJson(accounts))
    }
  }
  
  /**
   * Update an account
   * PUT /api/accounts/:id
   * Body: {"name": "New Name", "email": "new@example.com"}
   */
  def updateAccount(id: String) = Action.async(parse.json) { implicit request =>
    try {
      val accountId = AccountId(UUID.fromString(id))
      request.body.validate[UpdateAccountRequest].fold(
        errors => Future.successful(BadRequest(Json.obj("error" -> JsError.toJson(errors)))),
        updateReq => {
          ioToFuture(accountService.updateAccount(accountId, updateReq.name, updateReq.email)).map {
            case Right(account) => Ok(Json.toJson(account))
            case Left(error) => BadRequest(Json.obj("error" -> error))
          }
        }
      )
    } catch {
      case _: IllegalArgumentException => 
        Future.successful(BadRequest(Json.obj("error" -> "Invalid account ID format")))
    }
  }
}
