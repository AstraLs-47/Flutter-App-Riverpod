-- PurePulse Database Schema


-- Users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    role VARCHAR(20) DEFAULT 'user' CHECK (role IN ('user', 'admin')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User profiles table
CREATE TABLE IF NOT EXISTS user_profiles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    age INTEGER,
    gender VARCHAR(20),
    goal VARCHAR(50) CHECK (goal IN ('lose weight', 'gain weight', 'gain muscle', 'manage stress', 'maintain weight')),
    activity_level VARCHAR(20) CHECK (activity_level IN ('Active', 'Very Active', 'Lightly Active', 'Not active')),
    date_of_birth DATE,
    height DECIMAL(5,2),
    current_weight DECIMAL(6,2),
    goal_weight DECIMAL(6,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

-- Categories table
CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) DEFAULT 'general' CHECK (type IN ('general', 'exercise', 'product')),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Exercises table
CREATE TABLE IF NOT EXISTS exercises (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    image_url VARCHAR(500),
    category_id INTEGER REFERENCES categories(id) ON DELETE SET NULL,
    difficulty VARCHAR(50),
    warmup TEXT,
    main_workout TEXT,
    rest TEXT,
    duration VARCHAR(50),
    calories_per_minute DECIMAL(6,2),
    phases JSONB,
    created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Progress entries table
CREATE TABLE IF NOT EXISTS progress_entries (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    exercise_id INTEGER REFERENCES exercises(id) ON DELETE SET NULL,
    exercise_name VARCHAR(200),
    entry_date DATE DEFAULT CURRENT_DATE,
    duration_minutes INTEGER,
    sets INTEGER,
    reps INTEGER,
    weight DECIMAL(6,2),
    intensity VARCHAR(20) CHECK (intensity IN ('light', 'moderate', 'intense')),
    mood VARCHAR(50),
    notes TEXT,
    achievement TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Health metrics table
ALTER TABLE IF EXISTS health_metrics DROP CONSTRAINT IF EXISTS health_metrics_user_id_date_key;
ALTER TABLE IF EXISTS health_metrics DROP COLUMN IF EXISTS body_fat_percentage, DROP COLUMN IF EXISTS muscle_mass, DROP COLUMN IF EXISTS water_percentage;
CREATE TABLE IF NOT EXISTS health_metrics (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    date DATE DEFAULT CURRENT_DATE,
    weight DECIMAL(6,2),
    height DECIMAL(5,2),
    bmi DECIMAL(4,2),
    resting_heart_rate INTEGER,
    blood_pressure_systolic INTEGER,
    blood_pressure_diastolic INTEGER,
    blood_sugar DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products table
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT true,
    created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Announcements table
CREATE TABLE IF NOT EXISTS announcements (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    date DATE DEFAULT CURRENT_DATE,
    created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Activity log table (for admin analytics)
CREATE TABLE IF NOT EXISTS activity_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id INTEGER,
    metadata JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_exercises_category ON exercises(category_id);
CREATE INDEX IF NOT EXISTS idx_progress_user_date ON progress_entries(user_id, entry_date);
CREATE INDEX IF NOT EXISTS idx_health_user_date ON health_metrics(user_id, date);
CREATE INDEX IF NOT EXISTS idx_activity_logs_user ON activity_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_activity_logs_created ON activity_logs(created_at);

-- Insert default admin user (password: admin123)
-- Note: In production, use a properly hashed password
INSERT INTO users (email, password_hash, first_name, last_name, role)
VALUES ('ADMIN_EMAIL_PLACEHOLDER', 'ADMIN_PASSWORD_PLACEHOLDER', NULL, NULL, 'admin')
ON CONFLICT (email) DO NOTHING;
