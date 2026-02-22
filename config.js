// ============================================================
// KASSA APP - ZENTRALE KONFIGURATION
// ============================================================
// Diese Datei enthält ALLE betriebsspezifischen Einstellungen.
// Bei Neuinstallation NUR diese Datei anpassen!
//
// ANLEITUNG FÜR NEUEN KUNDEN:
// 1. Betrieb-Daten anpassen (Name, Logo, etc.)
// 2. Supabase-Projekt erstellen & URL/Key eintragen
// 3. Admin-Email anpassen
// 4. Kontaktdaten eintragen
// 5. SQL-Setup in Supabase ausführen (supabase_setup.sql)
// ============================================================

const APP_CONFIG = {

    // ==================== BETRIEB ====================
    betrieb: {
        name: 'HirscheggKassa',               // Name des Betriebs
        kurzname: 'Kassa',                 // App-Titel in der Navigation
        vollname: 'HIRSCHEGG KASSA',            // Großbuchstaben für Preisliste/PDFs
        backup_prefix: 'HirscheggKassa',       // Dateiname-Prefix für Backups
        untertitel: '',                         // Untertitel (optional)
        copyright: 'Entwickelt von: Claudio',
        version: 'v3.7',
    },

    // ==================== APP-IDENTIFIKATION ====================
    // Wird für lokale Datenbank, Service Worker Cache, PWA Manifest verwendet
    app: {
        db_name: 'HirscheggKassa',             // Name der lokalen IndexedDB (keine Sonderzeichen!)
        cache_name: 'hirschegg-kassa-v1',      // Service Worker Cache-Name
        start_url: '/KWT/',                    // PWA Start-URL (GitHub Pages Pfad)
        beschreibung: 'Self-Service Buchungssystem', // Meta-Description
    },

    // ==================== SUPABASE ====================
    // HIER DIE SUPABASE-DATEN DES KWT-PROJEKTS EINTRAGEN!
    supabase: {
        url: 'HIER_SUPABASE_URL_EINTRAGEN',
        anon_key: 'HIER_SUPABASE_ANON_KEY_EINTRAGEN',
    },

    // ==================== ADMIN ====================
    admin: {
        email: 'admin@hirscheggkassa.local',  // Admin-Login Email
        // Passwort wird vom Nutzer beim Login eingegeben
        // WICHTIG: Muss mit der Email im Supabase Auth + RLS Policies übereinstimmen!
    },

    // ==================== KONTAKT ====================
    kontakt: {
        whatsapp_nummer: '',                          // Ohne + und Leerzeichen
        whatsapp_anzeige: '',                         // Anzeige-Format
        whatsapp_aktiv: false,                        // WhatsApp-Button anzeigen?
    },

    // ==================== PREISE & STEUERN ====================
    preise: {
        waehrung: '€',                    // Währungssymbol
        waehrung_format: 'de-AT',         // Locale für Preisformatierung
        standard_steuer: 10,              // Standard-Steuersatz in %
        ideas_steuer: 19,                 // Steuer für IDEAS-Export
    },

    // ==================== KATEGORIEN (SV-Ausblendung) ====================
    kategorien: {
        sv_versteckt: [4, 6, 7],          // Kategorie-IDs die bei SV ausgeblendet werden
        // 4 = Schnäpse & Spirituosen, 6 = Süßes & Salziges, 7 = Sonstiges
    },

    // ==================== BUCHUNGS-ZEITFENSTER ====================
    buchung: {
        tageswechsel_stunde: 7,           // Um 7:00 Uhr wechselt der Buchungstag
        // Vor 7:00 → Buchungen zählen zum Vortag
    },

    // ==================== PREISLISTE PDF ====================
    preisliste: {
        fussnote: 'Die Getränke befinden sich im Kühlschrank im Aufenthaltsraum. Bitte bedienen Sie sich selbst und buchen Sie die Getränke über diese App.',
        whatsapp_hinweis: 'Nachbestellung per WhatsApp möglich:',
        zahlungshinweis: 'Die Bezahlung erfolgt bei Abreise.',
    },

    // ==================== IDEAS EXPORT ====================
    ideas: {
        start_id: 20000,                  // Start-ID für Buchungsdetail
        gast_start_id: 200,               // Start-ID für Gäste
    },

    // ==================== GEO-IP / ZUGRIFFSKONTROLLE ====================
    zugriff: {
        geo_beschraenkung_aktiv: true,     // Zugriff nur vor Ort?
        erlaubte_laender: ['AT'],          // Erlaubte Länder (ISO-Code)
        fehlermeldung: 'Diese Anwendung ist ausschließlich vor Ort im {betrieb} verfügbar.',
    },

    // ==================== SAMMELRECHNUNG ====================
    sammelrechnung: {
        default_name: 'SAMMELRECHNUNG',    // Standard-Name für Sammelrechnungen
        gruppen_name: 'Sammelrechnung',    // Gruppenname in Profilen
    },

    // ==================== LOGO ====================
    // Base64-kodiertes Logo (für Startseite + Loading Screen)
    // Ersetze mit eigenem Logo als data:image/... String
    // null = kein Logo wird angezeigt
    logo: null, // 'data:image/png;base64,...' oder 'data:image/webp;base64,...'
};

// Config wird global über APP_CONFIG verfügbar gemacht
// und vor app.js in index.html geladen
