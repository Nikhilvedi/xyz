# ARCHITECTURE.md

## Oyster Travel System - Architecture Documentation

### System Overview

The Oyster Travel System is a monolithic multi-module application built with functional programming principles. It simulates a transport card system like London's Oyster card.

### Design Principles

#### 1. Functional Programming

**Immutability**
- All domain models are immutable (case classes)
- Operations return new instances rather than modifying state
- Benefits: Thread-safe, predictable, easier to reason about

**Pure Functions**
- Business logic implemented as pure functions
- Same input always produces same output
- No hidden dependencies or side effects
- Benefits: Testable, composable, cacheable

**Effect Management**
- Side effects (I/O, state changes) wrapped in `cats.effect.IO`
- IO is lazy - describes computation without executing it
- Composable using flatMap/for-comprehensions
- Benefits: Explicit effects, easier testing, better resource management

#### 2. Domain-Driven Design

**Value Objects**
- Primitives wrapped in type-safe containers (AccountId, Money, Zone)
- Prevents mixing up different types of IDs
- Enforces domain constraints at compile time

**Entities**
- Account, Card, Wallet, Journey
- Identity-based equality
- Rich behavior encapsulated within entities

**Aggregates**
- Journey aggregate includes tap-in/tap-out
- Wallet aggregate includes balance and transactions
- Clear boundaries maintain consistency

**Repositories**
- Abstract data access behind interfaces
- In-memory implementations for demo
- Easy to swap for database implementations

#### 3. Layered Architecture

```
┌─────────────────────────────────────┐
│         Demo Application            │  ← User interface / Examples
├─────────────────────────────────────┤
│     Operations & Monitoring         │  ← System management
├─────────────────────────────────────┤
│  ┌──────────┬──────────┬──────────┐ │
│  │ Account  │  Wallet  │   Tap    │ │  ← Service Layer
│  │ Service  │ Service  │Validation│ │
│  └──────────┴──────────┴──────────┘ │
├─────────────────────────────────────┤
│         Domain Models               │  ← Core Business Logic
│  (Entities, Value Objects, Rules)  │
└─────────────────────────────────────┘
```

### Module Structure

#### Domain Module (Core)

**Purpose**: Pure business logic with no dependencies

**Components**:
- `ValueObjects.scala`: Type-safe wrappers (AccountId, CardId, Money, Zone)
- `Models.scala`: Core entities (Account, Card, Station, Wallet)
- `Journey.scala`: Journey lifecycle and status
- `FareCalculator.scala`: Fare calculation algorithms

**Key Design Decisions**:
- No I/O operations - all pure functions
- All validation in smart constructors
- Algebraic data types (sealed traits) for exhaustive matching
- No dependency on other modules

#### Account Service Module

**Purpose**: Account and card lifecycle management

**Dependencies**: Domain

**Components**:
- `AccountService.scala`: Account CRUD operations
- `CardService.scala`: Card ordering, activation, blocking

**Key Design Decisions**:
- Repository pattern for data access
- IO for effect management
- Either for business logic errors
- Separation of concerns (service vs repository)

#### Wallet Service Module

**Purpose**: Financial operations

**Dependencies**: Domain

**Components**:
- `WalletService.scala`: Top-up, deduction, balance management

**Key Design Decisions**:
- Immutable transaction history
- Atomic balance updates using Ref
- Validation before state changes
- Clear audit trail through transactions

#### Tap Validation Module

**Purpose**: Journey management and fare processing

**Dependencies**: Domain, Wallet Service

**Components**:
- `TapValidationService.scala`: Tap-in/out handling

**Key Design Decisions**:
- Hold maximum fare on tap-in
- Calculate and refund on tap-out
- State machine for journey status
- Coordination with wallet service

#### Operations Module

**Purpose**: System monitoring and administration

**Dependencies**: All other modules

