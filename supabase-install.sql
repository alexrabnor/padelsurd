-- IK SURD PADEL - Minimal installation
-- For nytt projekt: kopa hela supabase-schema.sql eller detta.
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  position TEXT,
  bio TEXT,
  phone TEXT,
  level INTEGER CHECK (level >= 1 AND level <= 9),
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE base_username TEXT; uni_username TEXT;
BEGIN
  base_username := lower(regexp_replace(split_part(COALESCE(NEW.raw_user_meta_data->>'email', NEW.email::text), '@', 1), '[^a-z0-9]', '', 'g'));
  IF base_username = '' THEN base_username := 'user'; END IF;
  uni_username := base_username || '_' || substr(replace(NEW.id::text, '-', ''), 1, 8);
  INSERT INTO public.profiles (id, username, full_name, avatar_url)
  VALUES (NEW.id, uni_username, COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name'), NEW.raw_user_meta_data->>'avatar_url')
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
EXCEPTION WHEN unique_violation THEN RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TABLE IF NOT EXISTS partner_matches (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  creator_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  match_type TEXT DEFAULT 'vinnarbana',
  level_min INTEGER DEFAULT 1, level_max INTEGER DEFAULT 9,
  duration_minutes INTEGER DEFAULT 90, scheduled_at TIMESTAMPTZ,
  location TEXT DEFAULT 'IK Surd Hall', message TEXT, is_open BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS partner_match_participants (
  match_id UUID REFERENCES partner_matches(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'pending', joined_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (match_id, user_id)
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE partner_matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE partner_match_participants ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public profiles" ON profiles; DROP POLICY IF EXISTS "Own profile update" ON profiles; DROP POLICY IF EXISTS "Own profile insert" ON profiles;
CREATE POLICY "Public profiles" ON profiles FOR SELECT USING (TRUE);
CREATE POLICY "Own profile update" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Own profile insert" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Read partner matches" ON partner_matches; DROP POLICY IF EXISTS "Create own matches" ON partner_matches; DROP POLICY IF EXISTS "Update own matches" ON partner_matches;
CREATE POLICY "Read partner matches" ON partner_matches FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Create own matches" ON partner_matches FOR INSERT WITH CHECK (auth.uid() = creator_id);
CREATE POLICY "Update own matches" ON partner_matches FOR UPDATE USING (auth.uid() = creator_id);

DROP POLICY IF EXISTS "Read participants" ON partner_match_participants; DROP POLICY IF EXISTS "Own participation pm" ON partner_match_participants;
CREATE POLICY "Read participants" ON partner_match_participants FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Own participation pm" ON partner_match_participants FOR ALL USING (auth.uid() = user_id);
