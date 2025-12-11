package models

import play.api.libs.json._
import play.api.libs.functional.syntax._
import com.oyster.domain._
import java.util.UUID
import java.sql.Timestamp

/**
 * JSON Format definitions for the API
 * These formats enable automatic serialization/deserialization between
 * JSON and domain models using Play JSON library
 */
object JsonFormats {
  
  // Basic type formats
  implicit val uuidFormat: Format[UUID] = new Format[UUID] {
    def reads(json: JsValue): JsResult[UUID] = json match {
      case JsString(s) => 
        try JsSuccess(UUID.fromString(s))
        catch { case _: IllegalArgumentException => JsError("Invalid UUID") }
      case _ => JsError("Expected UUID string")
    }
    def writes(uuid: UUID): JsValue = JsString(uuid.toString)
  }
  
  implicit val timestampFormat: Format[Timestamp] = new Format[Timestamp] {
    def reads(json: JsValue): JsResult[Timestamp] = json match {
      case JsNumber(n) => JsSuccess(new Timestamp(n.toLong))
      case JsString(s) => 
        try JsSuccess(Timestamp.valueOf(s))
        catch { case _: IllegalArgumentException => JsError("Invalid timestamp") }
      case _ => JsError("Expected timestamp")
    }
    def writes(ts: Timestamp): JsValue = JsNumber(ts.getTime)
  }
  
  // Value object formats
  implicit val moneyFormat: Format[Money] = new Format[Money] {
    def reads(json: JsValue): JsResult[Money] = json match {
      case JsNumber(n) => JsSuccess(Money.fromDouble(n.toDouble))
      case _ => JsError("Expected number for Money")
    }
    def writes(money: Money): JsValue = JsNumber(money.amount)
  }
  
  implicit val accountIdFormat: Format[AccountId] = new Format[AccountId] {
    def reads(json: JsValue): JsResult[AccountId] = 
      uuidFormat.reads(json).map(AccountId.apply)
    def writes(id: AccountId): JsValue = uuidFormat.writes(id.value)
  }
  
  implicit val cardIdFormat: Format[CardId] = new Format[CardId] {
    def reads(json: JsValue): JsResult[CardId] = 
      uuidFormat.reads(json).map(CardId.apply)
    def writes(id: CardId): JsValue = uuidFormat.writes(id.value)
  }
  
  implicit val journeyIdFormat: Format[JourneyId] = new Format[JourneyId] {
    def reads(json: JsValue): JsResult[JourneyId] = 
      uuidFormat.reads(json).map(JourneyId.apply)
    def writes(id: JourneyId): JsValue = uuidFormat.writes(id.value)
  }
  
  implicit val transactionIdFormat: Format[TransactionId] = new Format[TransactionId] {
    def reads(json: JsValue): JsResult[TransactionId] = 
      uuidFormat.reads(json).map(TransactionId.apply)
    def writes(id: TransactionId): JsValue = uuidFormat.writes(id.value)
  }
  
  implicit val zoneFormat: Format[Zone] = new Format[Zone] {
    def reads(json: JsValue): JsResult[Zone] = json match {
      case JsNumber(n) => JsSuccess(Zone(n.toInt))
      case _ => JsError("Expected number for Zone")
    }
    def writes(zone: Zone): JsValue = JsNumber(zone.number)
  }
  
  // Station format
  implicit val stationFormat: Format[Station] = Json.format[Station]
  
  // Enum formats
  implicit val cardStatusFormat: Format[CardStatus] = new Format[CardStatus] {
    def reads(json: JsValue): JsResult[CardStatus] = json match {
      case JsString("Active") => JsSuccess(CardStatus.Active)
      case JsString("Blocked") => JsSuccess(CardStatus.Blocked)
      case JsString("Cancelled") => JsSuccess(CardStatus.Cancelled)
      case JsString("Pending") => JsSuccess(CardStatus.Pending)
      case _ => JsError("Invalid card status")
    }
    def writes(status: CardStatus): JsValue = JsString(status.toString)
  }
  
  implicit val journeyStatusFormat: Format[JourneyStatus] = new Format[JourneyStatus] {
    def reads(json: JsValue): JsResult[JourneyStatus] = json match {
      case JsString("InProgress") => JsSuccess(JourneyStatus.InProgress)
      case JsString("Completed") => JsSuccess(JourneyStatus.Completed)
      case JsString("Incomplete") => JsSuccess(JourneyStatus.Incomplete)
      case _ => JsError("Invalid journey status")
    }
    def writes(status: JourneyStatus): JsValue = JsString(status.toString)
  }
  
  implicit val transactionTypeFormat: Format[TransactionType] = new Format[TransactionType] {
    def reads(json: JsValue): JsResult[TransactionType] = json match {
      case JsString("TopUp") => JsSuccess(TransactionType.TopUp)
      case JsString("FareDeduction") => JsSuccess(TransactionType.FareDeduction)
      case JsString("FareRefund") => JsSuccess(TransactionType.FareRefund)
      case _ => JsError("Invalid transaction type")
    }
    def writes(txType: TransactionType): JsValue = JsString(txType.toString)
  }
  
  // Domain entity formats
  implicit val accountFormat: Format[Account] = Json.format[Account]
  implicit val cardFormat: Format[Card] = Json.format[Card]
  implicit val walletFormat: Format[Wallet] = Json.format[Wallet]
  implicit val journeyFormat: Format[Journey] = Json.format[Journey]
  implicit val transactionFormat: Format[Transaction] = Json.format[Transaction]
  
  // Request/Response DTOs
  case class CreateAccountRequest(email: String, name: String)
  implicit val createAccountRequestFormat: Format[CreateAccountRequest] = Json.format[CreateAccountRequest]
  
  case class UpdateAccountRequest(name: Option[String], email: Option[String])
  implicit val updateAccountRequestFormat: Format[UpdateAccountRequest] = Json.format[UpdateAccountRequest]
  
  case class OrderCardRequest(accountId: String)
  implicit val orderCardRequestFormat: Format[OrderCardRequest] = Json.format[OrderCardRequest]
  
  case class CreateWalletRequest(cardId: String)
  implicit val createWalletRequestFormat: Format[CreateWalletRequest] = Json.format[CreateWalletRequest]
  
  case class TopUpRequest(amount: Double)
  implicit val topUpRequestFormat: Format[TopUpRequest] = Json.format[TopUpRequest]
  
  case class TapInRequest(cardId: String, stationName: String)
  implicit val tapInRequestFormat: Format[TapInRequest] = Json.format[TapInRequest]
  
  case class TapOutRequest(cardId: String, stationName: String)
  implicit val tapOutRequestFormat: Format[TapOutRequest] = Json.format[TapOutRequest]
  
  case class ErrorResponse(error: String)
  implicit val errorResponseFormat: Format[ErrorResponse] = Json.format[ErrorResponse]
  
  case class SuccessResponse(message: String)
  implicit val successResponseFormat: Format[SuccessResponse] = Json.format[SuccessResponse]
}
