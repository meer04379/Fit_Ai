-- ====================================================================
-- FitAI Database Schema for Supabase (PostgreSQL)
-- Run this script in your Supabase SQL Editor (Dashboard > SQL Editor)
-- ====================================================================

-- 1. Create Profiles Table
CREATE TABLE IF NOT EXISTS public.profiles (
    id TEXT PRIMARY KEY,
    name TEXT DEFAULT 'Meer',
    goal TEXT DEFAULT 'gainMuscle',
    target_calories INT DEFAULT 2000,
    target_protein NUMERIC DEFAULT 120,
    target_carbs NUMERIC DEFAULT 250,
    target_fat NUMERIC DEFAULT 65,
    current_weight NUMERIC DEFAULT 70.5,
    goal_weight NUMERIC DEFAULT 65.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Create Meal Logs Table
CREATE TABLE IF NOT EXISTS public.meal_logs (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    title TEXT NOT NULL,
    category TEXT NOT NULL,
    calories INT NOT NULL,
    time TEXT NOT NULL,
    image_url TEXT,
    emoji TEXT DEFAULT '🍲',
    protein NUMERIC DEFAULT 0,
    carbs NUMERIC DEFAULT 0,
    fat NUMERIC DEFAULT 0,
    ai_confidence INT DEFAULT 95,
    ingredients JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Create Weight Logs Table
CREATE TABLE IF NOT EXISTS public.weight_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    weight NUMERIC NOT NULL,
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. Enable Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meal_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weight_logs ENABLE ROW LEVEL SECURITY;

-- 5. Open Access Policies (Allows seamless access for both anonymous and authenticated users)
CREATE POLICY "Allow all profile operations" 
ON public.profiles FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all meal_logs operations" 
ON public.meal_logs FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all weight_logs operations" 
ON public.weight_logs FOR ALL USING (true) WITH CHECK (true);

-- 6. Insert Default Profile if not exists
INSERT INTO public.profiles (id, name, goal, target_calories, current_weight, goal_weight)
VALUES ('guest_user', 'Meer', 'gainMuscle', 2000, 70.5, 65.0)
ON CONFLICT (id) DO NOTHING;
