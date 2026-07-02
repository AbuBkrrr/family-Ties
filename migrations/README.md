Migrations - README

This directory contains raw SQL migrations for the Family Ties project. The project uses plain SQL up/down files so they can be applied with psql or integrated with any migration runner.

Files:
- 001_create_tables.up.sql    -- creates schema, extensions, and helper functions
- 001_create_tables.down.sql  -- drops schema objects created by the up script
- seed_sample.sql             -- small seed dataset for local development

How to apply (local Docker Compose):

1) Ensure docker-compose is running (services: postgres)

   docker-compose up -d postgres

2) Apply the migration using psql inside the postgres container:

   docker-compose exec postgres bash -c "psql -U $${POSTGRES_USER} -d $${POSTGRES_DB} -f /var/lib/postgresql/data/migrations/001_create_tables.up.sql"

Note: The docker-compose.yml in the repository mounts ./migrations into /docker-entrypoint-initdb.d which will automatically run *.sql files the first time the container initializes the database. If you need to re-run migrations against an existing DB, use the psql command above.

3) Seed sample data (optional):

   docker-compose exec postgres bash -c "psql -U $${POSTGRES_USER} -d $${POSTGRES_DB} -f /var/lib/postgresql/data/migrations/seed_sample.sql"

4) To rollback the schema (down script):

   docker-compose exec postgres bash -c "psql -U $${POSTGRES_USER} -d $${POSTGRES_DB} -f /var/lib/postgresql/data/migrations/001_create_tables.down.sql"

Notes:
- These SQL files assume the pgcrypto extension is available. The up script will create the extension if allowed by the Postgres user. When running in managed DBs you may need to enable the extension separately.
- For repeatable development you may need to remove the postgres volume (postgres_data) or run against a fresh DB to allow the init scripts to execute.
