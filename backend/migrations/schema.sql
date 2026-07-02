-- Family Ties Database Schema
-- Core tables for user management, family tree, biometrics, and AI features

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Users table
CREATE TABLE IF NOT EXISTS users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    birth_date DATE,
    location_city VARCHAR(100),
    location_country VARCHAR(100),
    family_id UUID REFERENCES families(family_id),
    house_id UUID REFERENCES houses(house_id),
    bio TEXT,
    avatar_url TEXT,
    is_elder BOOLEAN DEFAULT FALSE,
    is_deceased BOOLEAN DEFAULT FALSE,
    death_confirmed BOOLEAN DEFAULT FALSE,
    death_confirmed_by UUID[] DEFAULT '{}',
    ai_twin_active BOOLEAN DEFAULT FALSE,
    ai_twin_opt_in BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_family_id ON users(family_id);
CREATE INDEX idx_users_house_id ON users(house_id);
CREATE INDEX idx_users_is_deceased ON users(is_deceased);

-- Families table
CREATE TABLE IF NOT EXISTS families (
    family_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_name VARCHAR(255) NOT NULL,
    public_mission TEXT,
    founder_id UUID REFERENCES users(user_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_families_founder ON families(founder_id);

-- Houses (geographic sub-clans)
CREATE TABLE IF NOT EXISTS houses (
    house_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID REFERENCES families(family_id) ON DELETE CASCADE,
    house_name VARCHAR(255) NOT NULL,
    location_city VARCHAR(100),
    location_country VARCHAR(100),
    mascot_avatar_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_houses_family_id ON houses(family_id);

-- Person details (genealogy)
CREATE TABLE IF NOT EXISTS person_details (
    person_id BIGSERIAL PRIMARY KEY,
    user_id UUID UNIQUE REFERENCES users(user_id) ON DELETE CASCADE,
    info JSONB DEFAULT '{}',
    traits JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_person_user_id ON person_details(user_id);

-- Relationship descriptors
CREATE TABLE IF NOT EXISTS relationship_desc (
    rel_id SMALLINT PRIMARY KEY,
    rel_name VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO relationship_desc (rel_id, rel_name) VALUES
(1, 'father'),
(2, 'mother'),
(3, 'brother'),
(4, 'sister'),
(5, 'son'),
(6, 'daughter'),
(7, 'spouse'),
(8, 'grandparent'),
(9, 'grandchild'),
(10, 'uncle'),
(11, 'aunt'),
(12, 'cousin'),
(13, 'niece'),
(14, 'nephew')
ON CONFLICT DO NOTHING;

-- Family relationships (bidirectional)
CREATE TABLE IF NOT EXISTS family_relationships (
    c1 BIGINT REFERENCES person_details(person_id),
    c2 BIGINT REFERENCES person_details(person_id),
    prop SMALLINT[] DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (c1 <> c2),
    UNIQUE (c1, c2)
);

CREATE INDEX idx_family_rel_c1 ON family_relationships(c1);
CREATE INDEX idx_family_rel_c2 ON family_relationships(c2);

-- Biometric traits (encrypted)
CREATE TABLE IF NOT EXISTS biometric_traits (
    trait_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    trait_type VARCHAR(50) CHECK (trait_type IN ('face', 'hand', 'height')),
    feature_vector BYTEA,
    landmark_data JSONB,
    confidence_score FLOAT DEFAULT 0.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_biometric_user_id ON biometric_traits(user_id);
CREATE INDEX idx_biometric_type ON biometric_traits(trait_type);

-- AI training data sources
CREATE TABLE IF NOT EXISTS ai_training_data (
    data_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    source_type VARCHAR(50) CHECK (source_type IN ('social_media', 'email', 'journal', 'voice', 'photo', 'video', 'chat', 'family_ties')),
    source_platform VARCHAR(100),
    content_text TEXT,
    content_url TEXT,
    content_metadata JSONB DEFAULT '{}',
    processed_for_ai BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ai_training_user_id ON ai_training_data(user_id);
CREATE INDEX idx_ai_training_source ON ai_training_data(source_type);
CREATE INDEX idx_ai_training_processed ON ai_training_data(processed_for_ai);

-- AI twin models
CREATE TABLE IF NOT EXISTS ai_twin_models (
    model_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE REFERENCES users(user_id),
    llm_model_path TEXT,
    voice_clone_path TEXT,
    face_model_path TEXT,
    training_status VARCHAR(20) DEFAULT 'idle' CHECK (training_status IN ('idle', 'training', 'active', 'failed')),
    last_trained_at TIMESTAMP,
    training_data_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ai_models_user_id ON ai_twin_models(user_id);

-- Post-death revelations
CREATE TABLE IF NOT EXISTS death_revelations (
    revelation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    revelation_type VARCHAR(50) CHECK (revelation_type IN ('will', 'gift', 'secret', 'debt', 'advice')),
    recipient_user_id UUID REFERENCES users(user_id),
    content_text TEXT NOT NULL,
    content_attachments TEXT[],
    is_released BOOLEAN DEFAULT FALSE,
    release_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_revelations_user_id ON death_revelations(user_id);
CREATE INDEX idx_revelations_recipient ON death_revelations(recipient_user_id);
CREATE INDEX idx_revelations_released ON death_revelations(is_released);

-- Paper family tree scans
CREATE TABLE IF NOT EXISTS paper_tree_scans (
    scan_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID REFERENCES families(family_id),
    uploaded_by UUID REFERENCES users(user_id),
    scan_url TEXT NOT NULL,
    scan_pages INT DEFAULT 1,
    ocr_status VARCHAR(20) DEFAULT 'pending' CHECK (ocr_status IN ('pending', 'processing', 'completed', 'failed')),
    extracted_data JSONB DEFAULT '{}',
    mapped_tree JSONB DEFAULT '{}',
    confidence_score FLOAT DEFAULT 0.0,
    imported BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_paper_scans_family ON paper_tree_scans(family_id);
CREATE INDEX idx_paper_scans_status ON paper_tree_scans(ocr_status);

-- Private messages (E2EE)
CREATE TABLE IF NOT EXISTS private_messages (
    msg_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID REFERENCES users(user_id),
    recipient_id UUID REFERENCES users(user_id),
    encrypted_content BYTEA NOT NULL,
    message_type VARCHAR(20) DEFAULT 'text' CHECK (message_type IN ('text', 'voice', 'image', 'video')),
    attachment_url TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_private_msgs_recipient ON private_messages(recipient_id);
CREATE INDEX idx_private_msgs_sender ON private_messages(sender_id);
CREATE INDEX idx_private_msgs_created ON private_messages(created_at DESC);

-- Group messages
CREATE TABLE IF NOT EXISTS group_messages (
    msg_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID REFERENCES users(user_id),
    chat_room_id VARCHAR(100),
    content TEXT,
    message_type VARCHAR(20) DEFAULT 'text',
    attachment_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_group_msgs_room ON group_messages(chat_room_id);
CREATE INDEX idx_group_msgs_sender ON group_messages(sender_id);
CREATE INDEX idx_group_msgs_created ON group_messages(created_at DESC);

-- Competitions
CREATE TABLE IF NOT EXISTS competitions (
    comp_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    comp_name VARCHAR(255) NOT NULL,
    comp_type VARCHAR(50) CHECK (comp_type IN ('skill_sprint', 'memory_heirloom', 'craft_build', 'clan_marathon', 'game_night', 'trivia_showdown')),
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    description TEXT,
    status VARCHAR(20) DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'active', 'completed', 'cancelled')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_competitions_status ON competitions(status);

-- Competition entries
CREATE TABLE IF NOT EXISTS competition_entries (
    entry_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    comp_id UUID REFERENCES competitions(comp_id),
    house_id UUID REFERENCES houses(house_id),
    user_id UUID REFERENCES users(user_id),
    score FLOAT DEFAULT 0.0,
    rank INT,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_comp_entries_comp ON competition_entries(comp_id);
CREATE INDEX idx_comp_entries_user ON competition_entries(user_id);

-- Photo album
CREATE TABLE IF NOT EXISTS family_photos (
    photo_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID REFERENCES families(family_id),
    uploaded_by UUID REFERENCES users(user_id),
    photo_url TEXT NOT NULL,
    title VARCHAR(255),
    description TEXT,
    taken_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_photos_family ON family_photos(family_id);
CREATE INDEX idx_photos_uploader ON family_photos(uploaded_by);

-- Sessions for auth
CREATE TABLE IF NOT EXISTS sessions (
    session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id),
    refresh_token TEXT UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_expires ON sessions(expires_at);

-- Audit log
CREATE TABLE IF NOT EXISTS audit_logs (
    log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id),
    action VARCHAR(100),
    resource_type VARCHAR(100),
    resource_id VARCHAR(100),
    changes JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_created ON audit_logs(created_at DESC);
