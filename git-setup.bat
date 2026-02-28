:: ─────────────────────────────────────────────────
:: IK Surd Padel App — Git Setup (Windows)
:: Kör denna fil EFTER att du skapat repot på GitHub
:: ─────────────────────────────────────────────────

@echo off
echo.
echo  Initierar Git för IK Surd Padel App...
echo.

:: Initiera git
git init

:: Skapa dev-branch direkt
git checkout -b main

:: Lägg till alla filer
git add .

:: Första commit
git commit -m "init: IK Surd Padel App - spec, schema, demo och dokumentation"

:: BYTA UT DIN_GITHUB_ANVÄNDARE mot ditt riktiga GitHub-användarnamn!
set GITHUB_USER=alexrabnor
set REPO_NAME=iksurd-padel

echo.
echo  Kopplar till GitHub...
git remote add origin https://github.com/%GITHUB_USER%/%REPO_NAME%.git

:: Pusha till main
git push -u origin main

:: Skapa dev-branch
git checkout -b dev
git push -u origin dev

echo.
echo  ✅ Klart! Repot är nu uppe på GitHub.
echo  Webb: https://github.com/%GITHUB_USER%/%REPO_NAME%
echo.
echo  Öppna projektet i Cursor med:
echo  cursor .
echo.
pause
