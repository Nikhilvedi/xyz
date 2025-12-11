# 🎯 Oyster Travel System - Whiteboard Interview Guide

## Quick Reference for Case Study Presentation

---

## 1. SYSTEM OVERVIEW (Draw this first)

```
┌────────────────────────────────────────────┐
│     OYSTER TRAVEL CARD SYSTEM              │
│     (Like London Underground)              │
└────────────────────────────────────────────┘

Tech Stack:
• Scala 2.13
• Play Framework (REST API)
• Cats Effect (Functional Programming)
• PostgreSQL Database
```

---

## 2. ARCHITECTURE (3 Layers - Draw 3 horizontal boxes)

```
┌────────────────────────────────────────────┐
│  LAYER 1: API (Play Framework)             │
│  REST endpoints, JSON, HTTP                │
└────────────────────────────────────────────┘
                  ↓
┌────────────────────────────────────────────┐
│  LAYER 2: BUSINESS SERVICES                │
│  Account, Card, Wallet, Tap Services       │
└────────────────────────────────────────────┘
                  ↓
┌────────────────────────────────────────────┐
│  LAYER 3: DATA (PostgreSQL)                │
│  8 tables, repositories                    │
└────────────────────────────────────────────┘
```

---

## 3. CORE ENTITIES (Draw 4 boxes with arrows)

```
┌──────────┐         ┌──────┐         ┌────────┐
│ ACCOUNT  │────────▶│ CARD │────────▶│ WALLET │
│          │  1:Many │      │   1:1   │        │
│ id       │         │ id   │         │ balance│
│ email    │         │status│         │ card_id│
│ name     │         └──┬───┘         └────────┘
└──────────┘            │
                        │ 1:Many
                        ▼
                   ┌─────────┐
                   │ JOURNEY │
                   │         │
                   │ start   │
                   │ end     │
                   │ fare    │
                   └─────────┘
```

---

## 4. USER JOURNEY FLOW (Draw vertical flow)

```
1. CREATE ACCOUNT
   ↓
2. ORDER CARD
   ↓
3. ACTIVATE CARD
   ↓
4. CREATE WALLET
   ↓
5. TOP UP (£20)
   ↓
6. TAP IN (Hold £5)
   ↓
7. TRAVEL
   ↓
8. TAP OUT (Charge actual fare, refund difference)
```

---

## 5. KEY REST API ENDPOINTS

```
POST   /api/accounts              Create account
POST   /api/cards                 Order card
POST   /api/cards/:id/activate    Activate card
POST   /api/wallets               Create wallet
POST   /api/wallets/:id/topup     Add money
POST   /api/tap/in                Start journey
POST   /api/tap/out               End journey
GET    /api/monitoring/stats      System stats
GET    /health                    Health check
```

---

## 6. DATABASE SCHEMA (8 Tables)

```
Core Tables:
1. ACCOUNT       - Customer info
2. CARD          - Travel cards
3. WALLET        - Balance per card
4. TRANSACTION   - Money movements
5. JOURNEY       - Travel history

Reference Tables:
6. STATION       - Tube stations
7. ZONE          - Transport zones (1-9)
8. STATION_ZONE  - Station-Zone mapping
```

---

## 7. BUSINESS RULES

```
Wallet:
• Max balance: £500
• Min top-up: £1
• Max top-up: £100

Fares:
• Maximum fare: £5.00 (held on tap-in)
• Minimum fare: £1.50
• Zone-based calculation
• Automatic refund on tap-out

Card Status:
• Pending → Active → Blocked/Cancelled
```

---

## 8. FUNCTIONAL PROGRAMMING CONCEPTS

```
Key FP Concepts Used:
• Immutable data structures (case classes)
• Pure functions (no side effects)
• IO Monad (cats-effect)
• Either for error handling
• Repository pattern with Ref

Example:
def createAccount(email: String): IO[Either[String, Account]]
                                  ↑    ↑       ↑
                                  |    |       └─ Success
                                  |    └─ Error message
                                  └─ Side effect wrapper
```

---

## 9. TECH HIGHLIGHTS

```
✓ Play Framework 2.8 (REST API)
✓ Scala 2.13 (Type-safe)
✓ Cats Effect 3.5 (Functional effects)
✓ PostgreSQL (Persistence)
✓ SBT (Build tool)
✓ ScalaTest (Testing)

Module Structure:
• domain (core logic)
• account-service
• wallet-service
• tap-validation
• operations (monitoring)
• api (Play Framework)
• demo (example app)
```

---

## 10. DEMO SCENARIO (Tell this story)

```
"Let me show you a typical user flow:

1. Alice creates an account
   POST /api/accounts {"email":"alice@example.com", "name":"Alice"}

2. Orders a travel card
   POST /api/cards {"accountId":"..."}

3. Activates it
   POST /api/cards/123/activate

4. Tops up £20
   POST /api/wallets/123/topup {"amount": 20.00}

5. Taps in at Holborn (Zone 1)
   POST /api/tap/in {"cardId":"123", "stationName":"Holborn"}
   System holds £5.00 maximum fare

6. Taps out at Earl's Court (Zone 1-2)
   POST /api/tap/out {"cardId":"123", "stationName":"Earl's Court"}
   Actual fare: £2.50
   Refund: £2.50
   Final balance: £17.50

7. Check stats
   GET /api/monitoring/stats
   Shows: total journeys, revenue, active cards
```

---

## INTERVIEW TALKING POINTS

### Why Play Framework?
- Industry-standard for Scala web apps
- Built-in JSON handling
- Type-safe routing
- Async/non-blocking
- Easy to test

### Why Functional Programming?
- Immutability = thread-safe
- Pure functions = testable
- IO monad = explicit effects
- Either = type-safe errors
- Composable and maintainable

### Design Patterns Used:
- Repository Pattern (data access)
- Service Layer (business logic)
- Value Objects (type safety)
- Smart Constructors (validation)
- Algebraic Data Types (exhaustive matching)

### Scalability Considerations:
- Stateless services (horizontal scaling)
- Repository abstraction (swap DB easily)
- Async operations (Play + cats-effect)
- Can add caching layer
- Can add message queue for async processing

---

## QUICK WHITEBOARD LAYOUT

```
Draw this layout on whiteboard:

Top Left: System Overview box
Top Right: Tech Stack list
Middle: Architecture diagram (3 layers)
Bottom Left: Core entities with relationships
Bottom Right: User journey flow
Center: API endpoints (if space)
```

---

## KEY METRICS TO MENTION

```
• 7 modules (domain + 6 service modules)
• 8 database tables
• 40+ REST endpoints
• Full CRUD operations
• Real-time journey tracking
• System monitoring & reporting
• 100% type-safe
• Functional programming throughout
```

---

## CLOSING POINTS

```
What makes this system production-ready:
✓ Separation of concerns (layered architecture)
✓ Type safety (compile-time error checking)
✓ Testable (pure functions, dependency injection)
✓ Scalable (stateless services)
✓ Maintainable (functional programming, clear modules)
✓ Observable (monitoring endpoints)
✓ Extensible (repository pattern, service layer)
```

---

**Good luck with your interview! 🚀**
