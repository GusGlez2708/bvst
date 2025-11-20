-- =====================================================
-- BVST Game - Complete Database Schema
-- =====================================================
-- This script creates the entire database structure from scratch
-- for the BVST game including user management, authentication,
-- game state, and shop system.

-- =====================================================
-- 1. ENABLE REQUIRED EXTENSIONS
-- =====================================================

-- Enable UUID generation (if not already enabled)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable pg_crypto for password hashing (if needed)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- 2. CREATE USERS TABLE
-- =====================================================

-- Drop table if exists (CAUTION: This will delete all data!)
-- Uncomment the line below ONLY if you want to start fresh
-- DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE IF NOT EXISTS users (
  -- Primary key - uses Supabase auth user ID
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- User profile information
  username TEXT UNIQUE NOT NULL,
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Game statistics
  total_games_played INTEGER DEFAULT 0,
  total_wins INTEGER DEFAULT 0,
  total_losses INTEGER DEFAULT 0,
  highest_level_completed INTEGER DEFAULT 0,
  
  -- Shop and currency system
  coins INTEGER DEFAULT 0 CHECK (coins >= 0),
  has_double_shot BOOLEAN DEFAULT FALSE,
  extra_hearts_purchased INTEGER DEFAULT 0 CHECK (extra_hearts_purchased >= 0),
  
  -- Player preferences
  sound_enabled BOOLEAN DEFAULT TRUE,
  music_enabled BOOLEAN DEFAULT TRUE,
  music_volume REAL DEFAULT 0.7 CHECK (music_volume >= 0 AND music_volume <= 1),
  sfx_volume REAL DEFAULT 0.7 CHECK (sfx_volume >= 0 AND sfx_volume <= 1),
  
  -- Metadata
  last_login TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN DEFAULT TRUE
);

-- =====================================================
-- 3. CREATE INDEXES FOR PERFORMANCE
-- =====================================================

-- Index on username for fast lookups
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);

-- Index on email for fast lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Index on coins for leaderboard queries
CREATE INDEX IF NOT EXISTS idx_users_coins ON users(coins DESC);

-- Index on total wins for leaderboard queries
CREATE INDEX IF NOT EXISTS idx_users_wins ON users(total_wins DESC);

-- Index on created_at for sorting by registration date
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at DESC);

-- =====================================================
-- 4. CREATE TRIGGERS FOR AUTOMATIC UPDATES
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update updated_at
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 5. SHOP SYSTEM FUNCTIONS
-- =====================================================

-- Function to safely add coins to a user
CREATE OR REPLACE FUNCTION add_coins(user_id UUID, amount INTEGER)
RETURNS INTEGER AS $$
DECLARE
  new_balance INTEGER;
BEGIN
  -- Validate amount is positive
  IF amount < 0 THEN
    RAISE EXCEPTION 'Amount must be positive';
  END IF;

  -- Update coins and return new balance
  UPDATE users 
  SET coins = coins + amount,
      updated_at = NOW()
  WHERE id = user_id
  RETURNING coins INTO new_balance;
  
  -- Check if user exists
  IF new_balance IS NULL THEN
    RAISE EXCEPTION 'User not found';
  END IF;
  
  RETURN new_balance;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to purchase items from shop
