package controllers

import javax.inject._
import play.api.mvc._
import play.api.libs.json.Json

/**
 * HomeController - Basic endpoints for the API
 * Provides index and health check endpoints
 */
@Singleton
class HomeController @Inject()(val controllerComponents: ControllerComponents) 
  extends BaseController {
  
  /**
   * Index endpoint - provides API information
   */
  def index() = Action { implicit request: Request[AnyContent] =>
    Ok(Json.obj(
      "name" -> "Oyster Travel System API",
      "version" -> "1.0.0",
      "description" -> "REST API for the Oyster-style travel card system",
      "endpoints" -> Json.obj(
        "accounts" -> "/api/accounts",
        "cards" -> "/api/cards",
        "wallets" -> "/api/wallets",
        "tap" -> "/api/tap",
        "monitoring" -> "/api/monitoring"
      )
    ))
  }
  
  /**
   * Health check endpoint
   */
  def health() = Action { implicit request: Request[AnyContent] =>
    Ok(Json.obj(
      "status" -> "healthy",
      "timestamp" -> System.currentTimeMillis()
    ))
  }
}
