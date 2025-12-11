-- =====================================================
-- Oyster Travel System - PostgreSQL Database Schema
-- =====================================================
-- Version: 1.0.0
-- Database: PostgreSQL 12+ (Tested with PostgreSQL 15)
-- Description: Complete database schema for the Oyster Travel System
-- Note: Compatible with PostgreSQL 12 and higher. Docker setup uses PostgreSQL 15.
-- =====================================================

-- Enable UUID extension for generating UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- SCHEMA CREATION
-- =====================================================

-- Create schema for the application
CREATE SCHEMA IF NOT EXISTS oyster;

-- Set search path to include oyster schema
SET search_path TO oyster, public;

-- =====================================================
-- TABLE: account
-- =====================================================
-- Stores customer account information
-- =====================================================

CREATE TABLE IF NOT EXISTS account (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_account_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_account_name CHECK (LENGTH(TRIM(name)) > 0)
);

COMMENT ON TABLE account IS 'Customer accounts in the Oyster travel system';
COMMENT ON COLUMN account.id IS 'Unique account identifier (UUID)';
COMMENT ON COLUMN account.email IS 'Customer email address (unique)';
COMMENT ON COLUMN account.name IS 'Customer full name';
COMMENT ON COLUMN account.created_at IS 'Account creation timestamp';

-- =====================================================
-- TABLE: card
-- =====================================================
-- Represents physical or virtual travel cards
-- =====================================================

CREATE TABLE IF NOT EXISTS card (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    issued_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_card_account FOREIGN KEY (account_id) 
        REFERENCES account(id) ON DELETE RESTRICT,
    
    -- Constraints
    CONSTRAINT chk_card_status CHECK (status IN ('Active', 'Blocked', 'Cancelled', 'Pending'))
);

COMMENT ON TABLE card IS 'Travel cards associated with customer accounts';
COMMENT ON COLUMN card.id IS 'Unique card identifier (UUID)';
COMMENT ON COLUMN card.account_id IS 'Reference to the owning account';
COMMENT ON COLUMN card.status IS 'Current card status (Active, Blocked, Cancelled, Pending)';
COMMENT ON COLUMN card.issued_at IS 'Card issuance timestamp';

-- =====================================================
-- TABLE: wallet
-- =====================================================
-- Stores monetary balance for each card
-- One-to-one relationship with card
-- =====================================================

CREATE TABLE IF NOT EXISTS wallet (
    card_id UUID PRIMARY KEY,
    balance NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    last_updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_wallet_card FOREIGN KEY (card_id) 
        REFERENCES card(id) ON DELETE RESTRICT,
    
    -- Constraints
    CONSTRAINT chk_wallet_balance_non_negative CHECK (balance >= 0),
    CONSTRAINT chk_wallet_balance_max CHECK (balance <= 500.00)
);

COMMENT ON TABLE wallet IS 'Monetary balances for travel cards';
COMMENT ON COLUMN wallet.card_id IS 'Reference to the card (one-to-one relationship)';
COMMENT ON COLUMN wallet.balance IS 'Current balance in pounds (0 to 500)';
COMMENT ON COLUMN wallet.last_updated IS 'Last balance modification timestamp';

-- =====================================================
-- TABLE: zone
-- =====================================================
-- Represents transport zones (1-9)
-- =====================================================

CREATE TABLE IF NOT EXISTS zone (
    number INTEGER PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    
    -- Constraints
    CONSTRAINT chk_zone_number CHECK (number BETWEEN 1 AND 9)
);

COMMENT ON TABLE zone IS 'Transport zones in the network (Zone 1-9)';
COMMENT ON COLUMN zone.number IS 'Zone number (1-9)';
COMMENT ON COLUMN zone.name IS 'Zone name (e.g., "Zone 1")';

-- =====================================================
-- TABLE: station
-- =====================================================
-- Represents transport stations in the network
-- =====================================================

CREATE TABLE IF NOT EXISTS station (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    
    -- Constraints
    CONSTRAINT chk_station_id CHECK (LENGTH(TRIM(id)) > 0),
    CONSTRAINT chk_station_name CHECK (LENGTH(TRIM(name)) > 0)
);

