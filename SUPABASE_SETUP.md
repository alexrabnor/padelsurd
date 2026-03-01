# IK Surd Padel - Koppla till Supabase

Steg-för-steg så att inloggning och databas fungerar.

---

## Steg 1: Kör schemat i Supabase

1. Gå till [supabase.com](https://supabase.com) → **Dashboard**
2. Öppna ditt projekt (t.ex. oymftbcxbmyvtxemtduy)
3. Gå till **SQL Editor**
4. Skapa ny query och klistra in hela innehållet från **supabase-install.sql**
5. Klicka **Run**

Om du får fel typ "relation profiles already exists" betyder det att projektet redan har tabellerna. Då ska du i stället köra **supabase-migrations.sql** för att lägga till saknade tabeller.

---

## Steg 2: Tillåt localhost för Auth

1. I Supabase Dashboard → **Authentication** → **URL Configuration**
2. Under **Redirect URLs**, lägg till:
   - `http://localhost:38019/iksurd-padel-app.html`
   - `http://localhost:38019/**`
   - (Lägg till andra portar om du använder dem, t.ex. 3000)
3. Under **Site URL** kan du ställa in `http://localhost:38019` under utveckling
4. Spara

---

## Steg 3: Aktivera e-postregistrering (om behövs)

1. **Authentication** → **Providers** → **Email**
2. Kontrollera att **Enable Email Signup** är på
3. För enklare test: **Authentication** → **Providers** → sätt **Confirm email** till OFF (så du kan logga in direkt utan bekräftelse)

---

## Steg 4: Testa appen

1. Starta servern: `npx serve . -p 38019`
2. Öppna `http://localhost:38019/iksurd-padel-app.html`
3. Skapa konto med e-post och lösenord
4. Logga in och testa "Hitta Match"

---

## Felsökning

- **"Invalid login credentials"** – Fel lösenord eller användaren finns inte
- **"relation profiles does not exist"** – Kör supabase-install.sql
- **OAuth-redirect till fel URL** – Lägg till din localhost-URL under Redirect URLs i Steg 2
- **"new row violates row-level security"** – Kontrollera att RLS-policies är skapade (schema ska göra det)