**Components**:
- `MonitoringService.scala`: Statistics and reporting
- `AdminOperations.scala`: Administrative functions

**Key Design Decisions**:
- Read-only operations for monitoring
- Aggregation across all services
- Efficient queries for common reports

### Data Flow

#### Creating an Account and Journey

```
User Request
    ↓
AccountService.createAccount
    ↓
Account.create (validation)
    ↓
AccountRepository.save (IO)
    ↓
CardService.orderCard
    ↓
Card.create + CardRepository.save
    ↓
WalletService.createWallet
    ↓
Wallet.create + WalletRepository.save
    ↓
WalletService.topUp
    ↓
Wallet.topUp + Transaction.create
    ↓
TapValidationService.tapIn
    ↓
Journey.start + WalletService.deductFare
    ↓
TapValidationService.tapOut
    ↓
FareCalculator.calculateFare + WalletService.topUp (refund)
    ↓
Journey.complete
```

### Error Handling Strategy

#### Two Layers of Errors

1. **Technical Errors** (IO failures)
   - Database connection failures
   - Network errors
   - Resource exhaustion
   - Handled by IO's error channel
   - Can retry or fail gracefully

2. **Business Errors** (Domain violations)
   - Insufficient balance
   - Invalid card status
   - Duplicate account
   - Returned as Either[String, A]
   - Client handles explicitly

#### Example Pattern

```scala
def operation(): IO[Either[String, Result]] = {
  // Technical error handling by IO
  repository.get().flatMap { data =>
    // Business logic validation
    if (isValid(data)) {
      IO.pure(Right(result))
    } else {
      IO.pure(Left("Business rule violation"))
    }
  }
}
```

### Concurrency Model

- **Ref** for atomic state updates
- **IO** for sequential composition
- **Parallel** for concurrent operations
- Thread-safe by design (immutability)

### Testing Strategy

#### Unit Tests
- Test pure functions in isolation
- No mocking needed for domain logic
- Fast and reliable

#### Integration Tests
- Test service interactions
- Use in-memory repositories
- Test IO composition

#### Property-Based Tests
- Use ScalaCheck for invariants
- Test fare calculation properties
- Verify business rules hold

### Performance Considerations

#### Current Implementation
- In-memory repositories (fast but not persistent)
- Synchronous operations
- Suitable for demo and development

#### Production Enhancements
- Replace repositories with database implementations
- Add caching for fare calculations
- Batch operations for bulk updates
- Connection pooling
- Async processing for non-critical operations

### Security Considerations

1. **Input Validation**: All at domain boundary
2. **Type Safety**: Prevents many errors at compile time
3. **Immutability**: Prevents unauthorized mutations
4. **Audit Trail**: All transactions logged
5. **Balance Limits**: Prevent fraud/abuse

### Extensibility Points

#### Adding New Features

1. **New Station**: Add to Station companion object
2. **New Fare Rule**: Modify FareCalculator
3. **New Card Type**: Extend CardStatus sealed trait
4. **New Transaction Type**: Extend TransactionType sealed trait

#### Replacing Components

1. **Database**: Implement repository traits with DB access
2. **External Payment**: Add payment gateway service
3. **Real-time Updates**: Add event publishing

### Functional Programming Patterns Used

1. **Algebraic Data Types**: Sealed traits for sum types
2. **Smart Constructors**: Validation at creation
3. **Type Classes**: Cats instances for domain types
4. **Effect Systems**: IO for managing side effects
5. **Reader Pattern**: Service dependency injection
6. **Repository Pattern**: Abstract data access
7. **Error Handling**: Either for expected errors

### Key Takeaways

1. **Separation of Concerns**: Clear module boundaries
2. **Testability**: Pure functions easy to test
3. **Type Safety**: Compiler catches many errors
4. **Immutability**: Easier to reason about state
5. **Composability**: Small functions compose into larger programs
6. **Explicit Effects**: IO makes side effects visible