COMMENT ON TABLE station IS 'Transport stations in the network';
COMMENT ON COLUMN station.id IS 'Unique station identifier (kebab-case string)';
COMMENT ON COLUMN station.name IS 'Human-readable station name';

-- =====================================================
-- TABLE: station_zone
-- =====================================================
-- Junction table for many-to-many relationship
-- between stations and zones
-- =====================================================

CREATE TABLE IF NOT EXISTS station_zone (
    station_id VARCHAR(100) NOT NULL,
    zone_number INTEGER NOT NULL,
    
    -- Primary Key
    PRIMARY KEY (station_id, zone_number),
    
    -- Foreign Keys
    CONSTRAINT fk_station_zone_station FOREIGN KEY (station_id) 
        REFERENCES station(id) ON DELETE CASCADE,
    CONSTRAINT fk_station_zone_zone FOREIGN KEY (zone_number) 
        REFERENCES zone(number) ON DELETE CASCADE
);

COMMENT ON TABLE station_zone IS 'Many-to-many relationship between stations and zones';
COMMENT ON COLUMN station_zone.station_id IS 'Reference to station';
COMMENT ON COLUMN station_zone.zone_number IS 'Reference to zone';

-- =====================================================
-- TABLE: transaction
-- =====================================================
-- Records all financial transactions
-- =====================================================

CREATE TABLE IF NOT EXISTS transaction (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    card_id UUID NOT NULL,
    transaction_type VARCHAR(20) NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    balance_after NUMERIC(10, 2) NOT NULL,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    description TEXT,
    
    -- Foreign Keys
    CONSTRAINT fk_transaction_card FOREIGN KEY (card_id) 
        REFERENCES card(id) ON DELETE RESTRICT,
    
    -- Constraints
    CONSTRAINT chk_transaction_type CHECK (transaction_type IN ('TopUp', 'FareDeduction', 'Refund', 'PenaltyFare')),
    CONSTRAINT chk_transaction_amount CHECK (amount >= 0),
    CONSTRAINT chk_transaction_balance_after CHECK (balance_after >= 0)
);

COMMENT ON TABLE transaction IS 'Financial transactions for card wallets';
COMMENT ON COLUMN transaction.id IS 'Unique transaction identifier (UUID)';
COMMENT ON COLUMN transaction.card_id IS 'Reference to the card';
COMMENT ON COLUMN transaction.transaction_type IS 'Type of transaction (TopUp, FareDeduction, Refund, PenaltyFare)';
COMMENT ON COLUMN transaction.amount IS 'Transaction amount';
COMMENT ON COLUMN transaction.balance_after IS 'Balance after transaction (audit trail)';
COMMENT ON COLUMN transaction.timestamp IS 'When the transaction occurred';
COMMENT ON COLUMN transaction.description IS 'Human-readable description';

-- =====================================================
-- TABLE: journey
-- =====================================================
-- Tracks travel journeys from tap-in to tap-out
-- =====================================================

