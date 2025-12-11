# 🎯 Interview Preparation Guide
## Oyster Travel System - Architectural Decisions Explained

> **Purpose**: This guide answers the "why" behind key architectural decisions in the Oyster Travel System. Perfect for interview preparation where you need to explain and justify your design choices.

---

## Table of Contents

1. [Why Multi-Module SBT?](#1-why-multi-module-sbt)
2. [Why Play Framework?](#2-why-play-framework)
3. [Why Cats Effect?](#3-why-cats-effect)
4. [Why This ERD Design?](#4-why-this-erd-design)
5. [Why Functional Programming?](#5-why-functional-programming)
6. [Why This Module Structure?](#6-why-this-module-structure)
7. [Common Interview Questions](#7-common-interview-questions)

---

## 1. Why Multi-Module SBT?

### The Question
*"Why did you choose a multi-module monolithic architecture instead of a single module or microservices?"*

### The Answer

**Multi-module SBT provides:**

#### 1.1 Clear Separation of Concerns
```
domain/              ← Pure business logic (no dependencies)
account-service/     ← Account management (depends on domain)
wallet-service/      ← Financial operations (depends on domain)
tap-validation/      ← Journey logic (depends on domain + wallet)
operations/          ← Monitoring (depends on all)
api/                 ← REST API (depends on all)
demo/                ← Examples (depends on all)
```

**Benefits:**
- **Enforced Dependencies**: SBT won't compile if you try to create circular dependencies
- **Independent Testing**: Each module can be tested in isolation
- **Easier to Reason About**: Small, focused modules are easier to understand
- **Team Scalability**: Different teams can own different modules

#### 1.2 Monolithic vs Microservices Trade-offs

**Why NOT microservices (yet)?**
- **Complexity**: No need for service discovery, API gateways, distributed transactions
- **Development Speed**: Faster to develop and test locally
- **Simpler Deployment**: Single artifact to deploy
- **Shared Code**: Easy to share domain models without duplicating code
- **Transaction Integrity**: ACID transactions work within a single database

**Why NOT a single module?**
- **Build Times**: Only rebuild changed modules
- **Code Organization**: Clear boundaries prevent spaghetti code
- **Dependency Management**: Explicit module dependencies prevent coupling
- **Future Flexibility**: Easy to extract modules into services if needed

#### 1.3 Evolution Path

```
Current State:        Future if Needed:
┌─────────────┐      ┌──────────┐  ┌──────────┐
│ Monolithic  │  →   │ Service  │  │ Service  │
│ Multi-module│      │ Account  │  │ Wallet   │
│ Application │      └──────────┘  └──────────┘
└─────────────┘            ↓             ↓
                     ┌─────────────────────┐
                     │   Shared Domain     │
                     └─────────────────────┘
```

**Key Point**: *"We chose multi-module monolithic because it gives us microservices-like benefits (modularity, clear boundaries) without the operational complexity. If scale requires it, we can extract modules into services later."*

---

## 2. Why Play Framework?

### The Question
*"Why did you choose Play Framework for the API layer? Why not Akka HTTP, http4s, or Spring Boot?"*

### The Answer

**Play Framework was chosen because:**

#### 2.1 Industry Standard for Scala
- **Mature**: Battle-tested in production at companies like LinkedIn, Verizon, Samsung
- **Large Ecosystem**: Rich plugin ecosystem and community support
- **Well-Documented**: Excellent documentation and learning resources
- **Career Relevant**: Knowing Play is valuable for Scala jobs

#### 2.2 Developer Productivity
- **Type-Safe Routes**: Routes are checked at compile time
  ```scala
  // routes file
  GET  /api/accounts/:id    controllers.AccountController.getAccount(id: String)
  
  // Compiler catches typos and mismatches!
  ```

- **Built-in JSON Handling**: Play JSON makes serialization easy
  ```scala
  implicit val accountFormat = Json.format[Account]
  Ok(Json.toJson(account))  // Automatic JSON conversion
  ```

- **Hot Reload**: Changes are visible immediately in development
- **Built-in Testing**: Great testing support with `ScalaTest + Play`

#### 2.3 Performance Characteristics
- **Async/Non-blocking**: Built on Akka, handles many concurrent requests
- **Reactive Streams**: Backpressure support for streaming
- **Stateless**: Easy to scale horizontally

#### 2.4 Comparison with Alternatives

| Framework    | Pros                           | Cons                              |
|-------------|--------------------------------|-----------------------------------|
| **Play**    | Full-featured, productive      | Some learning curve               |
| Akka HTTP   | Fine-grained control           | More boilerplate, lower-level     |
| http4s      | Pure FP, cats-effect native    | Smaller community, more FP-heavy  |
| Spring Boot | Java ecosystem, huge community | Not idiomatic Scala, less type-safe |

**Key Point**: *"Play Framework gives us the best balance of productivity, performance, and industry relevance. It's the 'Rails of Scala' - convention over configuration with great defaults."*

---

## 3. Why Cats Effect?

### The Question
*"Why did you use Cats Effect for effect management? Why not just Future, ZIO, or plain Scala?"*

### The Answer

**Cats Effect provides principled functional effect management:**

#### 3.1 The Problem with Future
```scala
// Future executes immediately (eager)
val future = Future {
  println("This runs immediately!")
  riskyDatabaseCall()
}

// Problems:
// - Can't compose without executing
// - Can't retry or handle errors declaratively
// - Tight coupling to ExecutionContext
```

#### 3.2 The IO Monad Solution
```scala
// IO is lazy - describes computation without running it
val io = IO {
  println("This doesn't run until explicitly executed")
  riskyDatabaseCall()
}

// Benefits:
val program = for {
  account <- accountService.createAccount(email, name)
  card <- cardService.orderCard(account.id)
  wallet <- walletService.createWallet(card.id)
} yield wallet

// Composable, testable, retryable
program.handleErrorWith(e => IO.pure(Left(e.getMessage)))
```

#### 3.3 Key Benefits

**1. Referential Transparency**
```scala
// These mean the same thing
val x = IO.pure(42)
val y = IO.pure(42)
// x == y ✓

// But with Future:
val a = Future { ... }
val b = Future { ... }
// a != b (different executions)
```

**2. Explicit Effects**
```scala
// Clear what has side effects
def pureCalculation(a: Int, b: Int): Int = a + b
def effectfulOperation(id: String): IO[Account] = accountRepo.get(id)
```

**3. Resource Safety**
```scala
// Guaranteed cleanup even on errors
IO.bracket(acquireConnection)(
  connection => queryDatabase(connection)
)(connection => IO(connection.close()))
```

**4. Testability**
```scala
// Easy to test without executing effects
def createAccount(email: String): IO[Account] = IO(...)

// In tests:
val testIO = createAccount("test@example.com")
// No side effects yet! Can test composition logic.
```

#### 3.4 Why Not ZIO?

| Aspect        | Cats Effect                    | ZIO                          |
|--------------|--------------------------------|------------------------------|
| Ecosystem    | Integrates with Cats, Circe   | Own ecosystem (ZIO JSON, etc)|
| Learning     | Builds on Cats knowledge      | New concepts (R, E, A)       |
| Community    | Larger (TypeLevel)            | Growing but smaller          |
| Complexity   | One main type: IO[A]          | Three type params: ZIO[R,E,A]|

**Key Point**: *"Cats Effect gives us the benefits of pure functional programming - referential transparency, composability, and testability - while integrating seamlessly with the Cats ecosystem that's standard in Scala FP."*

---

## 4. Why This ERD Design?

### The Question
*"Why did you design the database schema this way? Why these relationships and constraints?"*

### The Answer

**The ERD reflects real-world business rules and ensures data integrity:**

#### 4.1 Core Entity Relationships

**1. ACCOUNT → CARD (1:Many)**
```
Why: A customer can have multiple cards (personal, business, backup)
Example: Alice has 3 cards - one active, one blocked, one backup
```

**2. CARD → WALLET (1:1)**
```
Why: Each card has exactly one balance
Benefits:
- Simple balance lookups (no joins needed)
- Atomic balance updates
- Clear ownership of money
```

**3. CARD → TRANSACTION (1:Many)**
```
Why: Audit trail of all financial operations
Benefits:
- Complete transaction history
- Fraud detection
- Dispute resolution
- Regulatory compliance
```

**4. CARD → JOURNEY (1:Many)**
```
Why: Track all travel history per card
Benefits:
- Usage analytics
- Fare dispute resolution
- Incomplete journey detection
```

**5. STATION ↔ ZONE (Many:Many)**
```
Why: Some stations span multiple zones
Example: Earl's Court is in both Zone 1 and Zone 2
Benefits:
- Flexible fare calculation
- Reflects real London Underground system
```

#### 4.2 Key Design Decisions

**Decision 1: Separate TRANSACTION table instead of embedded in WALLET**

```sql
-- Option 1: Embedded (NOT chosen)
wallet {
  card_id, 
  balance, 
  transactions TEXT  -- JSON array
}

-- Option 2: Separate table (CHOSEN)
transaction {
  id, 
  card_id, 
  type, 
  amount, 
  timestamp
}
```

**Why separate?**
- ✓ Efficient queries (indexed, no JSON parsing)
- ✓ Atomic operations (no row locks on wallet)
- ✓ Proper relational integrity
- ✓ Easy to add new transaction types
- ✓ Better performance for history queries

**Decision 2: `status` as VARCHAR instead of separate status table**

```sql
-- Simple enum check constraint
status VARCHAR NOT NULL CHECK (status IN ('Active', 'Blocked', 'Cancelled', 'Pending'))
```

**Why not a status table?**
- ✓ Statuses are fixed and unlikely to change
- ✓ No need for i18n (internal status)
- ✓ Simpler queries (no joins)
- ✓ Better performance
- Note: If statuses needed descriptions, rules, or frequently changed, we'd use a table

**Decision 3: `balance_after` in TRANSACTION table**

```sql
transaction {
  amount NUMERIC,
  balance_after NUMERIC  -- Current balance after this transaction
}
```

**Why redundant data?**
- ✓ Fast balance reconstruction (no need to sum all transactions)
- ✓ Audit trail verification (detect tampering)
- ✓ Point-in-time balance queries
- ✓ Data integrity checks (balance_after should match wallet.balance)

**Decision 4: NULL allowed for `journey.end_station_id`**

```sql
journey {
  end_station_id VARCHAR NULL,  -- NULL if journey incomplete
  tap_out_time TIMESTAMP NULL
}
```

**Why nullable?**
- ✓ Represents in-progress journeys (tapped in, not yet tapped out)
- ✓ Enables incomplete journey detection
- ✓ Natural state modeling (NULL = unknown/pending)
- Alternative would require separate tables for complete/incomplete journeys (more complex)

#### 4.3 Constraints Enforce Business Rules

```sql
-- Balance limits (prevents abuse)
CHECK (balance >= 0 AND balance <= 500)

-- Unique email (one account per email)
UNIQUE (email)

-- Referential integrity (no orphaned records)
FOREIGN KEY (account_id) REFERENCES account(id) ON DELETE RESTRICT

-- Valid zones only
CHECK (zone.number BETWEEN 1 AND 9)
```

#### 4.4 Index Strategy

**Indexes created for:**
```sql
-- Frequently queried foreign keys
CREATE INDEX idx_card_account_id ON card(account_id);
CREATE INDEX idx_transaction_card_id ON transaction(card_id);

-- Common filter columns
CREATE INDEX idx_card_status ON card(status);
CREATE INDEX idx_journey_status ON journey(status);

-- Time-based queries
CREATE INDEX idx_transaction_timestamp ON transaction(timestamp);
CREATE INDEX idx_journey_tap_in_time ON journey(tap_in_time);
```

**Why these indexes?**
- ✓ Support common query patterns
- ✓ Foreign key lookups are fast
- ✓ Enable efficient monitoring queries (low balance, incomplete journeys)

**Key Point**: *"The ERD design balances normalization with performance. We normalize to avoid redundancy (separate transaction table), but denormalize strategically (balance_after) for auditability and performance. Every relationship and constraint maps to a real business rule."*

---

## 5. Why Functional Programming?

### The Question
*"Why use functional programming? Wouldn't OOP be simpler?"*

### The Answer

**FP provides guarantees that make systems more reliable:**

#### 5.1 Immutability Prevents Bugs

```scala
// OOP (Mutable)
class Wallet(var balance: Money) {
  def topUp(amount: Money): Unit = {
    balance = balance + amount  // What if another thread reads balance here?
  }
}

// FP (Immutable)
case class Wallet(balance: Money) {
  def topUp(amount: Money): Wallet = {
    Wallet(balance + amount)  // Returns new wallet, thread-safe
  }
}
```

**Benefits:**
- ✓ **Thread-safe by default**: No race conditions
- ✓ **Time travel debugging**: Keep old states
- ✓ **Easier testing**: No hidden state mutations
- ✓ **Fearless refactoring**: Can't break by modifying state

#### 5.2 Pure Functions Are Predictable

```scala
// Pure function
def calculateFare(from: Station, to: Station): Money = {
  val zones = (from.zones ++ to.zones).distinct.size
  zones match {
    case 1 => Money(2.50)
    case 2 => Money(3.00)
    case _ => Money(3.50)
  }
}

// Same input = same output, every time
// No hidden dependencies, no side effects
// Easy to test, cache, parallelize
```

#### 5.3 Types Catch Errors at Compile Time

```scala
// Type-safe IDs prevent mixing up entities
case class AccountId(value: UUID) extends AnyVal
case class CardId(value: UUID) extends AnyVal

def getAccount(id: AccountId): IO[Account]
def getCard(id: CardId): IO[Card]

// This won't compile:
getAccount(cardId)  // Type error! ✓

// Whereas with strings:
def getAccount(id: String): Future[Account]
def getCard(id: String): Future[Card]
getAccount(cardId)  // Compiles but wrong at runtime ✗
```

#### 5.4 Algebraic Data Types Enable Exhaustive Matching

```scala
sealed trait CardStatus
object CardStatus {
  case object Active extends CardStatus
  case object Blocked extends CardStatus
  case object Cancelled extends CardStatus
  case object Pending extends CardStatus
}

// Compiler enforces handling all cases
def processCard(status: CardStatus): String = status match {
  case Active => "Allow"
  case Blocked => "Deny"
  case Cancelled => "Deny"
  // If we forget Pending, compiler error!
}
```

#### 5.5 Real-World Impact

**Bug Prevention:**
- Type errors caught at compile time (not production!)
- Race conditions eliminated by immutability
- Null pointer exceptions impossible (Option/Either)
- Forgot to handle case? Compiler tells you

**Testability:**
```scala
// Pure function test - no mocking needed
test("calculateFare for Zone 1 to Zone 1") {
  val fare = FareCalculator.calculateFare(holborn, kingsCross)
  fare shouldBe Money(2.50)
}

// IO test - compose without executing
test("createAccount composition") {
  val program = for {
    account <- createAccount("test@example.com", "Test User")
    card <- orderCard(account.id)
  } yield card
  
  // Test composition logic without database
}
```

**Key Point**: *"Functional programming isn't about being academic - it's about using the compiler to prevent bugs. Immutability eliminates race conditions, pure functions are predictable, and strong types catch errors before production."*

---

## 6. Why This Module Structure?

### The Question
*"Why did you organize modules this way? Why not group by feature or by layer?"*

### The Answer

**The module structure follows Domain-Driven Design principles:**

#### 6.1 Module Dependency Graph

```
              ┌──────────┐
              │   demo   │ (Example application)
              └────┬─────┘
                   │
              ┌────▼─────┐
              │operations│ (System monitoring)
              └────┬─────┘
       ┌───────┬──┴──┬────────┐
       ▼       ▼     ▼        ▼
┌──────────┬──────┬─────────┬───┐
│ account  │wallet│   tap   │api│ (Services)
│ service  │service│validation│  │
└────┬─────┴───┬──┴─────┬───┴───┘
     │         │        │
     └────┬────┴────┬───┘
          ▼         ▼
      ┌─────────────┐
      │   domain    │ (Core business logic)
      └─────────────┘
```

#### 6.2 Design Principles Applied

**1. Domain Module: Pure Business Logic**
```scala
modules/domain/
├── ValueObjects.scala  // AccountId, CardId, Money, Zone
├── Models.scala        // Account, Card, Wallet, Station
├── Journey.scala       // Journey entity
└── FareCalculator.scala // Pure fare calculation
```

**Why at the bottom?**
- ✓ No dependencies = no coupling
- ✓ Pure domain knowledge
- ✓ Reusable across all services
- ✓ Easy to test in isolation

**2. Service Modules: Single Responsibility**
```
account-service/   ← Account & Card operations
wallet-service/    ← Financial operations
tap-validation/    ← Journey & fare processing
```

**Why separate?**
- ✓ Each service has one clear purpose
- ✓ Can be developed independently
- ✓ Clear ownership boundaries
- ✓ Easy to extract into microservices later

**3. Operations Module: System-Wide Concerns**
```scala
operations/
├── MonitoringService.scala  // Cross-service stats
└── AdminOperations.scala    // Admin functions
```

**Why at the top?**
- ✓ Depends on all services (needs full visibility)
- ✓ Cross-cutting concerns (monitoring, admin)
- ✓ Clear separation from business logic

**4. API Module: External Interface**
```scala
api/
├── controllers/  // HTTP handlers
├── models/       // JSON DTOs
└── conf/         // Routes, config
```

**Why separate?**
- ✓ Business logic not coupled to HTTP
- ✓ Can swap to gRPC/GraphQL without touching services
- ✓ API concerns (JSON, routing) isolated

#### 6.3 Alternative Structures (Not Chosen)

**Alternative 1: Layered Architecture**
```
src/
├── controllers/
├── services/
├── repositories/
└── models/
```
**Why not?**
- ✗ No module boundaries (can access anything)
- ✗ Harder to extract to microservices
- ✗ Business logic spread across layers
- ✗ Tight coupling between layers

**Alternative 2: Feature-Based**
```
src/
├── account/
│   ├── controller/
│   ├── service/
│   └── repository/
├── wallet/
└── journey/
```
**Why not?**
- ✗ Duplicates infrastructure code
- ✗ Harder to share domain models
- ✗ More complex dependency management
- Note: This works well for microservices!

#### 6.4 Benefits Realized

**Development Benefits:**
- Fast builds (only rebuild changed modules)
- Parallel development (teams work on different modules)
- Clear interfaces (module dependencies explicit)
- Easy onboarding (start with domain, work outward)

**Testing Benefits:**
- Unit test domain without services
- Integration test services without API
- Mock fewer things (clear boundaries)

**Evolution Benefits:**
- Add new service by depending on domain
- Extract module to microservice (already modular)
- Swap implementations (repository pattern)

**Key Point**: *"The module structure reflects how the business works: domain at the core (pure business rules), services around it (use cases), and infrastructure at the edges (API, database). This is the 'ports and adapters' or 'hexagonal architecture' pattern."*

---

## 7. Common Interview Questions

### Q1: "How would you scale this system?"

**Answer:**
"There are several scaling strategies depending on the bottleneck:

**Horizontal Scaling (Stateless API):**
```
Load Balancer
    ↓
┌────┴────┬────────┬────────┐
│ API 1   │ API 2  │ API 3  │
└────┬────┴────┬───┴────┬───┘
     └──────┬──┘         │
         Database        └→ Cache
```
- Add more API instances behind load balancer
- Stateless services enable this easily
- Session in database/Redis, not in memory

**Database Scaling:**
- Read replicas for read-heavy operations (balance queries)
- Connection pooling (manage connections efficiently)
- Caching layer (Redis for hot data like balances)
- Sharding by account_id if single DB becomes bottleneck

**Async Processing:**
```
API → Message Queue → Workers
         (RabbitMQ)    ↓
                   Background jobs
                   (reports, notifications)
```

**Microservices (if needed):**
- Extract account-service → Account Microservice
- Extract wallet-service → Wallet Microservice
- Shared event bus for communication
- API Gateway pattern"

---

### Q2: "How would you handle high concurrency?"

**Answer:**
"Multiple strategies:

**1. Database Optimistic Locking:**
```sql
UPDATE wallet 
SET balance = balance + 10, version = version + 1
WHERE card_id = ? AND version = ?
```
- If version changed, transaction failed (retry)

**2. Pessimistic Locking (for critical operations):**
```sql
SELECT * FROM wallet WHERE card_id = ? FOR UPDATE
-- Lock row until transaction commits
```

**3. Cats Effect Ref for In-Memory State:**
```scala
Ref[IO].of(balance).flatMap { ref =>
  ref.updateAndGet(_ + amount)  // Atomic update
}
```

**4. Message Queue for Write Operations:**
- All balance changes go through queue
- Single consumer processes sequentially
- No race conditions possible

**Current implementation uses Ref (in-memory) which is already thread-safe. For production, I'd add database locking."**

---

### Q3: "What about security?"

**Answer:**
"Several layers:

**1. Input Validation:**
- All at domain boundary (smart constructors)
- Email validation, balance limits, zone ranges
- Prevent SQL injection (parameterized queries)

**2. Authentication/Authorization (to add):**
```scala
// Current: No auth (demo)
// Production:
POST /api/accounts
Authorization: Bearer <JWT token>

// Verify:
// - User authenticated
// - User authorized for operation
// - Rate limiting applied
```

**3. Audit Trail:**
- All transactions logged (who, what, when)
- Immutable transaction history
- Can detect fraud patterns

**4. Balance Limits:**
- Max £500 (prevent money laundering)
- Min/max top-up (prevent abuse)

**5. HTTPS Only:**
- All API traffic encrypted
- Sensitive data (PII) encrypted at rest

**6. Secure Defaults:**
- Cards start as Pending (not Active)
- Failed transactions don't lose money (Either error handling)
- No raw SQL (use prepared statements/ORM)"**

---

### Q4: "How would you test this?"

**Answer:**
"Multiple testing levels:

**1. Unit Tests (Pure Functions):**
```scala
test("FareCalculator: Zone 1 to Zone 1") {
  calculateFare(holborn, kingsCross) shouldBe Money(2.50)
}
```
- Fast, no mocking needed
- Test business logic in isolation

**2. Integration Tests (Services):**
```scala
test("Create account and order card") {
  for {
    account <- accountService.createAccount(email, name)
    card <- cardService.orderCard(account.id)
  } yield {
    card.accountId shouldBe account.id
    card.status shouldBe Pending
  }
}
```
- Test service interactions
- Use in-memory repositories

**3. API Tests:**
```scala
test("POST /api/accounts returns 201") {
  val request = FakeRequest(POST, "/api/accounts")
    .withJsonBody(Json.obj("email" -> "test@example.com"))
  
  val result = route(app, request).get
  status(result) shouldBe CREATED
}
```

**4. Property-Based Tests:**
```scala
property("Fare is always between min and max") {
  forAll { (from: Station, to: Station) =>
    val fare = calculateFare(from, to)
    fare.amount should be >= 1.50
    fare.amount should be <= 5.00
  }
}
```

**5. Load Tests:**
```bash
# Apache Bench
ab -n 10000 -c 100 http://localhost:9000/api/accounts
```

**Current implementation has unit tests for domain logic. I'd add integration and API tests for production."**

---

### Q5: "What would you improve?"

**Answer:**
"Several areas:

**Immediate improvements:**
1. Add comprehensive tests (currently just unit tests)
2. Implement proper error handling (more detailed error types)
3. Add authentication/authorization
4. Database connection pooling
5. Caching layer for frequently accessed data

**Medium-term:**
1. Event sourcing for audit trail
2. CQRS (separate read/write models)
3. Async job processing (reports, notifications)
4. API versioning
5. Rate limiting

**Long-term:**
1. Microservices if scale requires
2. Real-time updates (WebSocket for balance changes)
3. Machine learning for fraud detection
4. Multi-currency support
5. Mobile SDK

**Key philosophy**: *Start simple (monolith), add complexity only when needed (microservices). Current design allows evolution without rewrite."**

---

## 8. Quick Reference Card

### 30-Second Pitch
*"This is a travel card system like London's Oyster card, built in Scala using functional programming. It's a multi-module monolith with Play Framework for the API, Cats Effect for effect management, and PostgreSQL for persistence. The architecture prioritizes type safety, testability, and clear separation of concerns."*

### Key Numbers
- **7 modules**: domain + 6 service/application modules
- **8 database tables**: Full relational schema
- **40+ REST endpoints**: Complete CRUD operations
- **5 core services**: Account, Card, Wallet, Tap, Monitoring
- **3 key FP concepts**: Immutability, Pure Functions, IO Monad

### Technology Choices Summary

| Decision | Choice | Reason |
|----------|--------|--------|
| **Build Tool** | Multi-module SBT | Modular monolith, enforced dependencies |
| **Language** | Scala 2.13 | Type safety, FP support, JVM ecosystem |
| **Web Framework** | Play Framework | Industry standard, productive, type-safe |
| **Effects** | Cats Effect | Principled FP, composable, testable |
| **Database** | PostgreSQL | ACID, robust, relational integrity |
| **Testing** | ScalaTest | Standard Scala testing framework |

### One-Liner Answers

**Why SBT multi-module?**
*"Modular monolith: microservices benefits without operational complexity"*

**Why Play Framework?**
*"Industry standard for Scala, productive, great defaults"*

**Why Cats Effect?**
*"Pure FP with composable effects and referential transparency"*

**Why this ERD?**
*"Normalized for integrity, strategically denormalized for performance"*

**Why Functional Programming?**
*"Compiler-enforced correctness: immutability prevents bugs, types catch errors"*

---

## 9. Presentation Tips

### For Whiteboard Interviews

1. **Start with the big picture** (3-layer architecture)
2. **Draw 4 core entities** (Account → Card → Wallet, Journey)
3. **Show one complete flow** (Create account → Top up → Journey)
4. **Highlight key decisions** (Why multi-module? Why FP? Why this schema?)

### For Technical Deep-Dives

1. **Code walkthrough** (Show FareCalculator as pure function example)
2. **Architecture walkthrough** (Explain module dependencies)
3. **Database walkthrough** (Explain ERD relationships)
4. **Demo** (Live API calls showing full flow)

### For Behavioral Questions

- **Challenge**: "How did you handle conflicting requirements?"
  - *Answer*: "Balanced normalization vs performance in ERD design"

- **Learning**: "What did you learn building this?"
  - *Answer*: "Cats Effect's IO monad - how to manage effects purely"

- **Trade-offs**: "What compromises did you make?"
  - *Answer*: "In-memory repositories for demo vs database for production"

---

## 10. Final Checklist

Before your interview, make sure you can explain:

- [ ] **Why multi-module SBT?** (Modularity without microservices complexity)
- [ ] **Why Play Framework?** (Industry standard, productive)
- [ ] **Why Cats Effect?** (Pure FP, composable effects)
- [ ] **Why this ERD design?** (Business rules as constraints)
- [ ] **Module dependency graph** (Domain → Services → Operations/API)
- [ ] **One complete user flow** (Account → Card → Wallet → Journey)
- [ ] **Key FP concepts used** (Immutability, Pure functions, IO monad)
- [ ] **How to scale the system** (Horizontal scaling, caching, async)
- [ ] **How to test the system** (Unit, integration, property-based)
- [ ] **What you'd improve** (Auth, tests, caching, async jobs)

---

**Good luck with your interview! 🚀**

*Remember: Interviewers value clear thinking and trade-off awareness more than perfect solutions. Be ready to discuss alternatives and explain why you chose your approach.*
