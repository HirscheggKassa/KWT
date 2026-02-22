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
        name: 'Haus Bergkranz',               // Name des Betriebs
        kurzname: 'Kassa',                 // App-Titel in der Navigation
        vollname: 'HAUS BERGKRANZ',            // Großbuchstaben für Preisliste/PDFs
        backup_prefix: 'HausBergkranz',       // Dateiname-Prefix für Backups
        untertitel: '',                         // Untertitel (optional)
        copyright: 'Entwickelt von: Claudio',
        version: 'v3.7',
    },

    // ==================== APP-IDENTIFIKATION ====================
    // Wird für lokale Datenbank, Service Worker Cache, PWA Manifest verwendet
    app: {
        db_name: 'HausBergkranzKassa',        // Name der lokalen IndexedDB (keine Sonderzeichen!)
        cache_name: 'bergkranz-kassa-v1',      // Service Worker Cache-Name
        start_url: '/KWT/',                    // PWA Start-URL (GitHub Pages Pfad)
        beschreibung: 'Self-Service Buchungssystem - Haus Bergkranz',
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

    // ==================== KATEGORIEN ====================
    kategorien: {
        sv_versteckt: [],                 // Keine Kategorien ausgeblendet
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
    logo: 'data:image/png;base64,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',
};

// Config wird global über APP_CONFIG verfügbar gemacht
// und vor app.js in index.html geladen