CREATE TABLE IF NOT EXISTS journey (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    card_id UUID NOT NULL,
    start_station_id VARCHAR(100) NOT NULL,
    end_station_id VARCHAR(100),
    tap_in_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tap_out_time TIMESTAMP,
    fare NUMERIC(10, 2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'InProgress',
    
    -- Foreign Keys
    CONSTRAINT fk_journey_card FOREIGN KEY (card_id) 
        REFERENCES card(id) ON DELETE RESTRICT,
    CONSTRAINT fk_journey_start_station FOREIGN KEY (start_station_id) 
        REFERENCES station(id) ON DELETE RESTRICT,
    CONSTRAINT fk_journey_end_station FOREIGN KEY (end_station_id) 
        REFERENCES station(id) ON DELETE RESTRICT,
    
    -- Constraints
    CONSTRAINT chk_journey_status CHECK (status IN ('InProgress', 'Completed', 'Incomplete')),
    CONSTRAINT chk_journey_fare CHECK (fare >= 0),
    CONSTRAINT chk_journey_times CHECK (tap_out_time IS NULL OR tap_out_time >= tap_in_time),
    CONSTRAINT chk_journey_completed CHECK (
        (status = 'Completed' AND end_station_id IS NOT NULL AND tap_out_time IS NOT NULL) OR
        (status = 'InProgress' AND end_station_id IS NULL AND tap_out_time IS NULL) OR
        (status = 'Incomplete')
    )
);

COMMENT ON TABLE journey IS 'Travel journeys from tap-in to tap-out';
COMMENT ON COLUMN journey.id IS 'Unique journey identifier (UUID)';
COMMENT ON COLUMN journey.card_id IS 'Reference to the card used';
COMMENT ON COLUMN journey.start_station_id IS 'Station where journey began';
COMMENT ON COLUMN journey.end_station_id IS 'Station where journey ended (NULL if incomplete)';
COMMENT ON COLUMN journey.tap_in_time IS 'When passenger tapped in';
COMMENT ON COLUMN journey.tap_out_time IS 'When passenger tapped out (NULL if in progress)';
COMMENT ON COLUMN journey.fare IS 'Actual fare charged';
COMMENT ON COLUMN journey.status IS 'Journey status (InProgress, Completed, Incomplete)';

-- =====================================================
-- INDEXES
-- =====================================================
-- Performance optimization indexes
-- =====================================================

-- Account indexes
CREATE INDEX idx_account_email ON account(email);
CREATE INDEX idx_account_created_at ON account(created_at);

-- Card indexes
CREATE INDEX idx_card_account_id ON card(account_id);
CREATE INDEX idx_card_status ON card(status);
CREATE INDEX idx_card_issued_at ON card(issued_at);

-- Transaction indexes
CREATE INDEX idx_transaction_card_id ON transaction(card_id);
CREATE INDEX idx_transaction_timestamp ON transaction(timestamp);
CREATE INDEX idx_transaction_type ON transaction(transaction_type);

-- Journey indexes
CREATE INDEX idx_journey_card_id ON journey(card_id);
CREATE INDEX idx_journey_status ON journey(status);
CREATE INDEX idx_journey_start_station ON journey(start_station_id);
CREATE INDEX idx_journey_end_station ON journey(end_station_id);
CREATE INDEX idx_journey_tap_in_time ON journey(tap_in_time);

-- Station zone indexes
CREATE INDEX idx_station_zone_station ON station_zone(station_id);
CREATE INDEX idx_station_zone_zone ON station_zone(zone_number);

-- =====================================================
-- SEED DATA
-- =====================================================
-- Initial data for zones and stations
-- =====================================================

-- Insert zones (1-9)
INSERT INTO zone (number, name) VALUES
    (1, 'Zone 1'),
    (2, 'Zone 2'),
    (3, 'Zone 3'),
    (4, 'Zone 4'),
    (5, 'Zone 5'),
    (6, 'Zone 6'),
    (7, 'Zone 7'),
    (8, 'Zone 8'),
    (9, 'Zone 9')
ON CONFLICT (number) DO NOTHING;

-- Insert sample stations
INSERT INTO station (id, name) VALUES
    ('kings-cross', 'King''s Cross St. Pancras'),
    ('holborn', 'Holborn'),
    ('earls-court', 'Earl''s Court'),
    ('wimbledon', 'Wimbledon'),
    ('hammersmith', 'Hammersmith')
ON CONFLICT (id) DO NOTHING;

-- Insert station-zone relationships
INSERT INTO station_zone (station_id, zone_number) VALUES
    ('kings-cross', 1),
    ('holborn', 1),
    ('earls-court', 1),
    ('earls-court', 2),  -- Earl's Court spans two zones
    ('wimbledon', 3),
    ('hammersmith', 2)
ON CONFLICT (station_id, zone_number) DO NOTHING;

-- =====================================================
-- FUNCTIONS AND TRIGGERS
-- =====================================================

-- Function to automatically update wallet.last_updated
CREATE OR REPLACE FUNCTION update_wallet_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for wallet updates
CREATE TRIGGER trg_wallet_update_timestamp
    BEFORE UPDATE ON wallet
    FOR EACH ROW
    EXECUTE FUNCTION update_wallet_timestamp();

-- =====================================================
-- VIEWS
-- =====================================================
-- Useful views for common queries
-- =====================================================

-- View: Active cards with wallet information
CREATE OR REPLACE VIEW v_active_cards AS
SELECT 
    c.id AS card_id,
    c.account_id,
    a.email,
    a.name AS account_name,
    c.status,
    c.issued_at,
    w.balance,
    w.last_updated AS wallet_last_updated
FROM card c
INNER JOIN account a ON c.account_id = a.id
LEFT JOIN wallet w ON c.id = w.card_id
WHERE c.status = 'Active';

COMMENT ON VIEW v_active_cards IS 'Active cards with account and wallet information';

-- View: Journey summary with station names
CREATE OR REPLACE VIEW v_journey_summary AS
SELECT 
    j.id AS journey_id,
    j.card_id,
    j.status,
    s1.name AS start_station,
    s2.name AS end_station,
    j.tap_in_time,
    j.tap_out_time,
    j.fare,
    EXTRACT(EPOCH FROM (j.tap_out_time - j.tap_in_time))/60 AS duration_minutes
FROM journey j
INNER JOIN station s1 ON j.start_station_id = s1.id
LEFT JOIN station s2 ON j.end_station_id = s2.id;

COMMENT ON VIEW v_journey_summary IS 'Journey details with station names and duration';

-- View: Transaction history with card information
CREATE OR REPLACE VIEW v_transaction_history AS
SELECT 
    t.id AS transaction_id,
    t.card_id,
    a.email,
    a.name AS account_name,
    t.transaction_type,
    t.amount,
    t.balance_after,
    t.timestamp,
    t.description
FROM transaction t
INNER JOIN card c ON t.card_id = c.id
INNER JOIN account a ON c.account_id = a.id
ORDER BY t.timestamp DESC;

COMMENT ON VIEW v_transaction_history IS 'Transaction history with account information';

-- View: Low balance alerts (balance < £5.00)
CREATE OR REPLACE VIEW v_low_balance_alerts AS
SELECT 
    c.id AS card_id,
    a.email,
    a.name AS account_name,
    w.balance,
    w.last_updated
FROM card c
INNER JOIN account a ON c.account_id = a.id
INNER JOIN wallet w ON c.id = w.card_id
WHERE c.status = 'Active' 
  AND w.balance < 5.00
ORDER BY w.balance ASC;

COMMENT ON VIEW v_low_balance_alerts IS 'Active cards with low balance (< £5.00)';

-- =====================================================
-- GRANTS
-- =====================================================
-- Grant permissions to application user
-- Replace 'oyster_app' with your application user
-- =====================================================

-- Create application user if it doesn't exist
-- DO $$
-- BEGIN
--     IF NOT EXISTS (SELECT FROM pg_user WHERE usename = 'oyster_app') THEN
--         CREATE USER oyster_app WITH PASSWORD 'change_me_in_production';
--     END IF;
-- END
-- $$;

-- Grant schema usage
-- GRANT USAGE ON SCHEMA oyster TO oyster_app;

-- Grant table permissions
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA oyster TO oyster_app;

-- Grant sequence permissions (for auto-incrementing columns)
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA oyster TO oyster_app;

-- Grant view permissions
-- GRANT SELECT ON ALL TABLES IN SCHEMA oyster TO oyster_app;

-- =====================================================
-- SCHEMA VERSION
-- =====================================================

CREATE TABLE IF NOT EXISTS schema_version (
    version VARCHAR(20) PRIMARY KEY,
    applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    description TEXT
);

INSERT INTO schema_version (version, description) VALUES
    ('1.0.0', 'Initial schema creation with all core tables, indexes, and views')
ON CONFLICT (version) DO NOTHING;

-- =====================================================
-- END OF SCHEMA
-- =====================================================
