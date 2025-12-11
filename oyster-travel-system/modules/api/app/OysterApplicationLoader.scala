import play.api._
import play.api.ApplicationLoader.Context
import play.api.routing.Router
import play.filters.HttpFiltersComponents
import controllers._
import cats.effect.IO
import cats.effect.unsafe.implicits.global
import com.oyster.account.{AccountService, CardService, InMemoryAccountRepository, InMemoryCardRepository}
import com.oyster.wallet.{WalletService, InMemoryWalletRepository, InMemoryTransactionRepository}
import com.oyster.tap.{TapValidationService, InMemoryJourneyRepository}
import com.oyster.operations.{MonitoringService, AdminOperations}
import router.Routes

/**
 * OysterApplicationLoader - Custom application loader for Play Framework
 * 
 * This loader initializes all the services and controllers with proper
 * dependency injection. It bridges the gap between Play Framework's
 * component-based architecture and our functional cats-effect services.
 */
class OysterApplicationLoader extends ApplicationLoader {
  def load(context: Context): Application = {
    LoggerConfigurator(context.environment.classLoader).foreach {
      _.configure(context.environment)
    }
    new OysterComponents(context).application
  }
}

/**
 * OysterComponents - Application components container
 * 
 * This class wires together all the dependencies for the application.
 * It creates repositories, services, and controllers, ensuring proper
 * initialization order.
 */
class OysterComponents(context: Context) 
  extends BuiltInComponentsFromContext(context) 
  with HttpFiltersComponents 
  with play.filters.cors.CORSComponents {
  
  // Initialize repositories and services
  // These are initialized synchronously at application startup
  private val accountRepo = InMemoryAccountRepository.empty.unsafeRunSync()
  private val cardRepo = InMemoryCardRepository.empty.unsafeRunSync()
  private val walletRepo = InMemoryWalletRepository.empty.unsafeRunSync()
  private val txRepo = InMemoryTransactionRepository.empty.unsafeRunSync()
  private val journeyRepo = InMemoryJourneyRepository.empty.unsafeRunSync()
  
  // Create services
  private val accountServiceInstance = AccountService.withRepository(accountRepo)
  private val cardServiceInstance = CardService.withRepositories(cardRepo, accountRepo)
  private val walletServiceInstance = WalletService.withRepositories(walletRepo, txRepo)
  private val tapServiceInstance = TapValidationService.withRepositories(journeyRepo, walletServiceInstance)
  private val monitoringServiceInstance = MonitoringService.create(
    accountServiceInstance,
    cardServiceInstance,
    walletServiceInstance,
    tapServiceInstance
  )
  
  // Create controllers
  lazy val homeController = new HomeController(controllerComponents)
  lazy val accountController = new AccountController(controllerComponents, accountServiceInstance)(executionContext)
  lazy val cardController = new CardController(controllerComponents, cardServiceInstance)(executionContext)
  lazy val walletController = new WalletController(controllerComponents, walletServiceInstance)(executionContext)
  lazy val tapController = new TapController(controllerComponents, tapServiceInstance)(executionContext)
  lazy val monitoringController = new MonitoringController(controllerComponents, monitoringServiceInstance)(executionContext)
  
  // Router configuration
  lazy val router: Router = new Routes(
    httpErrorHandler,
    homeController,
    accountController,
    cardController,
    walletController,
    tapController,
    monitoringController
  )
  
  // Log successful initialization
  Logger(getClass).info("Oyster Travel System API initialized successfully")
}
