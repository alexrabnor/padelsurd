# 🎾 IK Surd Padel App

> Padel-app för IK Surds padelsektionen — webb och mobil med samma Supabase-databas.

![IK Surd](https://img.shields.io/badge/IK%20Surd-Padel%201903-c9a84c?style=for-the-badge)
![Next.js](https://img.shields.io/badge/Next.js-14-black?style=for-the-badge&logo=next.js)
![Expo](https://img.shields.io/badge/Expo-Mobile-white?style=for-the-badge&logo=expo)
![Supabase](https://img.shields.io/badge/Supabase-Database-3ECF8E?style=for-the-badge&logo=supabase)

---

## Funktioner

- 🔐 **Auth** — Logga in med e-post/lösenord eller Google
- 📅 **Kalender** — Träningar, matcher och tävlingar synkade
- 📣 **Info från Ledaren** — Inlägg med video och kommentarer
- 🏃 **Träningar** — RSVP, kommande och historik
- 🏆 **Tävlingar** — Resultat och statistik
- 🤝 **Hitta Match** — Vinnarbana, Americano, Mexicano, Träning
- 📋 **Mina Bokningar** — Alla anmälningar samlade
- 🎯 **Mina Mål** — Personliga mål med progressbar
- 💬 **Forum** — Diskussioner med Realtime
- 📊 **Topplista** — Aktivitet, tävling och mål
- 🤖 **AI Coach** — Personlig motivationscoach via OpenAI
- 🔔 **Notissystem** — Push och notispanel
- 🎾 **Matchi** — Länk till matchi.se för banbokning

---

## Tech Stack

| Del | Teknik |
|-----|--------|
| Monorepo | Turborepo |
| Webb | Next.js 14 (App Router) |
| Mobil | Expo (React Native) |
| Databas | Supabase (PostgreSQL) |
| Auth | Supabase Auth + Google OAuth |
| Realtime | Supabase Realtime |
| Styling | Tailwind CSS + shadcn/ui |
| AI | OpenAI API (gpt-4o-mini) |
| Språk | TypeScript |

---

## Kom igång

### 1. Klona repot
```bash
git clone https://github.com/DITTNAMN/iksurd-padel.git
cd iksurd-padel
```

### 2. Installera beroenden
```bash
npm install
```

### 3. Sätt upp Supabase
1. Gå till [supabase.com](https://supabase.com) och skapa ett nytt projekt
2. Öppna **SQL Editor** och kör `supabase-schema.sql`
3. Aktivera Google OAuth under **Authentication → Providers**

### 4. Miljövariabler
Skapa `apps/web/.env.local`:
```env
NEXT_PUBLIC_SUPABASE_URL=https://xxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...
OPENAI_API_KEY=sk-...
```

Skapa `apps/mobile/.env.local`:
```env
EXPO_PUBLIC_SUPABASE_URL=https://xxxx.supabase.co
EXPO_PUBLIC_SUPABASE_ANON_KEY=eyJ...
```

### 5. Starta utvecklingsservern
```bash
# Webb
npm run dev --filter=web

# Mobil (Expo Go)
npm run dev --filter=mobile
```

Skanna QR-koden med Expo Go-appen på telefonen.

---

## Mappstruktur

```
iksurd-padel/
├── apps/
│   ├── web/                    # Next.js webbapp
│   └── mobile/                 # Expo mobilapp
├── packages/
│   └── shared/                 # Delad kod (Supabase, typer, queries)
├── supabase-schema.sql         # Databas-schema
├── CURSOR_PROMPT.md            # Prompt för Cursor AI
├── PROJEKTSPEC.md              # Fullständig projektspecifikation
└── README.md
```

---

## Branches

| Branch | Syfte |
|--------|-------|
| `main` | Alltid fungerande, driftsatt kod |
| `dev` | Aktiv utveckling |
| `feature/x` | Specifika features |

---

## Deploy

**Webb → Vercel**
```bash
vercel --prod
```

**Mobil → Expo EAS**
```bash
eas build --platform all
```

---

## Kostnad (testfas)

| Tjänst | Kostnad |
|--------|---------|
| Supabase Free | 0 kr |
| Vercel Free | 0 kr |
| Expo Go (test) | 0 kr |
| OpenAI | ~5–10 kr/mån |
| **Totalt** | **~5–10 kr/mån** |

---

## Kontakt

IK Surd Padelsektionen · Sundsvall · Grundad 1903
