-- ============================================================
-- KASSA APP - SUPABASE SETUP SCRIPT
-- ============================================================
-- Dieses Script erstellt die komplette Datenbankstruktur
-- für ein neues Kundenprojekt.
--
-- VOR DEM AUSFÜHREN:
-- Ersetze ALLE Vorkommen von 'admin@KUNDE.local' durch
-- die gewünschte Admin-Email (z.B. admin@meinhotel.local)
-- → Suchen & Ersetzen: admin@KUNDE.local → admin@DEIN-BETRIEB.local
--
-- ANLEITUNG:
-- 1. Neues Supabase-Projekt erstellen (supabase.com)
-- 2. Admin-Email unten ersetzen (Suchen: admin@KUNDE.local)
-- 3. Dieses SQL-Script im SQL-Editor ausführen
-- 4. Supabase URL + Anon Key in config.js eintragen
-- 5. Admin-Email in config.js eintragen (muss identisch sein!)
-- 6. Admin-Account in Supabase Auth anlegen (siehe Ende)
-- ============================================================


-- ==================== 1. PROFILES (Gäste) ====================
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    vorname TEXT,
    first_name TEXT,
    display_name TEXT,
    pin_hash TEXT,
    group_name TEXT DEFAULT 'keiner Gruppe zugehörig',
    aktiv BOOLEAN DEFAULT true,
    geloescht BOOLEAN DEFAULT false,
    geloescht_am TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now(),
    last_login_at TIMESTAMPTZ,
    visibleId SERIAL,
    
    -- Preismodus pro Gast
    gast_preismodus TEXT DEFAULT 'default',  -- 'default', 'sv', 'hp', 'manual', 'zeitabhaengig'
    gast_manual_prozent NUMERIC DEFAULT 0,
    gast_hp_von TEXT DEFAULT '12:00',
    gast_hp_bis TEXT DEFAULT '23:59',
    
    -- Umlage
    ausnahmeumlage BOOLEAN DEFAULT false,
    
    -- Sammelrechnung
    is_sammelrechnung BOOLEAN DEFAULT false,
    sammel_quell_ids TEXT,          -- JSON Array der Quell-Gast-IDs
    sammel_quell_namen TEXT,        -- JSON Array der Quell-Gast-Namen
    sammel_deaktiviert_fuer UUID,   -- ID des Sammelaccounts
    sammel_deaktiviert_am TIMESTAMPTZ,
    
    -- Preis-Änderungs-Tracking
    preis_geaendert_am TIMESTAMPTZ,
    preis_alt NUMERIC
);

-- Index für häufige Queries
CREATE INDEX IF NOT EXISTS idx_profiles_aktiv ON profiles(aktiv);
CREATE INDEX IF NOT EXISTS idx_profiles_geloescht ON profiles(geloescht);
CREATE INDEX IF NOT EXISTS idx_profiles_group ON profiles(group_name);


