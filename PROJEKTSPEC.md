# IK Surd Padel App — Projektspecifikation

> Referensdokument för utveckling. Använd CURSOR_PROMPT.md för själva Cursor-prompten.

---

## Projektöversikt

Padel-app för IK Surds padel-sektion. Finns som webb (Next.js) och mobilapp (Expo) — båda kopplade till samma Supabase-databas.

---

## Tech Stack

| Del | Teknik |
|-----|--------|
| Monorepo | Turborepo |
| Webb | Next.js 14 (App Router) |
| Mobil | Expo (React Native) |
| Databas | Supabase (PostgreSQL) |
| Auth | Supabase Auth (e-post + Google OAuth) |
| Realtime | Supabase Realtime |
| Styling | Tailwind CSS + shadcn/ui |
| Språk | TypeScript |
| AI | OpenAI API (gpt-4o-mini) |

---

## Mappstruktur

```
iksurd-padel/
├── apps/
│   ├── web/                    # Next.js
│   │   └── app/
│   │       ├── (auth)/         # login, register, forgot
│   │       └── (app)/          # alla skyddade sidor
│   └── mobile/                 # Expo
│       └── app/(tabs)/
├── packages/
│   └── shared/
│       └── src/
│           ├── supabase.ts     # delad klient
│           ├── types.ts        # DB-typer
│           └── queries/        # alla DB-funktioner
└── turbo.json
```

---

## Sidor

| Route | Beskrivning |
|-------|-------------|
| `/login` | Inloggning — e-post/lösenord + Google |
| `/register` | Skapa konto med nivå 1–9 |
| `/dashboard` | Översikt — stats, AI-boost, träningar |
| `/calendar` | Månadskalender — träning/match/partner synkat |
| `/info` | Info från ledaren — video + kommentarer |
| `/trainings` | Träningar — RSVP, kommande/historik |
| `/competitions` | Tävlingar — lista + resultat |
| `/partner` | Hitta Match — skapa + filtrera + anmäl |
| `/bookings` | Mina Bokningar — alla anmälningar |
| `/goals` | Mina Mål — progressbar per mål |
| `/forum` | Diskussionsforum — kategorier + trådar |
| `/leaderboard` | Topplista — aktivitet/tävling/mål |
| `/ai` | AI Coach — motivationer + analys |
| `/notifications` | Notiser — panel + historik |
| Extern | Matchi → matchi.se/activities/search |

---

## Hitta Match — Regler

- **Matchformer:** Vinnarbana / Americano / Mexicano / Träning
- **Nivå:** 1–9, välj spann genom att klicka två siffror (t.ex. 4 → 6 = "Nivå 4–6")
- **Speltid:** 60 / 90 / 120 minuter
- **Fält:** datum, tid, plats, valfritt meddelande
- **Vid anmälan:** bokning skapas + kalenderhändelse läggs till automatiskt

---

## Mina Bokningar

Samlar automatiskt:
- Matcher du anmält dig till via Hitta Match
- Tävlingar som ledaren publicerat

Funktioner:
- Statistik: totalt / matcher / tävlingar
- Flikar: Alla / Hitta Match / Tävlingar / Historik
- Kalenderknapp → navigerar till rätt månad
- Avboka (matcher) — ej möjligt för tävlingar
- Tävlingar synkas automatiskt när ledaren lägger upp dem

---

## Notissystem

Notistyper:
- 🤖 AI Coach — motivationspush
- 🏃 Träning — påminnelse / ny träning
- 💬 Forum — nytt svar i din tråd
- 🤝 Match — matchförfrågan / accepterad
- 🏆 Tävling — ny tävling från ledaren

Funktioner:
- Slide-in panel från höger
- Oläst-indikator (prick på klockan)
- Toast-notiser för direkthändelser
- "Markera alla lästa"

---

## Färgpalett (IK Surds klubbfärger)

```css
--bg:       #06090f   /* bakgrund */
--surface:  #0c1020   /* kort/panels */
--accent:   #c9a84c   /* guld — primär accent */
--blue:     #1a2fa0   /* mörkblå */
--text:     #eef0f8   /* primär text */
--text2:    #8892b8   /* sekundär text */
--muted:    #4a5680   /* nedtonat */
--success:  #42c98a   /* grön */
--danger:   #e05555   /* röd */
```

Typsnitt:
- **Bebas Neue** — rubriker, siffror, titlar
- **Outfit** — brödtext, knappar, labels

---

## Supabase Setup

### 1. Skapa projekt
Gå till supabase.com → New Project → kör `supabase-schema.sql`

### 2. Aktivera Google OAuth
Supabase Dashboard → Authentication → Providers → Google → lägg in Client ID + Secret från Google Cloud Console

### 3. Miljövariabler
```env
NEXT_PUBLIC_SUPABASE_URL=https://xxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...
OPENAI_API_KEY=sk-...
```

### 4. Aktivera Realtime
```sql
ALTER PUBLICATION supabase_realtime ADD TABLE forum_posts;
ALTER PUBLICATION supabase_realtime ADD TABLE leader_post_comments;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE partner_match_participants;
```

---

## Delad Supabase-klient

```typescript
// packages/shared/src/supabase.ts
import { createClient } from '@supabase/supabase-js'
import type { Database } from './database.types'

export const supabase = createClient<Database>(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)
```

---

## AI Coach — OpenAI Integration

```typescript
// apps/web/app/api/ai-motivation/route.ts
const prompt = `
  Du är en entusiastisk padeltränare för IK Surd.
  Spelaren ${name} har:
  - ${trainings} träningar denna säsong
  - ${competitions} tävlingar (${wins} vinster)
  - ${goals} aktiva mål
  - Senast aktiv: ${lastActive} dagar sedan
  
  Skriv ett kort (max 2 meningar), personligt och energifullt 
  motivationsmeddelande på svenska.
`
```

---

## Kostnad

| Tjänst | Kostnad |
|--------|---------|
| Supabase Free | 0 kr — räcker för 20–50 användare |
| Vercel (webb) | 0 kr |
| Expo Go (testning) | 0 kr |
| OpenAI (AI-push) | ~5–10 kr/månad |
| **Totalt** | **~5–10 kr/månad** |

---

## Prioriterad byggnadsordning

1. **Auth** — login, register, Google OAuth
2. **Dashboard** — stats + AI-motivation
3. **Träningar** — RSVP-system
4. **Hitta Match** — partnermatching med bokningar
5. **Kalender** — synkad med bokningar
6. **Mina Bokningar** — samlingssida
7. **Info från Ledaren** — video + kommentarer
8. **Forum** — Realtime-trådar
9. **Tävlingar** — resultat + statistik
10. **AI Coach** — OpenAI-integration
11. **Notissystem** — push + panel
12. **Topplista** — beräknad ranking
13. **Mobilapp** — Expo-version
