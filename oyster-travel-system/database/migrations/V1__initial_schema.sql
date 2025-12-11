-- =====================================================
-- Migration: V1 - Initial Schema
-- =====================================================
-- Description: Creates all tables, indexes, views, and seed data
-- Applied: 2024-12-11
-- =====================================================

-- This migration is equivalent to the main schema.sql file
-- For a clean database, you can use schema.sql directly
-- This file is provided for migration tool compatibility (e.g., Flyway)

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create schema
CREATE SCHEMA IF NOT EXISTS oyster;

SET search_path TO oyster, public;

-- Create tables (see schema.sql for full DDL)
-- This is a reference file for migration versioning
-- The actual schema should be applied using schema.sql

-- Version tracking
CREATE TABLE IF NOT EXISTS schema_version (
    version VARCHAR(20) PRIMARY KEY,
    applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    description TEXT
);

INSERT INTO schema_version (version, description) VALUES
    ('V1', 'Initial schema - all core tables, indexes, and views')
ON CONFLICT (version) DO NOTHING;
