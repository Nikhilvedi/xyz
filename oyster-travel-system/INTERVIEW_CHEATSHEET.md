# 🚀 Interview Cheat Sheet - Quick Review

> **Use this for last-minute review before your interview. Full details in [INTERVIEW_PREP.md](INTERVIEW_PREP.md)**

---

## 30-Second System Summary

*"Oyster Travel System is a transport card system like London Underground, built in Scala using functional programming. It's a multi-module monolith with Play Framework REST API, Cats Effect for effects, and PostgreSQL. The architecture prioritizes type safety, testability, and clear separation of concerns."*

---

## The 4 Key "Why" Questions

### 1. Why Multi-Module SBT?
**Short Answer:** *"Microservices benefits without operational complexity"*

**Key Points:**
- ✅ Clear module boundaries (domain, services, API)
- ✅ Enforced dependencies (won't compile if wrong)
- ✅ Independent testing per module
- ✅ Easy to extract to microservices later
- ❌ NOT microservices (avoid distributed complexity)
- ❌ NOT single module (avoid coupling)

**One-liner:** *"Modular monolith gives us structure now, evolution path later"*

---

### 2. Why Play Framework?
**Short Answer:** *"Industry standard for Scala, productive, great defaults"*

**Key Points:**
- ✅ Type-safe routes (compile-time checks)
- ✅ Built-in JSON handling (Play JSON)
- ✅ Async/non-blocking (Akka under the hood)
- ✅ Hot reload in dev
- ✅ Large ecosystem & community

**Comparison:**
| Framework | Why Not? |
|-----------|----------|
| Akka HTTP | Too low-level, more boilerplate |
| http4s | Smaller community, more FP-heavy |
| Spring Boot | Not idiomatic Scala |

**One-liner:** *"Play is the 'Rails of Scala' - convention over configuration"*

---

### 3. Why Cats Effect?
**Short Answer:** *"Pure FP: referential transparency, composability, testability"*

**Key Points:**
- ✅ IO monad is lazy (describes, doesn't execute)
- ✅ Referential transparency (same input = same output)
- ✅ Explicit effects (side effects in type signature)
- ✅ Resource safety (guaranteed cleanup)
- ✅ Easy to test (compose without executing)

**Problem with Future:**
```scala
val future = Future { println("runs immediately!") } // Eager!
val io = IO { println("runs when called") } // Lazy!
```

**One-liner:** *"IO makes effects explicit and composable without execution"*

---

### 4. Why This ERD?
**Short Answer:** *"Normalized for integrity, denormalized strategically for performance"*

**Key Relationships:**
```
ACCOUNT (1:Many) CARD (1:1) WALLET
                   ↓
                JOURNEY
```

**Key Design Decisions:**
1. **Card → Wallet (1:1)**: Simple balance lookups, atomic updates
2. **Separate Transaction table**: Efficient queries, proper indexes
3. **`balance_after` in Transaction**: Audit trail, fast reconstruction
4. **NULL for `end_station_id`**: Represents incomplete journeys naturally
5. **VARCHAR for status**: Fixed enums, no need for separate table

**One-liner:** *"Each relationship and constraint maps to a real business rule"*

---

## Module Structure (Draw This!)

```
┌─────────────────────────────────┐
│  demo / api (Application)       │  ← Examples & REST API
├─────────────────────────────────┤
│  operations (Monitoring)        │  ← System-wide concerns
├─────────────────────────────────┤
│  Services (account, wallet, tap)│  ← Business logic
├─────────────────────────────────┤
│  domain (Core)                  │  ← Pure domain models
└─────────────────────────────────┘
```

**Dependency Rule:** Arrows only point down (inner layers independent)

---

## Key Technologies

| Layer | Technology | Version |
|-------|-----------|---------|
| **Language** | Scala | 2.13.12 |
| **Build** | SBT | 1.9.7 |
| **Web** | Play Framework | 2.8.20 |
| **FP** | Cats Effect | 3.5.2 |
| **DB** | PostgreSQL | 12+ |
| **Test** | ScalaTest | 3.2.17 |

---

## The 3 FP Concepts to Mention

### 1. Immutability
```scala
case class Wallet(balance: Money)  // Immutable
wallet.topUp(10) // Returns NEW wallet, thread-safe
```

### 2. Pure Functions
```scala
def calculateFare(from: Station, to: Station): Money
// Same input = same output, no side effects
```

### 3. IO Monad
```scala
def createAccount(email: String): IO[Account]
// Describes effect, doesn't execute yet
```

---

## Common Questions - Quick Answers

### "How would you scale this?"
1. **Horizontal scaling** - Add more API instances (stateless)
2. **Database** - Read replicas, connection pooling, caching
3. **Async** - Message queue for background jobs
4. **Microservices** - Extract modules if needed (already modular)

### "How would you handle concurrency?"
1. **Optimistic locking** - Version field in updates
2. **Pessimistic locking** - SELECT FOR UPDATE
3. **Cats Effect Ref** - Atomic in-memory updates (current)
4. **Message queue** - Sequential processing

### "What about security?"
1. **Input validation** - At domain boundary (smart constructors)
2. **Auth** - JWT tokens (to add)
3. **Audit trail** - All transactions logged
4. **Balance limits** - Prevent abuse (£500 max)
5. **HTTPS** - All traffic encrypted

### "How would you test this?"
1. **Unit** - Pure functions (no mocking)
2. **Integration** - Services with in-memory repos
3. **API** - HTTP endpoint tests
4. **Property-based** - ScalaCheck for invariants
5. **Load** - Apache Bench / Gatling

### "What would you improve?"
**Immediate:**
- Add comprehensive tests
- Implement authentication/authorization
- Database connection pooling
- Caching layer

**Medium-term:**
- Event sourcing for audit
- CQRS pattern
- Async job processing
- Rate limiting

---

## User Journey to Demo

```bash
# 1. Create account
POST /api/accounts {"email":"alice@example.com", "name":"Alice"}

# 2. Order & activate card
POST /api/cards {"accountId":"<id>"}
POST /api/cards/<card-id>/activate

# 3. Create wallet & top up
POST /api/wallets {"cardId":"<id>"}
POST /api/wallets/<card-id>/topup {"amount":20.00}

# 4. Make journey
POST /api/tap/in {"cardId":"<id>", "stationName":"Holborn"}
POST /api/tap/out {"cardId":"<id>", "stationName":"Earl's Court"}

# 5. Check stats
GET /api/monitoring/stats
```

---

## Business Rules to Know

**Wallet:**
- Max balance: £500
- Min top-up: £1
- Max top-up: £100

**Fares:**
- Maximum fare: £5.00 (held on tap-in)
- Minimum fare: £1.50
- Zone 1 to Zone 1: £2.50
- Zone 1 to Zone 2: £3.00

**Card Status:**
Pending → Active → Blocked/Cancelled

---

## Database Schema (8 Tables)

**Core:** account, card, wallet, transaction, journey
**Reference:** station, zone, station_zone

**Key Indexes:**
- `card(account_id)` - Find cards by account
- `transaction(card_id)` - Transaction history
- `journey(card_id, status)` - Journey queries
- `account(email)` - Unique email lookup

---

## Whiteboard Layout

```
┌─────────────┬─────────────┐
│ System      │ Tech Stack  │
│ Overview    │             │
├─────────────┴─────────────┤
│  Architecture (3 layers)  │
├───────────┬─────────────┬─┤
│ Entities  │ User Flow   │ │
│ (4 boxes) │ (8 steps)   │ │
└───────────┴─────────────┴─┘
```

---

## Numbers to Remember

- **7 modules**: domain + 6 service/application modules
- **8 tables**: Full relational schema
- **40+ endpoints**: Complete REST API
- **5 services**: Account, Card, Wallet, Tap, Monitoring
- **3 FP concepts**: Immutability, Pure Functions, IO Monad
- **4 core entities**: Account, Card, Wallet, Journey

---

## Talking Points by Topic

### Architecture
*"We follow hexagonal/ports-and-adapters: domain at core, services around it, infrastructure (API/DB) at edges. This keeps business logic pure and independent of technical concerns."*

### Functional Programming
*"FP isn't academic - it's about using the compiler to prevent bugs. Immutability eliminates race conditions, pure functions are predictable and testable, and strong types catch errors at compile time, not in production."*

### Scalability
*"We started with a modular monolith because it's simpler to develop and deploy. The clear module boundaries mean we can extract to microservices later if scale requires, without a rewrite."*

### Trade-offs
*"Every decision is a trade-off. Multi-module adds build complexity but gives us modularity. FP has a learning curve but prevents bug classes. Play is heavyweight vs Akka HTTP but more productive."*

---

## Interview Checklist

Before the interview, can you explain:

- [ ] Why multi-module SBT? *(Modularity without microservices complexity)*
- [ ] Why Play Framework? *(Industry standard, productive)*
- [ ] Why Cats Effect? *(Pure FP, composable effects)*
- [ ] Why this ERD design? *(Business rules as constraints)*
- [ ] One complete user flow? *(Account → Card → Wallet → Journey)*
- [ ] Three FP concepts? *(Immutability, Pure functions, IO)*
- [ ] How to scale? *(Horizontal, caching, async, microservices)*
- [ ] How to test? *(Unit, integration, API, property-based)*
- [ ] What to improve? *(Auth, tests, caching, async)*

---

## Final Tips

1. **Start with the big picture** - 3-layer architecture
2. **Have one concrete example ready** - User journey with API calls
3. **Know your trade-offs** - Why X over Y
4. **Be honest about limitations** - "This is demo, production would need..."
5. **Show enthusiasm** - FP makes you excited about correctness!

---

**🎯 Remember:** Interviewers value clear thinking and trade-off awareness more than perfect solutions. Be ready to discuss alternatives and explain why you chose your approach.

**Good luck! 🚀**

---

## Quick Links

- **[INTERVIEW_PREP.md](INTERVIEW_PREP.md)** - Full detailed guide (read this first!)
- **[WHITEBOARD_GUIDE.md](WHITEBOARD_GUIDE.md)** - Diagrams you can draw
- **[API_QUICK_REFERENCE.md](API_QUICK_REFERENCE.md)** - All API endpoints
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture deep dive
- **[ERD.md](ERD.md)** - Database schema explained
