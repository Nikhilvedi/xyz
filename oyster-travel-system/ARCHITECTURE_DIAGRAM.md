# System Architecture Diagram

```
┌───────────────────────────────────────────────────────────────────────────┐
│                         OYSTER TRAVEL SYSTEM                              │
│                    Monolithic Multi-Module Architecture                   │
└───────────────────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────────────────┐
│                              DEMO MODULE                                  │
│                                                                           │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │ DemoApp (IOApp)                                                 │    │
│  │  - Account Creation Demo                                        │    │
│  │  - Card Ordering Demo                                           │    │
│  │  - Wallet Top-up Demo                                           │    │
│  │  - Journey Demo (Tap-in/Tap-out)                               │    │
│  │  - Monitoring Demo                                              │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└───────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌───────────────────────────────────────────────────────────────────────────┐
│                          OPERATIONS MODULE                                │
│                                                                           │
│  ┌──────────────────────────┐    ┌──────────────────────────────────┐   │
│  │ MonitoringService        │    │ AdminOperations                  │   │
│  │  - System Statistics     │    │  - Cleanup Stale Journeys        │   │
│  │  - Card Statistics       │    │  - Block Multiple Cards          │   │
│  │  - Low Balance Detection │    │  - System Integrity Check        │   │
│  │  - Account Reports       │    │                                  │   │
│  └──────────────────────────┘    └──────────────────────────────────┘   │
└───────────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    ▼               ▼               ▼
┌──────────────────────┐  ┌──────────────────┐  ┌──────────────────────┐
│  ACCOUNT SERVICE     │  │  WALLET SERVICE  │  │  TAP VALIDATION      │
│                      │  │                  │  │                      │
│ AccountService       │  │ WalletService    │  │ TapValidationService │
│  - createAccount     │  │  - createWallet  │  │  - tapIn             │
│  - getAccount        │  │  - topUp         │  │  - tapOut            │
│  - updateAccount     │  │  - deductFare    │  │  - getJourney        │
│  - listAccounts      │  │  - getBalance    │  │  - previewFare       │
│                      │  │  - getHistory    │  │  - markIncomplete    │
│ CardService          │  │                  │  │                      │
│  - orderCard         │  │ TransactionRepo  │  │ JourneyRepository    │
│  - activateCard      │  │  - save          │  │  - save              │
│  - blockCard         │  │  - findByCard    │  │  - findInProgress    │
│  - validateForTravel │  │                  │  │  - findByCard        │
│                      │  │ WalletRepository │  │                      │
│ AccountRepository    │  │  - save          │  └──────────────────────┘
│  - save              │  │  - findByCard    │            │
│  - findById          │  │                  │            │
│  - findByEmail       │  └──────────────────┘            │
│                      │            │                     │
│ CardRepository       │            │                     │
│  - save              │            │                     │
│  - findById          │            │                     │
│  - findByAccount     │            │                     │
└──────────────────────┘            │                     │
          │                         │                     │
          └─────────────────────────┼─────────────────────┘
                                    ▼
┌───────────────────────────────────────────────────────────────────────────┐
│                            DOMAIN MODULE                                  │
│                        (Pure Business Logic)                              │
│                                                                           │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │ VALUE OBJECTS (Type-safe wrappers)                               │   │
│  │  AccountId, CardId, Money, Zone, StationId, TransactionId        │   │
│  │  JourneyId, Timestamp                                            │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                                                                           │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │ ENTITIES (Domain models)                                          │   │
│  │  Account, Card, Station, Wallet, Journey, Transaction            │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                                                                           │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │ ALGEBRAIC DATA TYPES (Sealed traits)                             │   │
│  │  CardStatus, JourneyStatus, TransactionType                      │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                                                                           │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │ BUSINESS LOGIC (Pure functions)                                  │   │
│  │  FareCalculator - Zone-based fare calculation                    │   │
│  │  FareRules - Business rules and validation                       │   │
│  └──────────────────────────────────────────────────────────────────┘   │
└───────────────────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════════════════
                              DATA FLOW EXAMPLE
═══════════════════════════════════════════════════════════════════════════════

    USER JOURNEY: Complete Travel Flow
    
    ┌──────────────────┐
    │ 1. Create Account│
    └────────┬─────────┘
             │ AccountService.createAccount("alice@example.com", "Alice")
             ▼
    ┌──────────────────┐
    │ Account Created  │ AccountId: 550e8400-e29b-41d4-a716-446655440000
    └────────┬─────────┘
             │
             │ CardService.orderCard(accountId)
             ▼
    ┌──────────────────┐
    │ 2. Order Card    │
    └────────┬─────────┘
             │ CardService.activateCard(cardId)
             ▼
    ┌──────────────────┐
    │ Card Activated   │ CardId: 123e4567-e89b-12d3-a456-426614174000
    └────────┬─────────┘
             │ WalletService.createWallet(cardId)
             ▼
    ┌──────────────────┐
    │ 3. Create Wallet │ Initial Balance: £0.00
    └────────┬─────────┘
             │ WalletService.topUp(cardId, £20.00)
             ▼
    ┌──────────────────┐
    │ 4. Top-up Wallet │ New Balance: £20.00
    └────────┬─────────┘
             │ TapValidationService.tapIn(cardId, Station.Holborn)
             ▼
    ┌──────────────────┐
    │ 5. Tap In        │ Hold Maximum Fare: £5.00
    │ at Holborn       │ Balance: £15.00
    └────────┬─────────┘
             │
             │ [Passenger Travels]
             │
             │ TapValidationService.tapOut(cardId, Station.EarlsCourt)
             ▼
    ┌──────────────────┐
    │ 6. Tap Out       │ Actual Fare: £2.50
    │ at Earl's Court  │ Refund: £2.50
    └────────┬─────────┘ Final Balance: £17.50
             │
             ▼
    ┌──────────────────┐
    │ Journey Complete │ Journey: Holborn → Earl's Court
    └──────────────────┘ Fare: £2.50


═══════════════════════════════════════════════════════════════════════════════
                           FUNCTIONAL PROGRAMMING FLOW
═══════════════════════════════════════════════════════════════════════════════

    Effect Management with cats.effect.IO
    
    Pure Functions          Side Effects (IO)          State Management (Ref)
    ┌────────────┐          ┌────────────┐            ┌────────────┐
    │            │          │            │            │            │
    │ Validation │─────────▶│ Repository │◀──────────│    Ref     │
    │   Logic    │          │   Save     │            │  (Atomic)  │
    │            │          │            │            │            │
    └────────────┘          └────────────┘            └────────────┘
         │                        │                         │
         │ Either[Error, A]       │ IO[Unit]               │ IO[Map[K,V]]
         │                        │                         │
         ▼                        ▼                         ▼
    Always Pure            Lazy Evaluation          Thread-Safe
    No Side Effects        Composable                Consistent
    Testable              Resource-Safe              Atomic Updates


═══════════════════════════════════════════════════════════════════════════════
                              MODULE DEPENDENCIES
═══════════════════════════════════════════════════════════════════════════════

                         demo
                           │
                           ▼
                      operations
                           │
           ┌───────────────┼───────────────┐
           ▼               ▼               ▼
      account-service  wallet-service  tap-validation
           │               │               │
           └───────────────┼───────────────┘
                           ▼
                        domain
                   (No dependencies)


═══════════════════════════════════════════════════════════════════════════════
                            KEY DESIGN PATTERNS
═══════════════════════════════════════════════════════════════════════════════

1. Repository Pattern
   ┌──────────┐       ┌──────────────┐       ┌──────────┐
   │ Service  │──────▶│  Repository  │──────▶│ Storage  │
   └──────────┘       │  Interface   │       └──────────┘
                      └──────────────┘
                             ▲
                             │
                      ┌──────┴───────┐
                      │ In-Memory    │
                      │Implementation│
                      └──────────────┘

2. Smart Constructors
   Raw Data → Validation → Either[Error, ValidData] → Domain Object

3. Algebraic Data Types
   sealed trait Status
   case object Active extends Status
   case object Blocked extends Status
   (Compiler ensures exhaustive matching)

4. Effect Management
   Business Logic (Pure) → IO[Either[Error, Result]] → Runtime Execution
```

This diagram illustrates the complete system architecture, data flow, and functional programming concepts used throughout the implementation.
