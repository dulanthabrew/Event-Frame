-- ============================================================================
-- EventFrame — Row Level Security Policies
-- Mirrors the logic from the old firestore.rules
-- Run this AFTER schema.sql in your Supabase SQL Editor.
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE pending_deliveries ENABLE ROW LEVEL SECURITY;

-- ── Helper: get the role of the current user ────────────────────────────────
CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS TEXT AS $$
  SELECT role FROM public.profiles WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER;

-- ════════════════════════════════════════════════════════════════════════════
-- PROFILES
-- ════════════════════════════════════════════════════════════════════════════

-- Admins can do everything
CREATE POLICY "admin_full_access_profiles" ON profiles
  FOR ALL USING (get_my_role() = 'admin');

-- Users can read all profiles
CREATE POLICY "authenticated_read_profiles" ON profiles
  FOR SELECT USING (auth.uid() IS NOT NULL);

-- Users can update their own profile
CREATE POLICY "users_update_own_profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Allow insert from the trigger (service role)
CREATE POLICY "service_insert_profiles" ON profiles
  FOR INSERT WITH CHECK (true);

-- ════════════════════════════════════════════════════════════════════════════
-- EVENTS
-- ════════════════════════════════════════════════════════════════════════════

-- Admins can do everything
CREATE POLICY "admin_full_access_events" ON events
  FOR ALL USING (get_my_role() = 'admin');

-- Authenticated users can read events
CREATE POLICY "authenticated_read_events" ON events
  FOR SELECT USING (auth.uid() IS NOT NULL);

-- Photographers can create events
CREATE POLICY "photographers_insert_events" ON events
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL AND get_my_role() IN ('photographer', 'admin'));

-- Photographers can update their own events
CREATE POLICY "photographers_update_own_events" ON events
  FOR UPDATE USING (auth.uid() = photographer_uid);

-- ════════════════════════════════════════════════════════════════════════════
-- PHOTOS
-- ════════════════════════════════════════════════════════════════════════════

-- Admins can do everything
CREATE POLICY "admin_full_access_photos" ON photos
  FOR ALL USING (get_my_role() = 'admin');

-- Authenticated users can read photos
CREATE POLICY "authenticated_read_photos" ON photos
  FOR SELECT USING (auth.uid() IS NOT NULL);

-- Authenticated users can insert photos
CREATE POLICY "authenticated_insert_photos" ON photos
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- ════════════════════════════════════════════════════════════════════════════
-- CLIENTS
-- ════════════════════════════════════════════════════════════════════════════

-- Users can read/write their own client record
CREATE POLICY "users_own_client" ON clients
  FOR ALL USING (auth.uid() = user_id);

-- Photographers can update client event access
CREATE POLICY "photographers_update_clients" ON clients
  FOR UPDATE USING (get_my_role() = 'photographer');

-- ════════════════════════════════════════════════════════════════════════════
-- ORDERS
-- ════════════════════════════════════════════════════════════════════════════

-- Users can read their own orders
CREATE POLICY "users_read_own_orders" ON orders
  FOR SELECT USING (auth.uid() = client_uid OR get_my_role() = 'admin');

-- Users can create orders
CREATE POLICY "users_create_orders" ON orders
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL AND get_my_role() = 'user');

-- ════════════════════════════════════════════════════════════════════════════
-- MEMBERSHIPS
-- ════════════════════════════════════════════════════════════════════════════

-- Everyone can read memberships
CREATE POLICY "authenticated_read_memberships" ON memberships
  FOR SELECT USING (auth.uid() IS NOT NULL);

-- Only admins can manage memberships
CREATE POLICY "admin_manage_memberships" ON memberships
  FOR ALL USING (get_my_role() = 'admin');

-- ════════════════════════════════════════════════════════════════════════════
-- PENDING DELIVERIES
-- ════════════════════════════════════════════════════════════════════════════

-- Users can read their own pending deliveries
CREATE POLICY "users_read_own_deliveries" ON pending_deliveries
  FOR SELECT USING (
    auth.uid() = client_uid
    OR get_my_role() IN ('admin', 'photographer')
  );

-- ════════════════════════════════════════════════════════════════════════════
-- STORAGE: Photos Bucket
-- ════════════════════════════════════════════════════════════════════════════
-- Run in Supabase Dashboard → Storage → Create bucket "photos" (public)
-- Then add these policies:

-- Authenticated users can upload
-- CREATE POLICY "authenticated_upload" ON storage.objects
--   FOR INSERT WITH CHECK (bucket_id = 'photos' AND auth.uid() IS NOT NULL);

-- Anyone can view (public bucket)
-- CREATE POLICY "public_read" ON storage.objects
--   FOR SELECT USING (bucket_id = 'photos');
