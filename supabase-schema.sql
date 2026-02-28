-- ============================================
-- IK SURD PADEL APP - Supabase Schema
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- USERS / PROFILES
-- ============================================
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  position TEXT, -- 'Spelare', 'Tränare', 'Admin'
  bio TEXT,
  phone TEXT,
  level INTEGER CHECK (level >= 1 AND level <= 9),
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Trigger: Skapa profil automatiskt vid ny registrering
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  base_username TEXT;
  uni_username TEXT;
BEGIN
  base_username := lower(split_part(COALESCE(NEW.raw_user_meta_data->>'email', NEW.email::text), '@', 1));
  base_username := regexp_replace(base_username, '[^a-z0-9]', '', 'g');
  IF base_username = '' THEN base_username := 'user'; END IF;
  uni_username := base_username || '_' || substr(replace(NEW.id::text, '-', ''), 1, 8);
  INSERT INTO public.profiles (id, username, full_name, avatar_url)
  VALUES (
    NEW.id,
    uni_username,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name'),
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- PERSONAL GOALS
-- ============================================
CREATE TABLE goals (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL, -- 'Teknik', 'Fysik', 'Mental', 'Tävling', 'Annat'
  target_value INTEGER, -- t.ex. antal träningar
  current_value INTEGER DEFAULT 0,
  deadline DATE,
  is_completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- TRAINING SESSIONS
-- ============================================
CREATE TABLE trainings (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  location TEXT DEFAULT 'IK Surd Padelhall',
  scheduled_at TIMESTAMPTZ NOT NULL,
  duration_minutes INTEGER DEFAULT 90,
  max_participants INTEGER DEFAULT 12,
  created_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE training_participants (
  training_id UUID REFERENCES trainings(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  rsvp_status TEXT DEFAULT 'attending', -- 'attending', 'declined', 'maybe'
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (training_id, user_id)
);

-- ============================================
-- COMPETITIONS / TOURNAMENTS
-- ============================================
CREATE TABLE competitions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  location TEXT,
  competition_date DATE NOT NULL,
  competition_type TEXT DEFAULT 'Tävling', -- 'Tävling', 'Cup', 'Liga', 'Vänskapsmatch'
  result TEXT,
  placement INTEGER,
  created_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE competition_participants (
  competition_id UUID REFERENCES competitions(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  result TEXT,
  placement INTEGER,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (competition_id, user_id)
);

-- ============================================
-- DISCUSSION FORUM
-- ============================================
CREATE TABLE forum_categories (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  icon TEXT, -- emoji eller icon-namn
  sort_order INTEGER DEFAULT 0
);

CREATE TABLE forum_threads (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  category_id UUID REFERENCES forum_categories(id) ON DELETE CASCADE,
  author_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  is_pinned BOOLEAN DEFAULT FALSE,
  is_locked BOOLEAN DEFAULT FALSE,
  view_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE forum_posts (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  thread_id UUID REFERENCES forum_threads(id) ON DELETE CASCADE,
  author_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  content TEXT NOT NULL,
  is_first_post BOOLEAN DEFAULT FALSE,
  likes_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE forum_likes (
  post_id UUID REFERENCES forum_posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (post_id, user_id)
);

-- ============================================
-- PARTNER MATCHES (Hitta Match)
-- ============================================
CREATE TABLE partner_matches (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  creator_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  match_type TEXT DEFAULT 'vinnarbana',
  level_min INTEGER DEFAULT 1 CHECK (level_min >= 1 AND level_min <= 9),
  level_max INTEGER DEFAULT 9 CHECK (level_max >= 1 AND level_max <= 9),
  duration_minutes INTEGER DEFAULT 90,
  scheduled_at TIMESTAMPTZ,
  location TEXT DEFAULT 'IK Surd Hall',
  message TEXT,
  is_open BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE partner_match_participants (
  match_id UUID REFERENCES partner_matches(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'pending',
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (match_id, user_id)
);

-- ============================================
-- LEADER POSTS (Info från Ledaren)
-- ============================================
CREATE TABLE leader_posts (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  author_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  content TEXT,
  video_url TEXT,
  is_pinned BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE leader_post_comments (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  post_id UUID REFERENCES leader_posts(id) ON DELETE CASCADE NOT NULL,
  author_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- NOTIFICATIONS
-- ============================================
CREATE TABLE notifications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  type TEXT,
  title TEXT,
  message TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  related_id UUID,
  related_type TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- AI MOTIVATIONS / PUSH
-- ============================================
CREATE TABLE ai_motivations (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  context TEXT, -- 'inactive', 'goal_progress', 'competition', 'general', 'weekly'
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- MEMBER STATS (för topplista)
-- ============================================
CREATE VIEW member_stats AS
SELECT
  p.id,
  p.full_name,
  p.username,
  p.avatar_url,
  COUNT(DISTINCT tp.training_id) AS total_trainings,
  COUNT(DISTINCT cp.competition_id) AS total_competitions,
  COUNT(DISTINCT g.id) FILTER (WHERE g.is_completed = TRUE) AS completed_goals,
  COUNT(DISTINCT fp.id) AS forum_posts
FROM profiles p
LEFT JOIN training_participants tp ON tp.user_id = p.id
LEFT JOIN competition_participants cp ON cp.user_id = p.id
LEFT JOIN goals g ON g.user_id = p.id
LEFT JOIN forum_posts fp ON fp.author_id = p.id
GROUP BY p.id, p.full_name, p.username, p.avatar_url;

-- ============================================
-- SEED: Forum kategorier
-- ============================================
INSERT INTO forum_categories (name, description, icon, sort_order) VALUES
  ('Allmänt', 'Allmän diskussion om laget och padelsporten', '💬', 1),
  ('Träning', 'Tips, frågor och diskussion om träning', '🏃', 2),
  ('Tävling', 'Inför och efter tävlingar', '🏆', 3),
  ('Teknik', 'Tekniktips och videolänkar', '🎾', 4),
  ('Off-topic', 'Allt annat', '😄', 5);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE trainings ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE competitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE competition_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE forum_threads ENABLE ROW LEVEL SECURITY;
ALTER TABLE forum_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE forum_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_motivations ENABLE ROW LEVEL SECURITY;
ALTER TABLE partner_matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE partner_match_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE leader_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE leader_post_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Profiles: alla kan läsa, bara du kan uppdatera ditt eget
CREATE POLICY "Public profiles" ON profiles FOR SELECT USING (TRUE);
CREATE POLICY "Own profile update" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Own profile insert" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Goals: privata per användare
CREATE POLICY "Own goals" ON goals FOR ALL USING (auth.uid() = user_id);

-- Trainings: alla inloggade kan läsa, admins/tränare skapar
CREATE POLICY "Read trainings" ON trainings FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Create trainings" ON trainings FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Training participants
CREATE POLICY "Read participants" ON training_participants FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Own participation" ON training_participants FOR ALL USING (auth.uid() = user_id);

-- Competitions
CREATE POLICY "Read competitions" ON competitions FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Create competitions" ON competitions FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Competition participants
CREATE POLICY "Read comp participants" ON competition_participants FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Own comp participation" ON competition_participants FOR ALL USING (auth.uid() = user_id);

-- Forum: alla inloggade kan läsa och skriva
CREATE POLICY "Read threads" ON forum_threads FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Create threads" ON forum_threads FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Read posts" ON forum_posts FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Create posts" ON forum_posts FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Own post update" ON forum_posts FOR UPDATE USING (auth.uid() = author_id);
CREATE POLICY "Likes" ON forum_likes FOR ALL USING (auth.uid() = user_id);

-- AI motivations: bara för dig själv
CREATE POLICY "Own motivations" ON ai_motivations FOR SELECT USING (auth.uid() = user_id);

-- Partner matches
CREATE POLICY "Read partner matches" ON partner_matches FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Create own matches" ON partner_matches FOR INSERT WITH CHECK (auth.uid() = creator_id);
CREATE POLICY "Update own matches" ON partner_matches FOR UPDATE USING (auth.uid() = creator_id);
CREATE POLICY "Read participants" ON partner_match_participants FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Own participation pm" ON partner_match_participants FOR ALL USING (auth.uid() = user_id);

-- Leader posts
CREATE POLICY "Read leader posts" ON leader_posts FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Create leader posts" ON leader_posts FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Read comments" ON leader_post_comments FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Create comments" ON leader_post_comments FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Notifications
CREATE POLICY "Own notifications" ON notifications FOR ALL USING (auth.uid() = user_id);

-- ============================================
-- REALTIME: Aktivera för live-uppdateringar
-- ============================================
ALTER PUBLICATION supabase_realtime ADD TABLE forum_posts;
ALTER PUBLICATION supabase_realtime ADD TABLE forum_threads;
ALTER PUBLICATION supabase_realtime ADD TABLE ai_motivations;
ALTER PUBLICATION supabase_realtime ADD TABLE training_participants;
ALTER PUBLICATION supabase_realtime ADD TABLE partner_match_participants;
ALTER PUBLICATION supabase_realtime ADD TABLE leader_post_comments;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
