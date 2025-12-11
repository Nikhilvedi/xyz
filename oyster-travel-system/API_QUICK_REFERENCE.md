# API Quick Reference - Oyster Travel System

## Base URL
```
http://localhost:9000
```

---

## 🏠 General

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | API information |
| GET | `/health` | Health check |

---

## 👤 Account Management

| Method | Endpoint | Request Body | Response |
|--------|----------|--------------|----------|
| POST | `/api/accounts` | `{"email":"user@example.com", "name":"John Doe"}` | Account object |
| GET | `/api/accounts/:id` | - | Account object |
| GET | `/api/accounts` | - | Array of accounts |
| PUT | `/api/accounts/:id` | `{"name":"New Name", "email":"new@example.com"}` | Updated account |

---

## 💳 Card Management

| Method | Endpoint | Request Body | Response |
|--------|----------|--------------|----------|
| POST | `/api/cards` | `{"accountId":"uuid"}` | Card object |
| GET | `/api/cards/:id` | - | Card object |
| GET | `/api/cards` | - | Array of cards |
| POST | `/api/cards/:id/activate` | - | Activated card |
| POST | `/api/cards/:id/block` | - | Blocked card |
| POST | `/api/cards/:id/cancel` | - | Cancelled card |

---

## 💰 Wallet Operations

| Method | Endpoint | Request Body | Response |
|--------|----------|--------------|----------|
| POST | `/api/wallets` | `{"cardId":"uuid"}` | Wallet object |
| GET | `/api/wallets/:cardId` | - | Wallet object |
| POST | `/api/wallets/:cardId/topup` | `{"amount":20.00}` | Updated wallet |
| GET | `/api/wallets/:cardId/balance` | - | `{"balance":20.00}` |
| GET | `/api/wallets/:cardId/transactions` | - | Array of transactions |

---

## 🚇 Tap/Journey Operations

| Method | Endpoint | Request Body | Response |
|--------|----------|--------------|----------|
| POST | `/api/tap/in` | `{"cardId":"uuid", "stationName":"Holborn"}` | Journey object |
| POST | `/api/tap/out` | `{"cardId":"uuid", "stationName":"Earl's Court"}` | Completed journey |
| GET | `/api/tap/preview?from=Holborn&to=EarlsCourt` | - | `{"fare":2.50}` |
| GET | `/api/journeys/:cardId` | - | Array of journeys |

---

## 📊 Monitoring

| Method | Endpoint | Response |
|--------|----------|----------|
| GET | `/api/monitoring/stats` | System statistics |
| GET | `/api/monitoring/cards/:id/stats` | Card-specific stats |
| GET | `/api/monitoring/low-balance` | Cards with low balance |
| GET | `/api/monitoring/incomplete-journeys` | Incomplete journeys |

---

## 🎯 Common Stations

- Holborn (Zone 1)
- King's Cross (Zone 1)
- Earl's Court (Zone 1, 2)
- Hammersmith (Zone 2)
- Wimbledon (Zone 3)

---

## 💡 Complete Example Flow

```bash
# 1. Create account
curl -X POST http://localhost:9000/api/accounts \
  -H "Content-Type: application/json" \
  -d '{"email":"alice@example.com", "name":"Alice Johnson"}'

# Response: {"id":"550e8400-...", "email":"alice@example.com", ...}

# 2. Order card
curl -X POST http://localhost:9000/api/cards \
  -H "Content-Type: application/json" \
  -d '{"accountId":"550e8400-..."}'

# Response: {"id":"123e4567-...", "status":"Pending", ...}

# 3. Activate card
curl -X POST http://localhost:9000/api/cards/123e4567-.../activate

# Response: {"id":"123e4567-...", "status":"Active", ...}

# 4. Create wallet
curl -X POST http://localhost:9000/api/wallets \
  -H "Content-Type: application/json" \
  -d '{"cardId":"123e4567-..."}'

# 5. Top up £20
curl -X POST http://localhost:9000/api/wallets/123e4567-.../topup \
  -H "Content-Type: application/json" \
  -d '{"amount":20.00}'

# Response: {"cardId":"...", "balance":20.00, ...}

# 6. Tap in at Holborn
curl -X POST http://localhost:9000/api/tap/in \
  -H "Content-Type: application/json" \
  -d '{"cardId":"123e4567-...", "stationName":"Holborn"}'

# Response: {"id":"...", "status":"InProgress", "fare":5.00, ...}

# 7. Tap out at Earl's Court
curl -X POST http://localhost:9000/api/tap/out \
  -H "Content-Type: application/json" \
  -d '{"cardId":"123e4567-...", "stationName":"Earl'\''s Court"}'

# Response: {"id":"...", "status":"Completed", "fare":2.50, ...}

# 8. Check balance
curl http://localhost:9000/api/wallets/123e4567-.../balance

# Response: {"balance":17.50}

# 9. View system stats
curl http://localhost:9000/api/monitoring/stats

# Response: {"totalJourneys":1, "totalRevenue":2.50, ...}
```

---

## ⚠️ Error Responses

All errors return JSON:
```json
{"error": "Error message description"}
```

Common status codes:
- `200 OK` - Success
- `201 Created` - Resource created
- `400 Bad Request` - Invalid input
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error

---

## 🚀 Running the API

```bash
# Start the server
cd oyster-travel-system
sbt api/run

# Server will start on port 9000
# Access at: http://localhost:9000
```
