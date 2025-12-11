# Database Documentation

## Overview

This directory contains the PostgreSQL database schema for the Oyster Travel System. The database is designed to persist all data for accounts, cards, wallets, transactions, journeys, and stations.

## Files

- **schema.sql** - Complete PostgreSQL database schema with tables, indexes, views, and seed data
- **docker-compose.yml** - Docker Compose configuration for running PostgreSQL locally
- **README.md** - This file

## Quick Start

### Using Docker (Recommended)

1. **Start PostgreSQL using Docker Compose:**
   ```bash
   cd database
   docker-compose up -d
   ```

2. **Apply the schema:**
   ```bash
   docker exec -i oyster-postgres psql -U oyster -d oyster_db < schema.sql
   ```

3. **Connect to the database:**
   ```bash
   docker exec -it oyster-postgres psql -U oyster -d oyster_db
   ```

4. **Stop the database:**
   ```bash
   docker-compose down
   ```

5. **Stop and remove all data:**
   ```bash
   docker-compose down -v
   ```

### Using Local PostgreSQL

If you have PostgreSQL installed locally:

1. **Create the database:**
   ```bash
   createdb oyster_db
   ```

2. **Apply the schema:**
   ```bash
   psql -d oyster_db -f schema.sql
   ```

3. **Connect to the database:**
   ```bash
   psql -d oyster_db
   ```

## Database Schema

### Tables

1. **account** - Customer accounts
2. **card** - Travel cards associated with accounts
3. **wallet** - Monetary balances for cards (1-to-1 with card)
4. **transaction** - Financial transaction history
5. **journey** - Travel journeys from tap-in to tap-out
6. **station** - Transport stations
7. **zone** - Transport zones (1-9)
8. **station_zone** - Many-to-many relationship between stations and zones

### Views

- **v_active_cards** - Active cards with account and wallet information
- **v_journey_summary** - Journey details with station names and duration
- **v_transaction_history** - Transaction history with account information
- **v_low_balance_alerts** - Active cards with low balance (< £5.00)

## Connection Details (Docker)

- **Host:** localhost
- **Port:** 5432
- **Database:** oyster_db
- **Username:** oyster
- **Password:** oyster_password
- **Schema:** oyster

## Connection String Examples

### JDBC (Java)
```
jdbc:postgresql://localhost:5432/oyster_db?currentSchema=oyster
```

### Scala (using Doobie)
```scala
val transactor = Transactor.fromDriverManager[IO](
  "org.postgresql.Driver",
  "jdbc:postgresql://localhost:5432/oyster_db?currentSchema=oyster",
  "oyster",
  "oyster_password"
)
```

### Node.js (using pg)
```javascript
const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'oyster_db',
  user: 'oyster',
  password: 'oyster_password',
  options: '-c search_path=oyster,public'
});
```

### Python (using psycopg2)
```python
import psycopg2

conn = psycopg2.connect(
    host="localhost",
    port=5432,
    database="oyster_db",
    user="oyster",
    password="oyster_password",
    options="-c search_path=oyster,public"
)
```

## Sample Queries

### Check all accounts
```sql
SELECT * FROM oyster.account;
```

### View active cards with balances
```sql
SELECT * FROM oyster.v_active_cards;
```

### Get recent journeys
```sql
SELECT * FROM oyster.v_journey_summary 
ORDER BY tap_in_time DESC 
LIMIT 10;
```

### Find low balance cards
```sql
SELECT * FROM oyster.v_low_balance_alerts;
```

### Get transaction history for a card
```sql
SELECT * FROM oyster.transaction 
WHERE card_id = 'your-card-id-here'
ORDER BY timestamp DESC;
```

### Check station zones
```sql
SELECT s.name, array_agg(z.name ORDER BY z.number) as zones
FROM oyster.station s
JOIN oyster.station_zone sz ON s.id = sz.station_id
JOIN oyster.zone z ON sz.zone_number = z.number
GROUP BY s.id, s.name
ORDER BY s.name;
```

## Maintenance

### Backup Database
```bash
docker exec oyster-postgres pg_dump -U oyster oyster_db > backup.sql
```

### Restore Database
```bash
docker exec -i oyster-postgres psql -U oyster oyster_db < backup.sql
```

### View Database Size
```sql
SELECT pg_size_pretty(pg_database_size('oyster_db'));
```

### View Table Sizes
```sql
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'oyster'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

## Schema Versioning

The database includes a `schema_version` table to track schema changes:

```sql
SELECT * FROM oyster.schema_version ORDER BY applied_at DESC;
```

Current version: **1.0.0**

## Security Notes

⚠️ **Important for Production:**

1. **Change default passwords** - Never use default passwords in production
2. **Use environment variables** - Store credentials in environment variables or secrets management
3. **Restrict network access** - Use firewall rules to limit database access
4. **Enable SSL/TLS** - Encrypt connections to the database
5. **Regular backups** - Implement automated backup strategy
6. **Monitor activity** - Set up logging and monitoring
7. **Apply updates** - Keep PostgreSQL updated with security patches

## Troubleshooting

### Cannot connect to database
```bash
# Check if container is running
docker ps | grep oyster-postgres

# Check container logs
docker logs oyster-postgres

# Restart container
docker-compose restart
```

### Schema not found
```sql
-- Ensure you're using the correct schema
SET search_path TO oyster, public;

-- Or specify schema in queries
SELECT * FROM oyster.account;
```

### Permission denied
```sql
-- Check current user
SELECT current_user;

-- Check schema permissions
SELECT * FROM information_schema.schema_privileges 
WHERE grantee = current_user;
```

## Further Reading

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [PostgreSQL Performance Tips](https://www.postgresql.org/docs/current/performance-tips.html)
- [PostgreSQL Security Best Practices](https://www.postgresql.org/docs/current/security.html)
