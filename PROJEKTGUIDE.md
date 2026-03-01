# IK Surd Padel App — Projektguide

## Stack
- **Supabase** — Databas, Auth, Realtime, Storage
- **Next.js 14** — Webbapp (App Router)
- **Expo (React Native)** — Mobilapp
- **Turborepo** — Monorepo-hantering
- **TypeScript** — Hela projektet

---

## 1. Skapa Supabase-projekt

1. Gå till [supabase.com](https://supabase.com) → New Project
2. Välj namn: `iksurd-padel`
3. Spara ditt **Project URL** och **Anon Key**
4. Gå till **SQL Editor** → klistra in `supabase-schema.sql` → kör

---

## 2. Projektstruktur (Monorepo)

```
iksurd-padel/
├── apps/
│   ├── web/                    # Next.js webbapp
│   │   ├── app/
│   │   │   ├── (auth)/
│   │   │   │   ├── login/
│   │   │   │   └── register/
│   │   │   ├── dashboard/
│   │   │   ├── trainings/
│   │   │   ├── competitions/
│   │   │   ├── goals/
│   │   │   ├── forum/
│   │   │   └── leaderboard/
│   │   └── package.json
│   └── mobile/                 # Expo app
│       ├── app/
│       │   ├── (tabs)/
│       │   │   ├── index.tsx       # Dashboard
│       │   │   ├── trainings.tsx
│       │   │   ├── goals.tsx
│       │   │   └── forum.tsx
│       └── package.json
└── packages/
    └── shared/                 # Delad kod!
        ├── src/
        │   ├── supabase.ts     # Supabase-klient
        │   ├── types.ts        # Databastyper
        │   └── queries/        # Databasfunktioner
        │       ├── goals.ts
        │       ├── trainings.ts
        │       ├── competitions.ts
        │       └── forum.ts
        └── package.json
```

---

## 3. Starta projektet

```bash
# Klona / initiera
npx create-turbo@latest iksurd-padel
cd iksurd-padel

# Installera beroenden
npm install

# Lägg till Supabase
npm install @supabase/supabase-js @supabase/ssr

# Miljövariabler — skapa .env.local i apps/web/ och apps/mobile/
NEXT_PUBLIC_SUPABASE_URL=https://xxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIs...

# Kör webb + mobil parallellt
npm run dev
```

---

## 4. Delad Supabase-klient (packages/shared/src/supabase.ts)

```typescript
import { createClient } from '@supabase/supabase-js'
import type { Database } from './database.types'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient<Database>(supabaseUrl, supabaseKey)
```

---

## 5. Exempel — Hämta träningar (packages/shared/src/queries/trainings.ts)

```typescript
import { supabase } from '../supabase'

// Hämta kommande träningar
export async function getUpcomingTrainings() {
  const { data, error } = await supabase
    .from('trainings')
    .select(`
      *,
      training_participants(count),
      created_by:profiles(full_name, avatar_url)
    `)
    .gte('scheduled_at', new Date().toISOString())
    .order('scheduled_at', { ascending: true })
    .limit(10)

  if (error) throw error
  return data
}

// Anmäl sig till träning
export async function joinTraining(trainingId: string, userId: string) {
  const { error } = await supabase
    .from('training_participants')
    .insert({ training_id: trainingId, user_id: userId, rsvp_status: 'attending' })

  if (error) throw error
}
```

---

## 6. Realtime Forum (live-uppdateringar)

```typescript
// Lyssna på nya foruminlägg i realtid
const channel = supabase
  .channel('forum-posts')
  .on(
    'postgres_changes',
    { event: 'INSERT', schema: 'public', table: 'forum_posts' },
    (payload) => {
      console.log('Nytt inlägg:', payload.new)
      // Uppdatera state i React
    }
  )
  .subscribe()

// Rensa vid unmount
return () => supabase.removeChannel(channel)
```

---

## 7. AI Motivation med OpenAI

```typescript
// apps/web/app/api/ai-motivation/route.ts

import OpenAI from 'openai'

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY })

export async function POST(req: Request) {
  const { userName, trainings, competitions, goals } = await req.json()

  const prompt = `
    Du är en entusiastisk padeltränare för IK Surd.
    Spelaren ${userName} har:
    - ${trainings} träningar denna säsong
    - ${competitions} tävlingar
    - ${goals} aktiva mål
    
    Skriv ett kort, personligt och energifullt motivationsmeddelande på svenska (max 2 meningar).
  `

  const response = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [{ role: 'user', content: prompt }],
    max_tokens: 100,
  })

  return Response.json({ message: response.choices[0].message.content })
}
```

---

## 8. Push-notiser (Expo)

```typescript
// apps/mobile/src/notifications.ts
import * as Notifications from 'expo-notifications'

// Schemalägg AI-motivation varje morgon kl 08:00
await Notifications.scheduleNotificationAsync({
  content: {
    title: '🎾 IK Surd Coach',
    body: 'Träning ikväll kl 18:00 — du är anmäld!',
  },
  trigger: {
    hour: 8,
    minute: 0,
    repeats: true,
  },
})
```

---

## 9. Nästa steg att bygga

- [ ] Auth (login/register med Supabase Auth)
- [ ] Profilsidor med avatar-upload
- [ ] Forum med realtids-chat
- [ ] Träningskalender med RSVP
- [ ] Tävlingsregistrering med resultat
- [ ] AI-motivation via OpenAI API (kopplat till din befintliga OpenAI-setup)
- [ ] Push-notiser via Expo Notifications
- [ ] Bildgalleri per träning/tävling
- [ ] Betalningsspårning (lagavgifter)
- [ ] Admin-panel för tränare

---

## Deployering

**Webb:** Vercel (gratis, kopplat till GitHub)
```bash
vercel --prod
```

**Mobil:** Expo EAS Build
```bash
eas build --platform android  # APK
eas build --platform ios
```

Appen kan lyftas ur din befintliga Supabase-setup på alexcloud.se
eller köras på ett separat Supabase-projekt!
