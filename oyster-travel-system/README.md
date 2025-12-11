# Oyster-Style Travel System

A comprehensive travel card management system implemented in Scala using functional programming paradigms. This system simulates the London Oyster card system, providing account management, card operations, wallet services, journey tracking, and operational tooling.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Database](#database)
- [Getting Started](#getting-started)
- [Module Structure](#module-structure)
- [Usage Examples](#usage-examples)
- [Building and Running](#building-and-running)
- [Testing](#testing)
- [Contributing](#contributing)

## 📚 Quick Reference Docs

### 🎯 Interview Preparation (Read These First!)
- **[START_HERE.md](START_HERE.md)** - 🎓 **Navigation hub - Start here for interview prep!**
- **[INTERVIEW_CHEATSHEET.md](INTERVIEW_CHEATSHEET.md)** - 🚀 **Quick cheat sheet for last-minute review (15 min)**
- **[INTERVIEW_PREP.md](INTERVIEW_PREP.md)** - 📖 **Comprehensive guide explaining "why" behind all architectural decisions (1-2 hours)**
- **[WHITEBOARD_GUIDE.md](WHITEBOARD_GUIDE.md)** - ✍️ **Diagrams you can draw on a whiteboard**

### 📚 Technical Documentation
- **[API_QUICK_REFERENCE.md](API_QUICK_REFERENCE.md)** - Complete API endpoint reference
- **[ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md)** - Detailed system architecture
- **[ERD.md](ERD.md)** - Database schema and relationships
- **[modules/api/README.md](modules/api/README.md)** - Play Framework API documentation

## 🎯 Overview

This project demonstrates a monolithic multi-module SBT (Scala Build Tool) project implementing an Oyster-style travel system. The system is built using functional programming principles with:

- **Immutable data structures** - All domain models are immutable
- **Pure functions** - Business logic implemented as pure functions without side effects
- **Effect management** - Using cats-effect IO for managing side effects
- **Type safety** - Strong typing to prevent errors at compile time
- **Algebraic data types** - Using sealed traits for exhaustive pattern matching

## ✨ Features

### Core Functionality

1. **Account Management**
   - Create customer accounts with email and name
   - Validate unique email addresses
   - Update account information
   - List all accounts

2. **Card Operations**
   - Order new travel cards
   - Activate pending cards
   - Block lost or stolen cards
   - Cancel cards permanently
   - Associate cards with accounts

3. **Wallet Services**
   - Create wallets for cards
   - Top-up with balance validation
   - Deduct fares automatically
   - Track transaction history
   - Enforce balance limits (max £500, min top-up £1, max top-up £100)

4. **Tap Validation**
   - Tap-in at stations with balance checking
   - Hold maximum fare on entry (£5.00)
   - Tap-out with actual fare calculation
   - Automatic refund of fare difference
   - Handle incomplete journeys (no tap-out)

5. **Fare Calculation**
   - Zone-based fare system
   - Intelligent fare calculation between zones
   - Minimum fare: £1.50
   - Maximum fare: £5.00 (for incomplete journeys)
   - Example fares:
     - Zone 1 to Zone 1: £2.50
     - Zone 1 to Zone 2: £3.00
     - Zone 1 to Zone 3: £3.50

6. **Operations & Monitoring**
   - System-wide statistics
   - Per-card usage statistics
   - Low balance alerts
   - Incomplete journey tracking
   - Administrative operations

## 🏗️ Architecture

The system follows a **multi-module monolithic architecture** with clear separation of concerns:

```
oyster-travel-system/
├── build.sbt                 # Root build configuration
├── project/
│   ├── build.properties      # SBT version
│   └── plugins.sbt           # SBT plugins (includes Play Framework)
├── database/                 # PostgreSQL database schema
│   ├── schema.sql           # Complete database schema
│   ├── docker-compose.yml   # Docker setup for PostgreSQL
│   ├── migrations/          # Database migration scripts
│   └── README.md            # Database documentation
├── ERD.md                    # Entity Relationship Diagram
└── modules/
    ├── domain/               # Core domain models and business rules
    ├── account-service/      # Account and card management
    ├── wallet-service/       # Wallet and transaction management
    ├── tap-validation/       # Journey and fare validation
    ├── operations/           # Monitoring and admin tools
    ├── demo/                 # Demo application
    └── api/                  # Play Framework REST API
```

### Module Dependencies

```
domain (no dependencies)
  ↑
  ├── account-service → domain
  ├── wallet-service → domain
  └── tap-validation → domain, wallet-service
      ↑
      ├── operations → all modules
      │   ↑
      │   ├── demo → all modules
      │   └── api → all modules (Play Framework REST API)
```

## 🗄️ Database

The system includes a complete PostgreSQL database schema for persistent storage.

### Database Features

- **Complete Schema** - Tables, indexes, views, and constraints
- **ERD Diagram** - Visual entity relationship diagram (see [ERD.md](ERD.md))
- **Seed Data** - Pre-populated zones and stations
- **Docker Support** - Easy local setup with Docker Compose
- **Migration Support** - Ready for Flyway, Liquibase, or golang-migrate

### Quick Database Setup

```bash
# Start PostgreSQL using Docker
cd database
docker-compose up -d

# The schema is automatically applied on first start
# Or apply manually:
docker exec -i oyster-postgres psql -U oyster -d oyster_db < schema.sql

# Connect to the database
docker exec -it oyster-postgres psql -U oyster -d oyster_db
```

### Database Tables

- **account** - Customer accounts
- **card** - Travel cards
- **wallet** - Card balances (one-to-one with card)
- **transaction** - Financial transaction history
- **journey** - Travel journeys (tap-in to tap-out)
- **station** - Transport stations
- **zone** - Transport zones (1-9)
- **station_zone** - Many-to-many station-zone relationships

**📖 Database Documentation:**
- [DATABASE_GUIDE.md](DATABASE_GUIDE.md) - Quick start guide
- [ERD.md](ERD.md) - Entity Relationship Diagram
- [database/README.md](database/README.md) - Complete reference
- [database/schema.sql](database/schema.sql) - PostgreSQL schema

## 🚀 Getting Started

### Prerequisites

- **JDK 11 or higher** - Java Development Kit
- **SBT 1.9.7 or higher** - Scala Build Tool
- **Scala 2.13.12** - Scala programming language
- **Docker** (optional) - For running PostgreSQL locally
- **PostgreSQL 12+** (optional) - If not using Docker

### Installation

1. **Install JDK**
   ```bash
   # On Ubuntu/Debian
   sudo apt-get install openjdk-11-jdk
   
   # On macOS with Homebrew
   brew install openjdk@11
   ```

2. **Install SBT**
   ```bash
   # On Ubuntu/Debian
   echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list
   curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add
   sudo apt-get update
   sudo apt-get install sbt
   
   # On macOS with Homebrew
   brew install sbt
   ```

3. **Clone and build the project**
   ```bash
   cd oyster-travel-system
   sbt compile
   ```

## 📦 Module Structure

### Domain Module

**Purpose**: Core business logic and domain models

**Key Components**:
- `ValueObjects.scala` - Type-safe wrappers for IDs and Money
- `Models.scala` - Station, Account, Card, Wallet entities
- `Journey.scala` - Journey tracking and status
- `FareCalculator.scala` - Fare calculation logic and business rules

**Key Concepts**:
```scala
// Value objects provide type safety
case class AccountId(value: UUID) extends AnyVal
case class Money(amount: BigDecimal) extends AnyVal

// Domain entities are immutable
case class Account(id: AccountId, email: String, name: String, createdAt: Timestamp)

// Algebraic data types for exhaustive matching
sealed trait CardStatus
object CardStatus {
  case object Active extends CardStatus
  case object Blocked extends CardStatus
  case object Cancelled extends CardStatus
  case object Pending extends CardStatus
}
```

### Account Service Module

**Purpose**: Account and card management operations

**Key Components**:
- `AccountService.scala` - Account CRUD operations
- `CardService.scala` - Card lifecycle management

**Usage**:
```scala
// Create account
accountService.createAccount(email = "user@example.com", name = "John Doe")

// Order and activate card
cardService.orderCard(accountId)
cardService.activateCard(cardId)
```

### Wallet Service Module

**Purpose**: Financial operations and transaction tracking

**Key Components**:
- `WalletService.scala` - Wallet operations and transaction history

**Usage**:
```scala
// Create wallet and top up
walletService.createWallet(cardId)
walletService.topUp(cardId, Money.fromDouble(20.00))

// Check balance
walletService.getBalance(cardId)

// View transaction history
walletService.getTransactionHistory(cardId)
```

### Tap Validation Module

**Purpose**: Journey management and fare processing

**Key Components**:
- `TapValidationService.scala` - Tap-in/tap-out handling

**Usage**:
```scala
// Start journey (tap-in)
tapService.tapIn(cardId, Station.KingsCross)

// End journey (tap-out)
tapService.tapOut(cardId, Station.Wimbledon)

// Preview fare
val fare = tapService.previewFare(Station.Holborn, Station.EarlsCourt)
```

### Operations Module

**Purpose**: System monitoring and administrative operations

**Key Components**:
- `MonitoringService.scala` - Statistics and reporting
- `AdminOperations.scala` - Administrative functions

**Usage**:
```scala
// Get system statistics
monitoringService.getSystemStatistics()

// Get card statistics
monitoringService.getCardStatistics(cardId)

// Find low balance cards
monitoringService.findLowBalanceCards()
```

### Demo Module

**Purpose**: Example application demonstrating all features

**Key Components**:
- `DemoApp.scala` - Complete demo showcasing system capabilities

### API Module

**Purpose**: REST API using Play Framework

**Key Components**:
- Controllers for all system operations (Account, Card, Wallet, Tap, Monitoring)
- JSON serialization/deserialization
- HTTP routing and request handling
- Integration with cats-effect IO services

**Usage**:
```bash
# Start the Play Framework server
sbt api/run

# Access the API
curl http://localhost:9000/
curl http://localhost:9000/health
```

**API Documentation**: See [modules/api/README.md](modules/api/README.md) for complete API reference

## 🔧 Building and Running

### Compile the Project

```bash
# Compile all modules
sbt compile

# Compile specific module
sbt domain/compile
sbt account-service/compile
```

### Run the Demo Application

```bash
# Run from SBT
sbt demo/run

# Or run directly after packaging
sbt demo/assembly
java -jar modules/demo/target/scala-2.13/demo-assembly-0.1.0-SNAPSHOT.jar
```

### Run the Play Framework API

```bash
# Start the API server (default port 9000)
sbt api/run

# Or specify a custom port
sbt "api/run -Dhttp.port=8080"

# The API will be available at:
# http://localhost:9000/
```

**API Endpoints:**
- `GET /` - API information
- `GET /health` - Health check
- `POST /api/accounts` - Create account
- `POST /api/cards` - Order card
- `POST /api/wallets/:cardId/topup` - Top up wallet
- `POST /api/tap/in` - Tap in at station
- `POST /api/tap/out` - Tap out at station
- `GET /api/monitoring/stats` - System statistics

See the [API README](modules/api/README.md) for complete endpoint documentation.

### Run Tests

```bash
# Run all tests
sbt test

# Run tests for specific module
sbt domain/test
sbt wallet-service/test

# Run with coverage
sbt clean coverage test coverageReport
```

### Interactive SBT Shell

```bash
# Start SBT shell
sbt

# Inside shell
compile          # Compile all projects
test             # Run all tests
demo/run         # Run demo application
api/run          # Run Play Framework API
clean            # Clean build artifacts
reload           # Reload build configuration
```

## 🧪 Testing

The project uses ScalaTest for testing. Each module includes comprehensive unit tests.

```scala
// Example test structure
class FareCalculatorSpec extends AnyFlatSpec with Matchers {
  "FareCalculator" should "calculate correct fare for Zone 1 to Zone 1" in {
    val fare = FareCalculator.calculateFare(Station.Holborn, Station.KingsCross)
    fare shouldBe Money.fromDouble(2.50)
  }
}
```

## 📚 Key Functional Programming Concepts

### Immutability

All data structures are immutable. Operations return new instances:

```scala
val wallet = Wallet.create(cardId)
val updatedWallet = wallet.topUp(Money.fromDouble(20.00))
// Original wallet unchanged
```

### Pure Functions

Functions have no side effects and always return the same output for the same input:

```scala
// Pure function - no side effects
def calculateFare(from: Station, to: Station): Money = {
  // Deterministic calculation
}
```

### Effect Management with IO

Side effects (database access, network calls) are wrapped in IO:

```scala
// IO describes an effect, doesn't execute it
def save(account: Account): IO[Unit] = IO {
  // Database operation
}

// Chain operations
val program = for {
  account <- accountService.createAccount(email, name)
  card <- cardService.orderCard(account.id)
  wallet <- walletService.createWallet(card.id)
} yield wallet
```

### Either for Error Handling

Business logic errors use Either instead of exceptions:

```scala
def topUp(cardId: CardId, amount: Money): IO[Either[String, Wallet]] = {
  if (amount < MinTopUpAmount) 
    IO.pure(Left("Amount too small"))
  else 
    IO.pure(Right(updatedWallet))
}
```

### Algebraic Data Types

Sealed traits enable exhaustive pattern matching:

```scala
sealed trait JourneyStatus
object JourneyStatus {
  case object InProgress extends JourneyStatus
  case object Completed extends JourneyStatus
  case object Incomplete extends JourneyStatus
}

// Compiler ensures all cases are handled
journey.status match {
  case InProgress => // handle
  case Completed => // handle
  case Incomplete => // handle
}
```

## 🤝 Contributing

This project demonstrates functional programming in Scala. Key principles to follow:

1. **Maintain immutability** - Never mutate data structures
2. **Keep functions pure** - No side effects in business logic
3. **Use IO for effects** - Wrap all side effects in IO
4. **Prefer Either over exceptions** - For business logic errors
5. **Add comprehensive comments** - Explain functional concepts for learners
6. **Write tests** - Ensure correctness and prevent regressions

## 📖 Learning Resources

- [Cats Effect Documentation](https://typelevel.org/cats-effect/)
- [Scala Functional Programming](https://docs.scala-lang.org/overviews/scala-book/functional-programming.html)
- [Domain-Driven Design](https://www.domainlanguage.com/ddd/)

## 📄 License

This project is provided as-is for educational and demonstration purposes.

## 👥 Contact

For questions or feedback about this implementation, please refer to the repository issues.
