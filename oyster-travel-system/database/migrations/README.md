# Database Migrations

## Overview

This directory contains database migration scripts for the Oyster Travel System. Migrations allow you to version control your database schema changes and apply them incrementally.

## Migration Tools

You can use any of the following migration tools with this directory:

### Flyway

[Flyway](https://flywaydb.org/) is a popular database migration tool.

**Installation:**
```bash
# macOS
brew install flyway

# Linux (download from https://flywaydb.org/download)
# Or use Docker
docker pull flyway/flyway
```

**Configuration (flyway.conf):**
```properties
flyway.url=jdbc:postgresql://localhost:5432/oyster_db
flyway.user=oyster
flyway.password=oyster_password
flyway.schemas=oyster
flyway.locations=filesystem:./migrations
```

**Usage:**
```bash
# Check migration status
flyway info

# Apply migrations
flyway migrate

# Validate migrations
flyway validate

# Using Docker
docker run --rm \
  -v $(pwd)/migrations:/flyway/sql \
  flyway/flyway \
  -url=jdbc:postgresql://host.docker.internal:5432/oyster_db \
  -user=oyster \
  -password=oyster_password \
  -schemas=oyster \
  migrate
```

### Liquibase

[Liquibase](https://www.liquibase.org/) is another popular database migration tool.

**Installation:**
```bash
# macOS
brew install liquibase

# Or use Docker
docker pull liquibase/liquibase
```

**Usage:**
```bash
liquibase update \
  --url=jdbc:postgresql://localhost:5432/oyster_db \
  --username=oyster \
  --password=oyster_password \
  --changeLogFile=changelog.xml
```

### golang-migrate

[golang-migrate](https://github.com/golang-migrate/migrate) is a simple migration tool written in Go.

**Installation:**
```bash
# macOS
brew install golang-migrate

# Linux
go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest
```

**Usage:**
```bash
# Apply all pending migrations
migrate -database "postgres://oyster:oyster_password@localhost:5432/oyster_db?sslmode=disable&search_path=oyster" \
        -path ./migrations \
        up

# Rollback one migration
migrate -database "postgres://oyster:oyster_password@localhost:5432/oyster_db?sslmode=disable&search_path=oyster" \
        -path ./migrations \
        down 1
```

## Migration Naming Convention

Migrations should follow this naming pattern:

```
V{version}__{description}.sql
```

Examples:
- `V1__initial_schema.sql`
- `V2__add_journey_indexes.sql`
- `V3__add_user_preferences_table.sql`
- `V4__alter_wallet_max_balance.sql`

### Best Practices

1. **Never modify existing migrations** - Once applied, treat them as immutable
2. **Always create new migrations** - For schema changes, create a new migration file
3. **Test migrations** - Test on development database before applying to production
4. **Incremental changes** - Keep migrations small and focused
5. **Add descriptions** - Include clear descriptions of what each migration does
6. **Backup first** - Always backup production database before applying migrations
7. **Rollback plan** - Have a rollback strategy for each migration

## Manual Migration

If you're not using a migration tool, you can apply migrations manually:

```bash
# Apply a specific migration
psql -U oyster -d oyster_db -f migrations/V1__initial_schema.sql

# Apply all migrations in order
for file in migrations/V*.sql; do
    echo "Applying $file..."
    psql -U oyster -d oyster_db -f "$file"
done
```

## Creating New Migrations

When you need to change the database schema:

1. **Create a new migration file:**
   ```bash
   # Next version number (e.g., if V1 exists, create V2)
   touch migrations/V2__your_description.sql
   ```

2. **Write your SQL changes:**
   ```sql
   -- V2__add_card_expiry.sql
   SET search_path TO oyster, public;
   
   ALTER TABLE card ADD COLUMN expiry_date DATE;
   
   CREATE INDEX idx_card_expiry ON card(expiry_date);
   
   INSERT INTO schema_version (version, description) VALUES
       ('V2', 'Added expiry date to cards');
   ```

3. **Test the migration:**
   ```bash
   # Test on a development database first
   psql -U oyster -d oyster_db_dev -f migrations/V2__add_card_expiry.sql
   ```

4. **Apply to production:**
   ```bash
   # Use your migration tool or apply manually
   flyway migrate
   ```

## Rollback Migrations

For tools that support rollback (e.g., golang-migrate), create a down migration:

```
V2__add_card_expiry.up.sql
V2__add_card_expiry.down.sql
```

**Down migration example:**
```sql
-- V2__add_card_expiry.down.sql
SET search_path TO oyster, public;

DROP INDEX IF EXISTS idx_card_expiry;
ALTER TABLE card DROP COLUMN IF EXISTS expiry_date;

DELETE FROM schema_version WHERE version = 'V2';
```

## Current Schema Version

To check the current schema version:

```sql
SELECT * FROM oyster.schema_version ORDER BY applied_at DESC;
```

## Common Migration Scenarios

### Adding a Column
```sql
ALTER TABLE table_name ADD COLUMN column_name data_type;
```

### Modifying a Column
```sql
ALTER TABLE table_name ALTER COLUMN column_name TYPE new_data_type;
```

### Adding an Index
```sql
CREATE INDEX idx_name ON table_name(column_name);
```

### Adding a Foreign Key
```sql
ALTER TABLE child_table 
ADD CONSTRAINT fk_name 
FOREIGN KEY (column_name) 
REFERENCES parent_table(id);
```

### Creating a View
```sql
CREATE OR REPLACE VIEW view_name AS
SELECT ... FROM ...;
```

## Troubleshooting

### Migration Failed
```bash
# Check which migrations have been applied
SELECT * FROM oyster.schema_version;

# Check migration tool status
flyway info

# Manual rollback if needed
psql -U oyster -d oyster_db
# Then manually undo the changes or restore from backup
```

### Migration Checksum Mismatch
This happens if a migration file was modified after being applied.

**Solution:** Never modify applied migrations. Create a new migration to fix issues.

### Database Out of Sync
```bash
# Validate schema
flyway validate

# Repair migration history (use with caution)
flyway repair
```
