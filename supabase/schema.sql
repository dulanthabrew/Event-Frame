-- ============================================================================
-- EventFrame — Supabase PostgreSQL Schema
-- Run this in your Supabase SQL Editor to create the required tables.
-- ============================================================================

-- ── Profiles (linked to Supabase auth.users) ────────────────────────────────
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  display_name TEXT NOT NULL DEFAULT '',
  photo_url TEXT,
  role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('admin', 'photographer', 'user')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Events ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  code TEXT NOT NULL UNIQUE,
  date TIMESTAMPTZ NOT NULL,
  photographer_uid UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  watermark_enabled BOOLEAN NOT NULL DEFAULT true,
  photo_count INT NOT NULL DEFAULT 0,
  client_count INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_events_photographer ON events(photographer_uid);
CREATE INDEX idx_events_code ON events(code);

-- ── Photos ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  thumbnail_url TEXT,
  uploaded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  file_name TEXT NOT NULL DEFAULT '',
  size INT NOT NULL DEFAULT 0
);

CREATE INDEX idx_photos_event ON photos(event_id);

-- ── Clients (event access tracking) ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS clients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  event_access UUID[] DEFAULT '{}'
);

-- ── Orders (photo purchases) ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_uid UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  photo_ids UUID[] NOT NULL DEFAULT '{}',
  total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'cancelled')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Memberships (subscription plans) ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS memberships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  max_events INT NOT NULL DEFAULT 10,
  max_photos_per_event INT NOT NULL DEFAULT 100,
  features JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Pending Deliveries (Drive full fallback) ────────────────────────────────
CREATE TABLE IF NOT EXISTS pending_deliveries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_uid UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  photo_ids UUID[] NOT NULL DEFAULT '{}',
  status TEXT NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Storage Bucket for Photos ───────────────────────────────────────────────
-- Run this separately or via Supabase Dashboard:
-- INSERT INTO storage.buckets (id, name, public) VALUES ('photos', 'photos', true);

-- ── Function: auto-create profile on signup ─────────────────────────────────
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, display_name, photo_url, role, created_at)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    NEW.raw_user_meta_data->>'avatar_url',
    'user',
    now()
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger: call handle_new_user on auth.users insert
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