CREATE OR REPLACE FUNCTION purchase_item(
  user_id UUID, 
  item_cost INTEGER,
  item_type TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
  current_coins INTEGER;
  current_double_shot BOOLEAN;
  current_extra_hearts INTEGER;
  purchase_successful BOOLEAN := FALSE;
BEGIN
  -- Get current user state
  SELECT coins, has_double_shot, extra_hearts_purchased 
  INTO current_coins, current_double_shot, current_extra_hearts
  FROM users 
  WHERE id = user_id;
  
  -- Check if user exists
  IF current_coins IS NULL THEN
    RAISE EXCEPTION 'User not found';
  END IF;
  
  -- Validate item cost
  IF item_cost < 0 THEN
    RAISE EXCEPTION 'Item cost must be positive';
  END IF;
  
  -- Check if user has enough coins
  IF current_coins >= item_cost THEN
    -- Process purchase based on item type
    IF item_type = 'double_shot' THEN
      -- Check if already purchased
      IF current_double_shot = TRUE THEN
        RETURN FALSE; -- Already owned
      END IF;
      
      -- Deduct coins and grant upgrade
      UPDATE users 
      SET coins = coins - item_cost,
          has_double_shot = TRUE,
          updated_at = NOW()
      WHERE id = user_id;
      
      purchase_successful := TRUE;
      
    ELSIF item_type = 'extra_heart' THEN
      -- Check session limit (max 1 per session)
      IF current_extra_hearts >= 1 THEN
        RETURN FALSE; -- Session limit reached
      END IF;
      
      -- Deduct coins and grant upgrade
      UPDATE users 
      SET coins = coins - item_cost,
          extra_hearts_purchased = extra_hearts_purchased + 1,
          updated_at = NOW()
      WHERE id = user_id;
      
      purchase_successful := TRUE;
      
    ELSE
      RAISE EXCEPTION 'Invalid item type: %', item_type;
    END IF;
  END IF;
  
  RETURN purchase_successful;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to reset session-specific purchases
CREATE OR REPLACE FUNCTION reset_session_purchases(user_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE users 
  SET extra_hearts_purchased = 0,
      updated_at = NOW()
  WHERE id = user_id;
  
  -- Check if user exists
  IF NOT FOUND THEN
    RAISE EXCEPTION 'User not found';
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update game statistics after battle
CREATE OR REPLACE FUNCTION update_game_stats(
  user_id UUID,
  did_win BOOLEAN,
  level_completed INTEGER DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
  UPDATE users 
  SET total_games_played = total_games_played + 1,
      total_wins = CASE WHEN did_win THEN total_wins + 1 ELSE total_wins END,
      total_losses = CASE WHEN NOT did_win THEN total_losses + 1 ELSE total_losses END,
      highest_level_completed = CASE 
        WHEN level_completed IS NOT NULL AND level_completed > highest_level_completed 
        THEN level_completed 
        ELSE highest_level_completed 
      END,
      updated_at = NOW()
  WHERE id = user_id;
  
  -- Check if user exists
  IF NOT FOUND THEN
    RAISE EXCEPTION 'User not found';
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update last login time
CREATE OR REPLACE FUNCTION update_last_login(user_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE users 
  SET last_login = NOW(),
      updated_at = NOW()
  WHERE id = user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 6. ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on users table
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read their own data
CREATE POLICY "Users can view own data"
  ON users
  FOR SELECT
  USING (auth.uid() = id);

-- Policy: Users can update their own data
CREATE POLICY "Users can update own data"
  ON users
  FOR UPDATE
  USING (auth.uid() = id);

-- Policy: Users can insert their own data (for registration)
CREATE POLICY "Users can insert own data"
  ON users
  FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Policy: Users can delete their own data
CREATE POLICY "Users can delete own data"
  ON users
  FOR DELETE
  USING (auth.uid() = id);

-- =====================================================
-- 6.5. AUTOMATIC USER CREATION TRIGGER
-- =====================================================
-- This trigger automatically creates a user entry in the users table
-- when a new user signs up via Supabase Auth

-- First, temporarily disable RLS for the trigger to work
-- The trigger runs with SECURITY DEFINER so it has full permissions
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER 
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  -- Insert new user with default values
  INSERT INTO public.users (
    id, 
    username, 
    email,
    created_at,
    updated_at
  )
  VALUES (
    NEW.id,
    COALESCE(
      NEW.raw_user_meta_data->>'username', 
      SPLIT_PART(NEW.email, '@', 1)
    ),
    NEW.email,
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log the error but don't block user creation
    RAISE WARNING 'Error creating user profile for %: %', NEW.id, SQLERRM;
    RETURN NEW;
END;
$$;

-- Drop existing trigger if exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create trigger on auth.users insert
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Grant necessary permissions to the function
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON public.users TO postgres, service_role;

-- =====================================================
-- 7. HELPER VIEWS FOR LEADERBOARDS
-- =====================================================

-- View for top players by coins
CREATE OR REPLACE VIEW leaderboard_by_coins AS
SELECT 
  username,
  coins,
  total_wins,
  total_games_played,
  created_at
FROM users
WHERE is_active = TRUE
ORDER BY coins DESC
LIMIT 100;

-- View for top players by wins
CREATE OR REPLACE VIEW leaderboard_by_wins AS
SELECT 
  username,
  total_wins,
  total_games_played,
  coins,
  created_at
FROM users
WHERE is_active = TRUE
ORDER BY total_wins DESC
LIMIT 100;

-- =====================================================
-- USAGE EXAMPLES
-- =====================================================

/*
-- Create a new user (after Supabase Auth creates the auth.users entry)
INSERT INTO users (id, username, email)
VALUES ('user-uuid-from-auth', 'player1', 'player1@example.com');

-- Add coins to a user
SELECT add_coins('user-uuid-here', 50);

-- Purchase double shot (costs 100 coins)
SELECT purchase_item('user-uuid-here', 100, 'double_shot');

-- Purchase extra heart (costs 50 coins)
SELECT purchase_item('user-uuid-here', 50, 'extra_heart');

-- Reset session purchases (call when starting new game)
SELECT reset_session_purchases('user-uuid-here');

-- Update game stats after a battle
SELECT update_game_stats('user-uuid-here', TRUE, 1); -- Won, completed level 1

-- Update last login
SELECT update_last_login('user-uuid-here');

-- View leaderboards
SELECT * FROM leaderboard_by_coins;
SELECT * FROM leaderboard_by_wins;

-- Get user's complete profile
SELECT * FROM users WHERE id = 'user-uuid-here';
*/

-- =====================================================
-- NOTES
-- =====================================================

/*
IMPORTANT NOTES:

1. AUTH INTEGRATION:
   - This schema assumes Supabase Auth is being used
   - The users.id references auth.users(id)
   - When a user signs up via Supabase Auth, you need to create
     a corresponding entry in the users table

2. SECURITY:
   - Row Level Security (RLS) is enabled
   - Users can only access their own data
   - Functions use SECURITY DEFINER for controlled access

3. PRICING (from requirements):
   - Coins per enemy kill: 50
   - Double shot upgrade: 100 coins
   - Extra heart upgrade: 50 coins (max 1 per session)

4. SESSION MANAGEMENT:
   - extra_hearts_purchased should be reset when starting a new game
   - Call reset_session_purchases() at the start of each game session

5. GAME FLOW:
   - On login: Call update_last_login()
   - After killing enemy: Call add_coins(user_id, 50)
   - After game ends: Call update_game_stats()
   - At game start: Call reset_session_purchases()
*/
