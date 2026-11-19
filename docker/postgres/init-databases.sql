-- ============================================================================
-- Prism Hub — Shared PostgreSQL 16 Initialization Script
-- Runs automatically when Docker creates a fresh database volume.
-- Idempotently creates isolated databases for all Prism Hub microservices.
-- ============================================================================

SELECT 'CREATE DATABASE wonderlab'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'wonderlab')\gexec

SELECT 'CREATE DATABASE central_gateway'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'central_gateway')\gexec

SELECT 'CREATE DATABASE git_pulse'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'git_pulse')\gexec
