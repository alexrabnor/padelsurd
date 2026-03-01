-- ============================================
-- IK SURD PADEL — Migreringar (för befintlig DB)
-- Kör detta om du redan kört supabase-schema.sql
-- ============================================

-- Lägg till level i profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS level INTEGER CHECK (level >= 1 AND level <= 9);

-- ============================================
-- PARTNER MATCHES (Hitta Match)
-- ============================================
CREATE TABLE IF NOT EXISTS partner_matches (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  creator_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  match_type TEXT DEFAULT 'vinnarbana', -- vinnarbana, americano, mexicano, träning
  level_min INTEGER DEFAULT 1 CHECK (level_min >= 1 AND level_min <= 9),
  level_max INTEGER DEFAULT 9 CHECK (level_max >= 1 AND level_max <= 9),
  duration_minutes INTEGER DEFAULT 90, -- 60, 90, 120
  scheduled_at TIMESTAMPTZ,
  location TEXT DEFAULT 'IK Surd Hall',
  message TEXT,
  is_open BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS partner_match_participants (
  match_id UUID REFERENCES partner_matches(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'pending', -- pending, accepted, declined
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (match_id, user_id)
);

ALTER TABLE partner_matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE partner_match_participants ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Read partner matches" ON partner_matches FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Create own matches" ON partner_matches FOR INSERT WITH CHECK (auth.uid() = creator_id);
CREATE POLICY "Update own matches" ON partner_matches FOR UPDATE USING (auth.uid() = creator_id);

CREATE POLICY "Read participants" ON partner_match_participants FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Own participation" ON partner_match_participants FOR ALL USING (auth.uid() = user_id);

-- ============================================
-- LEADER POSTS (Info från Ledaren)
-- ============================================
CREATE TABLE IF NOT EXISTS leader_posts (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  author_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  content TEXT,
  video_url TEXT,
  is_pinned BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS leader_post_comments (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  post_id UUID REFERENCES leader_posts(id) ON DELETE CASCADE NOT NULL,
  author_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE leader_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE leader_post_comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Read leader posts" ON leader_posts FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Create leader posts" ON leader_posts FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Read comments" ON leader_post_comments FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Create comments" ON leader_post_comments FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- ============================================
-- NOTIFICATIONS
-- ============================================
CREATE TABLE IF NOT EXISTS notifications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  type TEXT, -- ai, training, forum, match, competition
  title TEXT,
  message TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  related_id UUID,
  related_type TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Own notifications" ON notifications FOR ALL USING (auth.uid() = user_id);

-- ============================================
-- REALTIME
-- ============================================
ALTER PUBLICATION supabase_realtime ADD TABLE partner_match_participants;
ALTER PUBLICATION supabase_realtime ADD TABLE leader_post_comments;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