-- ==================== 2. ARTIKEL ====================
CREATE TABLE IF NOT EXISTS artikel (
    artikel_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    preis NUMERIC NOT NULL DEFAULT 0,       -- SV-Preis (Standard)
    preis_hp NUMERIC DEFAULT 0,             -- HP-Preis (Halbpension)
    kategorie_id INTEGER DEFAULT 1,
    icon TEXT DEFAULT '',
    bild TEXT,                              -- Base64 Foto
    steuer_prozent NUMERIC DEFAULT 10,
    aktiv BOOLEAN DEFAULT true,
    sortierung INTEGER DEFAULT 0,
    erstellt_am TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_artikel_aktiv ON artikel(aktiv);
CREATE INDEX IF NOT EXISTS idx_artikel_kategorie ON artikel(kategorie_id);


-- ==================== 3. KATEGORIEN ====================
CREATE TABLE IF NOT EXISTS kategorien (
    kategorie_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    sortierung INTEGER DEFAULT 0,
    farbe TEXT DEFAULT '#2C5F7C'
);

-- Standard-Kategorien einfügen
INSERT INTO kategorien (kategorie_id, name, sortierung, farbe) VALUES
    (1, 'Alkoholfreie Getränke', 10, '#2196F3'),
    (2, 'Biere', 20, '#F0A500'),
    (3, 'Weine', 30, '#8B1A4A'),
    (4, 'Schnäpse & Spirituosen', 40, '#5B2C8C'),
    (5, 'Heiße Getränke', 50, '#6D4C41'),
    (6, 'Süßes & Salziges', 60, '#E91E8C'),
    (7, 'Sonstiges', 70, '#607D6B')
ON CONFLICT (kategorie_id) DO NOTHING;


-- ==================== 4. BUCHUNGEN ====================
CREATE TABLE IF NOT EXISTS buchungen (
    buchung_id TEXT PRIMARY KEY,
    user_id UUID REFERENCES profiles(id),
    gast_id TEXT,
    gast_vorname TEXT,
    gast_nachname TEXT,
    gastgruppe TEXT,
    group_name TEXT,
    artikel_id INTEGER,
    artikel_name TEXT,
    preis NUMERIC DEFAULT 0,
    preis_modus TEXT,                       -- 'sv' oder 'hp'
    steuer_prozent NUMERIC DEFAULT 10,
    menge INTEGER DEFAULT 1,
    datum TEXT,                             -- Format: DD.MM.YYYY
    uhrzeit TEXT,                           -- Format: HH:MM:SS
    erstellt_am TIMESTAMPTZ DEFAULT now(),
    exportiert BOOLEAN DEFAULT false,
    aufgefuellt BOOLEAN DEFAULT false,
    gerät_id TEXT,
    sync_status TEXT DEFAULT 'synced',
    session_id TEXT,
    storniert BOOLEAN DEFAULT false,
    storniert_am TIMESTAMPTZ,
    fix BOOLEAN DEFAULT false,
    aus_fehlend BOOLEAN DEFAULT false,
    ist_umlage BOOLEAN DEFAULT false,
    bezahlt BOOLEAN DEFAULT false,
    
    -- Sammelrechnung-Tracking
    sammel_original_user UUID,
    sammel_original_name TEXT
);

CREATE INDEX IF NOT EXISTS idx_buchungen_user ON buchungen(user_id);
CREATE INDEX IF NOT EXISTS idx_buchungen_datum ON buchungen(datum);
CREATE INDEX IF NOT EXISTS idx_buchungen_storniert ON buchungen(storniert);
CREATE INDEX IF NOT EXISTS idx_buchungen_bezahlt ON buchungen(bezahlt);
CREATE INDEX IF NOT EXISTS idx_buchungen_erstellt ON buchungen(erstellt_am);


-- ==================== 5. SETTINGS (Key-Value Store) ====================
CREATE TABLE IF NOT EXISTS settings (
    key TEXT PRIMARY KEY,
    value JSONB,
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Standard-Settings einfügen
INSERT INTO settings (key, value) VALUES
    ('preis_modus', '"sv"'),
    ('preis_schedule', '[]'),
    ('gruppen_abfrage', 'false'),
    ('tages_menu_v2', 'null'),
    ('nachricht', 'null')
ON CONFLICT (key) DO NOTHING;


-- ==================== 6. FEHLENDE GETRÄNKE ====================
CREATE TABLE IF NOT EXISTS fehlende_getraenke (
    id SERIAL PRIMARY KEY,
    artikel_id INTEGER,
    artikel_name TEXT,
    artikel_preis NUMERIC,
    kategorie_id INTEGER,
    icon TEXT,
    datum TEXT,
    erstellt_am TIMESTAMPTZ DEFAULT now(),
    uebernommen BOOLEAN DEFAULT false,
    uebernommen_von UUID,
    uebernommen_von_name TEXT,
    uebernommen_am TIMESTAMPTZ,
    geloescht BOOLEAN DEFAULT false
);


-- ==================== 7. KÄSE-BESTELLUNGEN ====================
CREATE TABLE IF NOT EXISTS cheese_orders (
    id SERIAL PRIMARY KEY,
    guest_name TEXT NOT NULL,
    grams INTEGER NOT NULL,
    packaging_type TEXT DEFAULT 'standard',
    base_price_cents INTEGER DEFAULT 0,
    packaging_fee_cents INTEGER DEFAULT 0,
    total_price_cents INTEGER DEFAULT 0,
    status TEXT DEFAULT 'OPEN',
    created_at TIMESTAMPTZ DEFAULT now()
);


-- ==================== 8. ROW LEVEL SECURITY ====================

-- RLS aktivieren
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE artikel ENABLE ROW LEVEL SECURITY;
ALTER TABLE kategorien ENABLE ROW LEVEL SECURITY;
ALTER TABLE buchungen ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE fehlende_getraenke ENABLE ROW LEVEL SECURITY;
ALTER TABLE cheese_orders ENABLE ROW LEVEL SECURITY;

-- ===== PROFILES =====
-- Jeder kann Profile lesen (für Gästeliste)
CREATE POLICY "Profiles sind lesbar" ON profiles
    FOR SELECT USING (true);

-- User kann eigenes Profil updaten
CREATE POLICY "User kann eigenes Profil updaten" ON profiles
    FOR UPDATE USING (auth.uid() = id);

-- Admin kann alle Profile updaten
-- WICHTIG: Admin-Email hier anpassen!
CREATE POLICY "Admin kann alle Profile updaten" ON profiles
    FOR UPDATE USING (auth.email() = 'admin@KUNDE.local');

-- Admin kann Profile einfügen
CREATE POLICY "Admin kann Profile einfügen" ON profiles
    FOR INSERT WITH CHECK (true);

-- ===== ARTIKEL =====
CREATE POLICY "Artikel sind lesbar" ON artikel
    FOR SELECT USING (true);

CREATE POLICY "Artikel verwaltbar" ON artikel
    FOR ALL USING (auth.role() = 'authenticated');

-- ===== KATEGORIEN =====
CREATE POLICY "Kategorien sind lesbar" ON kategorien
    FOR SELECT USING (true);

CREATE POLICY "Kategorien verwaltbar" ON kategorien
    FOR ALL USING (auth.role() = 'authenticated');

-- ===== BUCHUNGEN =====
-- Jeder authentifizierte kann lesen (für Admin-Übersicht)
CREATE POLICY "Buchungen lesbar" ON buchungen
    FOR SELECT USING (auth.role() = 'authenticated');

-- Jeder authentifizierte kann einfügen
CREATE POLICY "Buchungen einfügbar" ON buchungen
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Jeder authentifizierte kann updaten (für Storno, Sammelrechnung)
CREATE POLICY "Buchungen updatebar" ON buchungen
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Admin kann löschen
CREATE POLICY "Buchungen löschbar durch Admin" ON buchungen
    FOR DELETE USING (auth.email() = 'admin@KUNDE.local');

-- ===== SETTINGS =====
CREATE POLICY "Settings lesbar" ON settings
    FOR SELECT USING (true);

CREATE POLICY "Settings verwaltbar" ON settings
    FOR ALL USING (auth.role() = 'authenticated');

-- ===== FEHLENDE GETRÄNKE =====
CREATE POLICY "Fehlende lesbar" ON fehlende_getraenke
    FOR SELECT USING (true);

CREATE POLICY "Fehlende einfügbar" ON fehlende_getraenke
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Fehlende updatebar" ON fehlende_getraenke
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Fehlende löschbar" ON fehlende_getraenke
    FOR DELETE USING (auth.email() = 'admin@KUNDE.local');

-- ===== KÄSE-BESTELLUNGEN =====
CREATE POLICY "Cheese Orders lesbar" ON cheese_orders
    FOR SELECT USING (true);

CREATE POLICY "Cheese Orders verwaltbar" ON cheese_orders
    FOR ALL USING (auth.role() = 'authenticated');


-- ==================== 9. TRIGGER: Auto-Profil bei Auth Signup ====================
-- Erstellt automatisch ein Profil wenn ein neuer User sich registriert

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, vorname, first_name, display_name, aktiv, geloescht, created_at)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'first_name', NEW.raw_user_meta_data->>'display_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'display_name', NEW.raw_user_meta_data->>'first_name', ''),
        true,
        false,
        now()
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        vorname = COALESCE(EXCLUDED.vorname, profiles.vorname),
        first_name = COALESCE(EXCLUDED.first_name, profiles.first_name),
        display_name = COALESCE(EXCLUDED.display_name, profiles.display_name);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger an auth.users hängen
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- ==================== 10. HILFSFUNKTIONEN ====================

-- Profil deaktivieren (für Sammelrechnung, RLS-sicher)
CREATE OR REPLACE FUNCTION public.deactivate_profile(profile_id UUID, sammel_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE profiles SET
        aktiv = false,
        sammel_deaktiviert_fuer = sammel_id,
        sammel_deaktiviert_am = now()
    WHERE id = profile_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ==================== 11. ADMIN-ACCOUNT ERSTELLEN ====================
-- WICHTIG: Nach dem Ausführen dieses Scripts muss der Admin-Account
-- manuell über die Supabase Auth UI erstellt werden:
--
-- 1. Gehe zu Authentication → Users → Add User
-- 2. Email: admin@KUNDE.local (GLEICHE Email wie in den RLS Policies oben!)
-- 3. Passwort: [sicheres Passwort wählen]
-- 4. Setze "Auto Confirm" auf ON
--
-- CHECKLISTE NACH SETUP:
-- ✅ SQL ausgeführt (dieses Script)
-- ✅ Admin-Account in Supabase Auth erstellt
-- ✅ config.js: supabase.url eingetragen
-- ✅ config.js: supabase.anon_key eingetragen  
-- ✅ config.js: admin.email = gleiche Email wie hier
-- ✅ config.js: betrieb.name = Kundenname
-- ✅ manifest.json: name + short_name angepasst
-- ✅ sw.js: BASE_PATH angepasst (falls nicht root)


-- ==================== 12. SUPABASE KONFIGURATION ====================
-- Folgende Einstellungen müssen im Supabase Dashboard gemacht werden:
--
-- Authentication → Settings:
--   ✅ Enable Email Signup
--   ✅ Disable Email Confirmations (für lokale @kassa.local Emails)
--   ✅ Disable "Secure email change"
--
-- Authentication → URL Configuration:
--   Site URL: https://deine-domain.com/
--
-- ==================== FERTIG! ====================
