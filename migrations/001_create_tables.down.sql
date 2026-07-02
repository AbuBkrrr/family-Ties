-- migrations/001_create_tables.down.sql
-- Raw SQL migrations for Family Ties (down) - drops created objects

DROP FUNCTION IF EXISTS get_family_tree(UUID, INT, BIGINT) CASCADE;

DROP TABLE IF EXISTS competition_entries CASCADE;
DROP TABLE IF EXISTS competitions CASCADE;
DROP TABLE IF EXISTS private_messages CASCADE;
DROP TABLE IF EXISTS group_messages CASCADE;
DROP TABLE IF EXISTS paper_tree_scans CASCADE;
DROP TABLE IF EXISTS death_revelations CASCADE;
DROP TABLE IF EXISTS ai_twin_models CASCADE;
DROP TABLE IF EXISTS ai_training_data CASCADE;
DROP TABLE IF EXISTS biometric_traits CASCADE;
DROP TABLE IF EXISTS family_relationships CASCADE;
DROP TABLE IF EXISTS relationship_desc CASCADE;
DROP TABLE IF EXISTS person_details CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS houses CASCADE;
DROP TABLE IF EXISTS families CASCADE;

-- Note: extension pgcrypto left as-is (shared extension)
