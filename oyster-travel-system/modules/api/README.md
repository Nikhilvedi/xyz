# Oyster Travel System - Play Framework API

This module provides a REST API for the Oyster Travel System using the Scala Play Framework.

## Overview

The API module exposes HTTP endpoints for all system operations including account management, card operations, wallet services, tap-in/tap-out functionality, and system monitoring.

## Architecture

The API module follows Play Framework's MVC architecture while integrating with the existing functional programming services:

- **Controllers**: Handle HTTP requests and responses
- **Models**: JSON serialization/deserialization formats
- **Services**: Reuses existing cats-effect IO-based services
- **Application Loader**: Custom dependency injection

## Key Features

- RESTful API design
- JSON request/response handling with Play JSON
- Integration with cats-effect IO services
- Comprehensive error handling
- CORS support for web clients
- Health check endpoint

## Running the API

### Prerequisites

- JDK 11 or higher
- SBT 1.9.7 or higher

### Start the Server

```bash
# From the oyster-travel-system root directory
sbt "api/run"

# Or specify a port
sbt "api/run -Dhttp.port=9000"
```

The server will start on `http://localhost:9000` by default.

## API Endpoints

### General

- `GET /` - API information
- `GET /health` - Health check

### Account Management

- `POST /api/accounts` - Create account
  ```json
  {"email": "user@example.com", "name": "John Doe"}
  ```
- `GET /api/accounts/:id` - Get account by ID
- `GET /api/accounts` - List all accounts
- `PUT /api/accounts/:id` - Update account
  ```json
  {"name": "New Name", "email": "new@example.com"}
  ```

### Card Management

- `POST /api/cards` - Order card
  ```json
  {"accountId": "uuid"}
  ```
- `GET /api/cards/:id` - Get card by ID
- `GET /api/cards` - List all cards
- `POST /api/cards/:id/activate` - Activate card
- `POST /api/cards/:id/block` - Block card
- `POST /api/cards/:id/cancel` - Cancel card

### Wallet Operations

- `POST /api/wallets` - Create wallet
  ```json
  {"cardId": "uuid"}
  ```
- `GET /api/wallets/:cardId` - Get wallet
- `POST /api/wallets/:cardId/topup` - Top up wallet
  ```json
  {"amount": 20.00}
  ```
- `GET /api/wallets/:cardId/balance` - Get balance
- `GET /api/wallets/:cardId/transactions` - Get transaction history

### Tap/Journey Operations

- `POST /api/tap/in` - Tap in at station
  ```json
  {"cardId": "uuid", "stationName": "Holborn"}
  ```
- `POST /api/tap/out` - Tap out at station
  ```json
  {"cardId": "uuid", "stationName": "Earl's Court"}
  ```
- `GET /api/tap/preview?from=Holborn&to=EarlsCourt` - Preview fare
- `GET /api/journeys/:cardId` - Get journey history

### Monitoring

- `GET /api/monitoring/stats` - System statistics
- `GET /api/monitoring/cards/:id/stats` - Card statistics
- `GET /api/monitoring/low-balance` - Low balance cards
- `GET /api/monitoring/incomplete-journeys` - Incomplete journeys

## Example Usage

### Create Account and Top Up

```bash
# Create account
curl -X POST http://localhost:9000/api/accounts \
  -H "Content-Type: application/json" \
  -d '{"email": "alice@example.com", "name": "Alice Johnson"}'

# Order card (use accountId from response)
curl -X POST http://localhost:9000/api/cards \
  -H "Content-Type: application/json" \
  -d '{"accountId": "account-uuid"}'

# Activate card (use cardId from response)
curl -X POST http://localhost:9000/api/cards/card-uuid/activate

# Create wallet
curl -X POST http://localhost:9000/api/wallets \
  -H "Content-Type: application/json" \
  -d '{"cardId": "card-uuid"}'

# Top up wallet
curl -X POST http://localhost:9000/api/wallets/card-uuid/topup \
  -H "Content-Type: application/json" \
  -d '{"amount": 20.00}'
```

### Make a Journey

```bash
# Tap in
curl -X POST http://localhost:9000/api/tap/in \
  -H "Content-Type: application/json" \
  -d '{"cardId": "card-uuid", "stationName": "Holborn"}'

# Tap out
curl -X POST http://localhost:9000/api/tap/out \
  -H "Content-Type: application/json" \
  -d '{"cardId": "card-uuid", "stationName": "Earl'\''s Court"}'
```

### Check System Stats

```bash
curl http://localhost:9000/api/monitoring/stats
```

## Configuration

The API can be configured via `conf/application.conf`:

- `play.server.http.port` - HTTP port (default: 9000)
- `play.http.secret.key` - Application secret key
- `play.filters.cors` - CORS settings

## Integration with Existing Services

The API module integrates seamlessly with existing services:

1. **cats-effect IO**: Controllers convert IO operations to Futures for Play
2. **Immutable Models**: Domain models remain unchanged
3. **Repository Pattern**: Uses existing in-memory repositories
4. **Functional Approach**: Maintains functional programming principles

## Error Handling

All endpoints return appropriate HTTP status codes:

- `200 OK` - Successful operation
- `201 Created` - Resource created
- `400 Bad Request` - Invalid input
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error

Error responses include JSON with error details:
```json
{"error": "Error message"}
```

## Testing

```bash
# Run API tests
sbt api/test

# Run with test coverage
sbt clean coverage api/test coverageReport
```

## Production Deployment

For production deployment:

1. Set `APPLICATION_SECRET` environment variable
2. Configure appropriate logging levels
3. Set up reverse proxy (nginx, etc.)
4. Consider using a persistent database instead of in-memory repositories

## Development

The API uses hot-reloading in development mode. Changes to controllers and models will be automatically recompiled.

## Notes

- This implementation uses in-memory repositories suitable for demo/testing
- For production, implement database-backed repositories
- All existing services maintain their functional programming approach
- The API layer is thin - business logic remains in service modules
