# 🎰🚫 Quit Gambling

**Eine native iOS-App zur Unterstützung bei der Überwindung von Spielsucht.**

> Quit Gambling begleitet Betroffene auf ihrem Weg in ein spielfreies Leben – mit evidenzbasierten Werkzeugen, einfühlsamer Sprache und einem starken Fokus auf Datenschutz und Privatsphäre.

---

## 📱 Über die App

Quit Gambling ist mehr als ein Tracker. Die App kombiniert klinisch fundierte Strategien mit einer beruhigenden, nicht wertenden Benutzeroberfläche. Sie tarnt sich auf Wunsch als Taschenrechner oder Notizen-App – damit niemand erfährt, dass du Hilfe suchst.

### Kernfunktionen

| Bereich | Beschreibung |
|---------|-------------|
| **🏠 Dashboard** | Live-Abstinenz-Zähler (Tage, Stunden, Minuten, Sekunden), gespartes Geld, tägliches Versprechen, Meilenstein-Vorschau |
| **🆘 SOS-Toolkit** | Atemübung (Box Breathing 4-4-4-4), Urge Surfing (15-Min-Timer), Erdungsübung (5-4-3-2-1), D.E.A.D.S.-Strategie, persönliche Gründe, Notfall-Buddy |
| **📊 Tracker** | Kalender-Ansicht, Craving-Logger mit Intensität/Auslöser/Stimmung, Meilenstein-Badges, Rückfall-Reflexion (mitfühlend, nicht bestrafend), Analytics |
| **📓 Tagebuch** | Stimmungs-Tagging, Dankbarkeitseinträge, Suchfunktion, Verlangen-Tracking |
| **💰 Finanzen** | Gesamtersparnis, Sparziele mit Fortschritt, Sparäquivalente (z.B. „Das entspricht 12 Kinobesuchen"), verhinderte Verluste |
| **🛡️ Schutzschild** | Safari-Extension zum Blockieren von Glücksspielseiten, DNS-Schutz, Gefahrenzonen-Radar mit Standortwarnung, Screen Time Shield |
| **📋 Klinischer Bericht** | Exportierbarer PDF-Bericht für Therapeuten mit Abstinenz-Statistiken, Craving-Mustern und Verlaufsdaten |
| **🎨 Tarnung** | Wechselbare App-Icons (Taschenrechner, Notizen), Camouflage-Modus mit funktionsfähigem Taschenrechner als Tarnung |

---

## 🏗️ Technologie

| Komponente | Details |
|-----------|---------|
| **Sprache** | Swift 6.0 mit strikter Concurrency |
| **Framework** | SwiftUI (100% deklarativ) |
| **Persistenz** | SwiftData |
| **Mindest-iOS** | 18.0 |
| **Architektur** | MVVM mit `@Observable` ViewModels |
| **In-App-Käufe** | RevenueCat SDK |
| **Design** | Eigenes Design-Token-System (`DesignTokens.swift`) |

---

## 📁 Projektstruktur

```
QuitGambling/
├── Sources/
│   ├── QuitGamblingApp.swift          # App Entry Point
│   ├── ContentView.swift              # Tab-Navigation
│   ├── Design/                        # Design-Token-System
│   │   ├── DesignTokens.swift         # Farben, Abstände, Radien, Animationen
│   │   └── SolidSurfaceModifier.swift # Glasmorphismus-Effekte
│   ├── Models/                        # SwiftData Models
│   │   ├── UserProfile.swift          # Benutzerprofil & Abstinenz-Startdatum
│   │   ├── CravingLog.swift           # Verlangen-Einträge
│   │   ├── JournalEntry.swift         # Tagebucheinträge
│   │   ├── SavingsGoal.swift          # Sparziele
│   │   ├── TriggerZone.swift          # Gefahrenzonen (GPS)
│   │   └── ...                        # Weitere Models
│   ├── ViewModels/                    # @Observable ViewModels
│   ├── Views/
│   │   ├── Dashboard/                 # Live-Counter, Sparanzeige, Pledge
│   │   ├── SOS/                       # Notfall-Übungen & Hotlines
│   │   ├── Tracker/                   # Kalender, Cravings, Milestones
│   │   ├── Journal/                   # Tagebuch & Stimmungs-Picker
│   │   ├── Finance/                   # Sparfortschritt & Ziele
│   │   ├── Shield/                    # Schutzschild-Dashboard
│   │   ├── Resources/                 # Hilfsangebote & kognitive Verzerrungen
│   │   ├── Settings/                  # Einstellungen, Paywall, Onboarding
│   │   ├── Checkin/                   # Täglicher Morgen-Check-in
│   │   └── Shared/                    # Wiederverwendbare Komponenten
│   ├── Services/                      # Backend-Services
│   │   ├── SubscriptionManager.swift  # RevenueCat Integration
│   │   ├── DNSProtectionService.swift # DNS-basiertes Blocking
│   │   ├── ShieldManager.swift        # Screen Time API
│   │   ├── LocationShieldManager.swift# Geofencing für Gefahrenzonen
│   │   ├── AmbientSoundService.swift  # Beruhigende Klanglandschaften
│   │   └── ...                        # Weitere Services
│   └── Resources/                     # Assets, Sounds, Videos
├── SafariExtension/                   # Safari Web Extension (Blocking)
├── ShieldAction/                      # Screen Time Shield Action
├── ShieldConfiguration/               # Screen Time Shield UI
├── QuitGambling.xcodeproj/            # Xcode-Projekt
├── QuitGambling.entitlements          # App-Berechtigungen
└── project.yml                        # XcodeGen Konfiguration
```

---

## 🔒 Datenschutz & Privatsphäre

- **Keine Datenübertragung** – Alle Daten bleiben lokal auf dem Gerät (SwiftData)
- **Tarnmodus** – App kann als Taschenrechner oder Notizen-App getarnt werden
- **Keine Tracking-SDKs** – Kein Analytics, kein Tracking
- **Privatsphäre-Manifest** – `PrivacyInfo.xcprivacy` deklariert alle API-Nutzungen

---

## 🆘 Integrierte Hilfsangebote

| Organisation | Nummer | Land |
|-------------|--------|------|
| BZgA Glücksspielsucht | 0800 1 37 27 00 | 🇩🇪 |
| Telefonseelsorge | 0800 111 0 111 | 🇩🇪 |
| NCPG Helpline | 1-800-522-4700 | 🇺🇸 |
| GamCare | 0808 8020 133 | 🇬🇧 |
| Gambling Help | 1800 858 858 | 🇦🇺 |

---

## ⚙️ Setup & Build

### Voraussetzungen

- Xcode 16.0+
- iOS 18.0+ Gerät oder Simulator
- Apple Developer Account (für Screen Time API & Safari Extension)

### Build

```bash
# Projekt öffnen
open QuitGambling.xcodeproj

# Oder via XcodeGen (falls project.yml geändert wurde)
xcodegen generate
open QuitGambling.xcodeproj
```

### Auf Gerät installieren

```bash
xcodebuild -scheme QuitGambling \
  -destination "id=<DEVICE_UDID>" \
  -configuration Debug build

xcrun devicectl device install app \
  --device <DEVICE_UDID> \
  <path-to-built-app>
```

---

## 👥 Team

Entwickelt mit ❤️ für Menschen, die den Mut haben, sich Hilfe zu holen.

---

## 📄 Lizenz

Dieses Projekt ist proprietär. Alle Rechte vorbehalten.
© 2026 Lennert Röhrig
