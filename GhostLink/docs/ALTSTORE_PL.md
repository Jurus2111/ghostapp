# GHOSTLINK – instalacja tylko przez AltStore

Aplikacja **nie jest** na App Store. Dystrybucja wyłącznie jako `.ipa` + **AltStore** / **AltServer**.

---

## 1. Zbuduj IPA na GitHubie (bez Maca)

1. Wypchnij kod na `main`:
   ```powershell
   cd "c:\Users\user\Documents\ghost"
   git add .
   git commit -m "update"
   git push origin main
   ```
2. [github.com/Jurus2111/ghostapp/actions](https://github.com/Jurus2111/ghostapp/actions)
3. Workflow: **Build IPA for AltStore**
4. Po zielonym buildzie: **Artifacts** → `GhostLink-ipa` → pobierz **`GhostLink.ipa`**

Nie ustawiasz żadnych sekretów Apple w GitHubie – podpis robi **AltStore** przy instalacji.

---

## 2. Przygotuj iPhone

| Krok | Co zrobić |
|------|-----------|
| AltStore | Zainstaluj z [altstore.io](https://altstore.io) ( przez AltServer na PC/Mac ) |
| To samo Wi‑Fi | iPhone i komputer z AltServer w jednej sieci |
| Zaufaj deweloperowi | Ustawienia → Ogólne → VPN i zarządzanie urządzeniem → zaufaj profilowi po pierwszej instalacji |

---

## 3. Zainstaluj GhostLink.ipa

1. Przenieś `GhostLink.ipa` na iPhone (AirDrop, Pliki, mail).
2. Otwórz **AltStore** → zakładka **My Apps** → **+** (góra lewa).
3. Wybierz `GhostLink.ipa`.
4. Zaloguj się Apple ID w AltStore (jeśli trzeba) – to **podpisze** aplikację na 7 dni (darmowe konto).

**Login w aplikacji:** `revishef` / `revishef`

---

## 4. Odświeżanie (co 7 dni)

Darmowe Apple ID: aplikacja wygasa po ~7 dniach.

- Otwórz **AltStore** na iPhone (z włączonym AltServer na PC).
- **Refresh** przy GhostLink – lub włącz **Background Refresh** w AltStore.

---

## 5. Opcjonalnie: build na Macu (Xcode)

Jeśli masz Maca:

1. Otwórz `GhostLink.xcodeproj`
2. Podłącz iPhone → wybierz urządzenie → **Run** (Xcode podpisze i zainstaluje)

Albo: **Product → Archive → Distribute → Development** → `.ipa` → ten sam plik wrzucasz do AltStore.

---

## Rozwiązywanie problemów

| Problem | Rozwiązanie |
|---------|-------------|
| AltStore „Unable to install” | AltServer włączony, to samo Wi‑Fi, restart AltServer |
| „Integrity could not be verified” | Ustawienia → Zaufaj deweloperowi |
| GitHub Actions czerwony | Actions → logi → wyślij screenshot / issue |
| Aplikacja znika po tygodniu | Normalne – **Refresh** w AltStore |

---

**Tylko AltStore / sideload – nie App Store.**
