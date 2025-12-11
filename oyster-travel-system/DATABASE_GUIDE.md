# Database Quick Start Guide

## 🎯 Overview

This guide helps you quickly set up and use the PostgreSQL database for the Oyster Travel System.

## 🚀 Quick Start (Docker - Recommended)

### 1. Start the Database

```bash
cd oyster-travel-system/database
docker-compose up -d
```

This will:
- Start PostgreSQL 15 on port 5432
- Start pgAdmin on port 5050 (optional UI)
- Automatically create the database and apply the schema
- Set up persistent volumes for data

### 2. Verify Setup

```bash
# Check if containers are running
docker ps | grep oyster

# Test connection
docker exec -it oyster-postgres psql -U oyster -d oyster_db -c "SELECT version();"
```

### 3. Connect to Database

```bash
# Using psql
docker exec -it oyster-postgres psql -U oyster -d oyster_db

# Once connected, try:
\dt oyster.*          # List all tables
SELECT * FROM oyster.zone;  # View zones
SELECT * FROM oyster.station;  # View stations
```

## 📊 Viewing the ERD

The Entity Relationship Diagram shows the database structure visually:

**File:** [ERD.md](ERD.md)

The ERD includes:
- All 8 entities with their attributes
- Relationships between entities
- Primary keys (PK) and foreign keys (FK)
- Constraints and check rules

## 🗂️ Database Structure

### Core Tables

| Table | Description | Key Relationships |
|-------|-------------|-------------------|
| `account` | Customer accounts | Parent of `card` |
| `card` | Travel cards | Child of `account`, parent of `wallet`, `transaction`, `journey` |
| `wallet` | Card balances | One-to-one with `card` |
| `transaction` | Financial transactions | Many-to-one with `card` |
| `journey` | Travel journeys | Many-to-one with `card`, `station` |
| `station` | Transport stations | Many-to-many with `zone` via `station_zone` |
| `zone` | Transport zones (1-9) | Many-to-many with `station` |
| `station_zone` | Station-zone mapping | Junction table |

### Useful Views

| View | Purpose |
|------|---------|
| `v_active_cards` | Active cards with wallet info |
| `v_journey_summary` | Journeys with station names |
| `v_transaction_history` | Transactions with account details |
| `v_low_balance_alerts` | Cards with balance < £5 |

## 💡 Common Operations

### Check All Accounts
```sql
SELECT * FROM oyster.account;
```

### View Active Cards with Balances
```sql
SELECT * FROM oyster.v_active_cards;
```

### Get Recent Journeys
```sql
SELECT * FROM oyster.v_journey_summary 
ORDER BY tap_in_time DESC 
LIMIT 10;
```

### Find Low Balance Cards
```sql
SELECT * FROM oyster.v_low_balance_alerts;
```

### Check Transaction History for a Card
```sql
SELECT * FROM oyster.transaction 
WHERE card_id = 'your-card-id-here'
ORDER BY timestamp DESC;
```

## 🔧 Using pgAdmin (Database UI)

If you started the database with Docker Compose, pgAdmin is available:

1. **Open pgAdmin:** http://localhost:5050
2. **Login:**
   - Email: `admin@oyster.local`
   - Password: `admin`
3. **Add Server:**
   - Host: `postgres` (Docker network name)
   - Port: `5432`
   - Database: `oyster_db`
   - Username: `oyster`
   - Password: `oyster_password`

## 🔄 Database Migrations

For production deployments, use migration tools:

### Flyway
```bash
cd database
flyway -url=jdbc:postgresql://localhost:5432/oyster_db \
       -user=oyster \
       -password=oyster_password \
       -schemas=oyster \
       migrate
```

### Manual Migration
```bash
psql -U oyster -d oyster_db -f migrations/V1__initial_schema.sql
```

See [database/migrations/README.md](database/migrations/README.md) for details.

## 🛑 Stop and Clean Up

### Stop Containers (Keep Data)
```bash
cd database
docker-compose stop
```

### Stop and Remove Everything
```bash
cd database
docker-compose down -v  # -v removes volumes (deletes data)
```

## 🔗 Connection Information

### Default Connection Details

- **Host:** localhost
- **Port:** 5432
- **Database:** oyster_db
- **Username:** oyster
- **Password:** oyster_password
- **Schema:** oyster

### JDBC Connection String
```
jdbc:postgresql://localhost:5432/oyster_db?currentSchema=oyster
```

## 📚 Additional Documentation

- **[ERD.md](ERD.md)** - Visual entity relationship diagram
- **[database/README.md](database/README.md)** - Comprehensive database guide
- **[database/schema.sql](database/schema.sql)** - Complete SQL schema
- **[database/migrations/README.md](database/migrations/README.md)** - Migration guide

## 🆘 Troubleshooting

### Port Already in Use
```bash
# Check what's using port 5432
lsof -i :5432

# Stop other PostgreSQL instances or change port in docker-compose.yml
```

### Cannot Connect
```bash
# Check container status
docker ps | grep oyster-postgres

# Check logs
docker logs oyster-postgres

# Restart container
docker-compose restart postgres
```

### Schema Not Found
```sql
-- Set search path
SET search_path TO oyster, public;

-- Or always use schema prefix
SELECT * FROM oyster.account;
```

## ⚠️ Production Considerations

Before using in production:

1. ✅ Change default passwords
2. ✅ Use environment variables for credentials
3. ✅ Enable SSL/TLS connections
4. ✅ Set up regular backups
5. ✅ Configure proper firewall rules
6. ✅ Set up monitoring and alerting
7. ✅ Review and adjust connection pool settings
8. ✅ Test disaster recovery procedures

## 🎓 Learning Resources

- [PostgreSQL Official Documentation](https://www.postgresql.org/docs/)
- [SQL Tutorial](https://www.postgresqltutorial.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
