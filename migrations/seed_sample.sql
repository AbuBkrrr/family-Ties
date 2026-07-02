-- migrations/seed_sample.sql
-- Insert sample family and users for local development/testing

-- Create a sample family
INSERT INTO families (family_id, family_name, public_mission)
VALUES (gen_random_uuid(), 'Sample Family', 'Keeping memories and stories across generations')
RETURNING family_id;

-- Use the returned family_id or fetch it
-- For simplicity, fetch the family_id we just inserted

-- NOTE: When running via psql you can capture the family_id; here we will perform simple inserts referencing the family by name

-- Create two houses
INSERT INTO houses (house_id, family_id, house_name, location_city, location_country)
SELECT gen_random_uuid(), f.family_id, 'London House', 'London', 'United Kingdom'
FROM families f WHERE f.family_name = 'Sample Family'
ON CONFLICT DO NOTHING;

INSERT INTO houses (house_id, family_id, house_name, location_city, location_country)
SELECT gen_random_uuid(), f.family_id, 'New York House', 'New York', 'United States'
FROM families f WHERE f.family_name = 'Sample Family'
ON CONFLICT DO NOTHING;

-- Create sample users
INSERT INTO users (user_id, email, full_name, birth_date, location_city, location_country, family_id, is_elder)
SELECT gen_random_uuid(), 'john@example.com', 'John Sample', '1950-06-15', 'London', 'United Kingdom', f.family_id, true
FROM families f WHERE f.family_name = 'Sample Family'
ON CONFLICT (email) DO NOTHING;

INSERT INTO users (user_id, email, full_name, birth_date, location_city, location_country, family_id)
SELECT gen_random_uuid(), 'mary@example.com', 'Mary Sample', '1955-09-02', 'London', 'United Kingdom', f.family_id
FROM families f WHERE f.family_name = 'Sample Family'
ON CONFLICT (email) DO NOTHING;

INSERT INTO users (user_id, email, full_name, birth_date, location_city, location_country, family_id)
SELECT gen_random_uuid(), 'olivia@example.com', 'Olivia Sample', '1990-03-22', 'New York', 'United States', f.family_id
FROM families f WHERE f.family_name = 'Sample Family'
ON CONFLICT (email) DO NOTHING;

-- Create person_details records for each user
INSERT INTO person_details (person_id, user_id, info)
SELECT gen_random_uuid(), u.user_id, jsonb_build_object('bio', 'Seeded user', 'traits', jsonb_build_object())
FROM users u
WHERE u.email IN ('john@example.com', 'mary@example.com', 'olivia@example.com')
ON CONFLICT DO NOTHING;

-- Create relationships: John & Mary spouses; John -> Olivia child
WITH
  p AS (
    SELECT pd.person_id, u.email
    FROM person_details pd
    JOIN users u ON u.user_id = pd.user_id
    WHERE u.email IN ('john@example.com','mary@example.com','olivia@example.com')
  )
INSERT INTO family_relationships (c1, c2, prop)
SELECT p1.person_id, p2.person_id, ARRAY[5]::SMALLINT[]
FROM p p1 JOIN p p2 ON p1.email = 'john@example.com' AND p2.email = 'mary@example.com'
ON CONFLICT DO NOTHING;

INSERT INTO family_relationships (c1, c2, prop)
SELECT p1.person_id, p2.person_id, ARRAY[6]::SMALLINT[]
FROM p p1 JOIN p p2 ON p1.email = 'john@example.com' AND p2.email = 'olivia@example.com'
ON CONFLICT DO NOTHING;

-- End of seed file
