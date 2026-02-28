# IK Surd Padel App — Cursor Composer Prompt

Klistra in detta i Cursor Composer (Cmd+I / Ctrl+I) och välj Claude Sonnet som modell.

---

## PROMPT ATT KLISTRA IN:

```
Bygg en fullstack padel-app för idrottsklubben IK Surd i ett Next.js + Expo monorepo med Supabase som backend.

## Stack
- Monorepo med Turborepo
- Next.js 14 (App Router) för webb
- Expo (React Native) för mobil
- Supabase (databas, auth, realtime, storage)
- TypeScript i hela projektet
- Tailwind CSS för styling
- shadcn/ui för komponenter

## Auth
- Inloggning med e-post + lösenord via Supabase Auth
- Inloggning med Google OAuth via Supabase
- Glömt lösenord / återställning via e-post
- Skapa konto med namn, e-post, lösenord och spelnivå (1–9)
- Automatisk profilskapning i profiles-tabellen vid registrering
- Dela auth-logiken i packages/shared

## Databastabeller (Supabase)
Skapa följande tabeller med Row Level Security:

profiles: id, username, full_name, avatar_url, position, bio, phone, level (int 1-9), joined_at

goals: id, user_id, title, description, category (Teknik/Träning/Tävling/Mental/Annat), target_value, current_value, deadline, is_completed

trainings: id, title, description, location, scheduled_at, duration_minutes, max_participants, created_by

training_participants: training_id, user_id, rsvp_status (attending/declined/maybe)

competitions: id, name, description, location, competition_date, competition_type (Liga/Cup/Vänskapsmatch), result, placement, created_by

competition_participants: competition_id, user_id, result, placement

forum_categories: id, name, description, icon, sort_order
forum_threads: id, category_id, author_id, title, is_pinned, is_locked, view_count
forum_posts: id, thread_id, author_id, content, is_first_post, likes_count
forum_likes: post_id, user_id

partner_matches: id, creator_id, match_type (vinnarbana/americano/mexicano/träning), level_min (1-9), level_max (1-9), duration_minutes (60/90/120), scheduled_at, location, message, is_open
partner_match_participants: match_id, user_id, status (pending/accepted/declined)

leader_posts: id, author_id, title, content, video_url, is_pinned
leader_post_comments: id, post_id, author_id, content

bookings: view som samlar training_participants + competition_participants + partner_match_participants för en användare

notifications: id, user_id, type (ai/training/forum/match/competition), title, message, is_read, related_id, related_type

ai_motivations: id, user_id, message, context, is_read

## Sidor / Routes

### Webb (Next.js)
app/(auth)/login          — Inloggning (e-post + Google)
app/(auth)/register       — Skapa konto
app/(auth)/forgot         — Glömt lösenord

app/(app)/dashboard       — Översikt: stats, AI-motivation, kommande träningar, partnersök
app/(app)/calendar        — Månadskalender med träningar, tävlingar och partner-matcher
app/(app)/info            — Info från ledaren (video + kommentarer, Realtime)
app/(app)/trainings       — Träningar: kommande + historik + RSVP
app/(app)/competitions    — Tävlingar: lista, resultat, statistik
app/(app)/partner         — Hitta Match: skapa match, filtrera (matchform/nivå), anmäl dig
app/(app)/bookings        — Mina Bokningar: alla anmälningar från matcher + tävlingar, synkat med kalender
app/(app)/goals           — Mina Mål: aktiva/klara mål med progressbar
app/(app)/forum           — Diskussionsforum: kategorier + trådar + inlägg (Realtime)
app/(app)/leaderboard     — Topplista: aktivitet, tävling, mål
app/(app)/ai              — AI Coach: motivationshistorik + personlig analys
app/(app)/notifications   — Notiser: panel med olästa/lästa

### Extern länk
Matchi-länk → https://www.matchi.se/activities/search (öppnas i ny flik)

## Hitta Match — specifika regler
- Matchformer: Vinnarbana, Americano, Mexicano, Träning
- Nivåväljare 1–9: klicka två siffror för spann (t.ex. 4 och 6 = "Nivå 4–6")
- Speltid: 60, 90 eller 120 minuter
- Datum, tid och plats
- Valfritt meddelande
- När man anmäler sig → bokning skapas + kalender-event läggs till

## Mina Bokningar
- Samlar: anmälda partner-matcher + tävlingar från ledaren
- Stats: totalt, matcher, tävlingar
- Flikar: Alla / Hitta Match / Tävlingar / Historik
- Kalenderknapp per bokning → navigerar till rätt månad i kalendern
- Avboka-knapp för matcher (ej tävlingar)
- Tävlingar läggs automatiskt till när ledaren publicerar

## Kalender
- Månadsvy med navigation
- Färgkodning: blå=träning, guld=match/tävling, grön=partner-match
- Klicka dag för att se detaljer
- Bokningar synkas automatiskt

## Info från Ledaren
- Ledare/admin kan skapa inlägg med titel, text och video-URL (YouTube/Vimeo)
- Video visas som embed eller klickbar thumbnail
- Kommentarsfält under varje inlägg med Realtime-uppdateringar
- Ledarens egna svar markeras med guldlinje

## Notissystem
- Notis-panel (slide-in från höger)
- Typer: AI-motivation, träning, forum-svar, matchförfrågan, tävling
- Oläst-indikator (prick på klockan)
- "Markera alla lästa"
- Toast-notiser för direkta händelser

## AI Coach
- Generera personlig motivationstext via OpenAI API (gpt-4o-mini)
- Prompt baseras på: antal träningar, tävlingar, aktiva mål, dagar sedan senaste träning
- Spara genererade motivationer i ai_motivations-tabellen
- Visa historik över tidigare motivationer
- Visa styrkor + förbättringsområden baserat på statistik

## Färger & Design (IK Surds klubbfärger)
--bg: #06090f
--surface: #0c1020
--accent: #c9a84c   (guld)
--blue: #1a2fa0     (mörkblå)
--text: #eef0f8
Font: Bebas Neue för rubriker, Outfit för brödtext

## Miljövariabler (.env.local)
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
OPENAI_API_KEY=

## Starta med
1. Skapa monorepo-strukturen
2. Sätt upp Supabase-klienten i packages/shared
3. Bygg auth-flödet (login + register + Google)
4. Skapa dashboard som startpunkt
5. Sedan bygg ut sida för sida

Kom ihåg: delad Supabase-klient i packages/shared/src/supabase.ts så att både webb och mobil använder samma kod.
```
