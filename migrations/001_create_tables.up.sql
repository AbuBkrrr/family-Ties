-- migrations/001_create_tables.up.sql
-- Raw SQL migrations for Family Ties (up)

-- Extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Families table
CREATE TABLE IF NOT EXISTS families (
    family_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_name VARCHAR(255) NOT NULL,
    public_mission TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Houses (geographic sub-clans)
CREATE TABLE IF NOT EXISTS houses (
    house_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID REFERENCES families(family_id) ON DELETE CASCADE,
    house_name VARCHAR(255) NOT NULL,
    location_city VARCHAR(100),
    location_country VARCHAR(100),
    mascot_avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Users table
CREATE TABLE IF NOT EXISTS users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20) UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    birth_date DATE,
    location_city VARCHAR(100),
    location_country VARCHAR(100),
    family_id UUID REFERENCES families(family_id),
    house_id UUID REFERENCES houses(house_id),
    is_elder BOOLEAN DEFAULT FALSE,
    is_deceased BOOLEAN DEFAULT FALSE,
    death_confirmed BOOLEAN DEFAULT FALSE,
    death_confirmed_by UUID[] DEFAULT '{}',
    ai_twin_active BOOLEAN DEFAULT FALSE,
    ai_twin_opt_in BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Person details (nodes in the family graph)
CREATE TABLE IF NOT EXISTS person_details (
    person_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id),
    info JSONB,
    crt_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Relationship descriptors
CREATE TABLE IF NOT EXISTS relationship_desc (
    rel_id SMALLINT PRIMARY KEY,
    rel_name VARCHAR(50) NOT NULL
);

-- Family relationships (graph edges) - bidirectional storage
CREATE TABLE IF NOT EXISTS family_relationships (
    c1 UUID REFERENCES person_details(person_id) ON DELETE CASCADE,
    c2 UUID REFERENCES person_details(person_id) ON DELETE CASCADE,
    prop SMALLINT[],
    crt_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CHECK (c1 IS DISTINCT FROM c2),
    UNIQUE (c1, c2)
);

CREATE INDEX IF NOT EXISTS idx_family_rel_c1 ON family_relationships(c1);
CREATE INDEX IF NOT EXISTS idx_family_rel_c2 ON family_relationships(c2);

-- Biometric traits
CREATE TABLE IF NOT EXISTS biometric_traits (
    trait_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    trait_type VARCHAR(50) CHECK (trait_type IN ('face', 'hand', 'height')),
    feature_vector BYTEA,
    landmark_data JSONB,
    confidence_score FLOAT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- AI training data
CREATE TABLE IF NOT EXISTS ai_training_data (
    data_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    source_type VARCHAR(50) CHECK (source_type IN ('social_media', 'email', 'journal', 'voice', 'photo', 'video', 'chat', 'family_ties')),
    source_platform VARCHAR(100),
    content_text TEXT,
    content_url TEXT,
    content_metadata JSONB,
    processed_for_ai BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- AI twin models
CREATE TABLE IF NOT EXISTS ai_twin_models (
    model_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id) UNIQUE,
    llm_model_path TEXT,
    voice_clone_path TEXT,
    face_model_path TEXT,
    training_status VARCHAR(20) DEFAULT 'training',
    last_trained_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Death revelations
CREATE TABLE IF NOT EXISTS death_revelations (
    revelation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    revelation_type VARCHAR(50) CHECK (revelation_type IN ('will', 'gift', 'secret', 'debt', 'advice')),
    recipient_user_id UUID REFERENCES users(user_id),
    content_text TEXT,
    content_attachments TEXT[],
    is_released BOOLEAN DEFAULT FALSE,
    release_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Paper tree scans
CREATE TABLE IF NOT EXISTS paper_tree_scans (
    scan_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID REFERENCES families(family_id),
    uploaded_by UUID REFERENCES users(user_id),
    scan_url TEXT,
    scan_pages INT,
    ocr_status VARCHAR(20) DEFAULT 'pending',
    extracted_data JSONB,
    mapped_tree JSONB,
    confidence_score FLOAT,
    imported BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Messaging
CREATE TABLE IF NOT EXISTS private_messages (
    msg_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID REFERENCES users(user_id),
    recipient_id UUID REFERENCES users(user_id),
    encrypted_content BYTEA NOT NULL,
    message_type VARCHAR(20) DEFAULT 'text' CHECK (message_type IN ('text', 'voice', 'image', 'video')),
    attachment_url TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS group_messages (
    msg_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID REFERENCES users(user_id),
    chat_room_id VARCHAR(100),
    content TEXT,
    message_type VARCHAR(20) DEFAULT 'text',
    attachment_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_private_msgs_recipient ON private_messages(recipient_id);
CREATE INDEX IF NOT EXISTS idx_private_msgs_created ON private_messages(created_at DESC);

-- Competitions
CREATE TABLE IF NOT EXISTS competitions (
    comp_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    comp_name VARCHAR(255) NOT NULL,
    comp_type VARCHAR(50) CHECK (comp_type IN ('skill_sprint', 'memory_heirloom', 'craft_build', 'clan_marathon', 'game_night', 'trivia_showdown')),
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE,
    description TEXT,
    status VARCHAR(20) DEFAULT 'upcoming',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS competition_entries (
    entry_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    comp_id UUID REFERENCES competitions(comp_id),
    house_id UUID REFERENCES houses(house_id),
    user_id UUID REFERENCES users(user_id),
    score FLOAT,
    rank INT,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Relationship descriptors seed (if empty)
INSERT INTO relationship_desc (rel_id, rel_name)
SELECT * FROM (VALUES
  (1, 'father'),
  (2, 'mother'),
  (3, 'brother'),
  (4, 'sister'),
  (5, 'spouse'),
  (6, 'child')
) AS v(rel_id, rel_name)
ON CONFLICT (rel_id) DO NOTHING;

-- Function to traverse the family tree using recursive CTE
CREATE OR REPLACE FUNCTION get_family_tree(
    root_id UUID,
    max_depth INT DEFAULT 99,
    limit_per_level BIGINT DEFAULT 2000000000
)
RETURNS TABLE(
    path UUID[],
    point1 UUID,
    point2 UUID,
    link_prop SMALLINT[],
    depth INT
) AS $$
BEGIN
    RETURN QUERY EXECUTE format($f$
        WITH RECURSIVE search_graph AS (
            SELECT g.c1, g.c2, g.prop, 1 depth, ARRAY[g.c1, g.c2] path
            FROM family_relationships g
            WHERE g.c1 = %L
            LIMIT %s
            UNION ALL
            SELECT g.c1, g.c2, g.prop, sg.depth + 1, sg.path || g.c2
            FROM family_relationships g, search_graph sg
            WHERE g.c1 = sg.c2
              AND NOT (g.c2 = ANY(sg.path))
              AND sg.depth <= %s
            LIMIT %s
        )
        SELECT path, c1, c2, prop, depth FROM search_graph
    $f$, root_id::text, limit_per_level, max_depth, limit_per_level);
END;
$$ LANGUAGE plpgsql STABLE;

-- VACUUM ANALYZE to update planner stats
ANALYZE;
