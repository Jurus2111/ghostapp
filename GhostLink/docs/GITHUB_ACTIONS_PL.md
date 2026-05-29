# GitHub Actions → budowa .ipa (GHOSTLINK)

Repozytorium: [github.com/Jurus2111/ghostapp](https://github.com/Jurus2111/ghostapp)

GitHub uruchamia build na **macOS** (runner w chmurze). Ty na Windowsie tylko wrzucasz kod i klikasz **Run workflow**.

---

## 1. Co musisz mieć od Apple

| Element | Opis |
|--------|------|
| **Apple ID** | Darmowe lub płatne Developer ($99/rok) |
| **Team ID** | [developer.apple.com/account](https://developer.apple.com/account) → Membership → Team ID |
| **Certyfikat .p12** | „Apple Development” (łatwiej) lub „Apple Distribution” (Ad Hoc) |
| **Provisioning Profile** | **iOS App Development** lub **Ad Hoc** dla bundle `edu.lab.ghostlink` |
| **UDID iPhone’a** | W profilu Ad Hoc – dodaj urządzenie w Certificates, Identifiers & Profiles |

**AltStore / sideload:** zwykle wystarczy **development** + profil Development z Twoim UDID.

Bez Maca: certyfikat możesz wygenerować na **iac.io** / **Codemagic** (trial) alaz poprosić kolegę z Maciem o eksport `.p12` + `.mobileprovision`.

---

## 2. Sekrety w GitHub (Settings → Secrets and variables → Actions)

Dodaj **Repository secrets**:

| Nazwa sekretu | Co wkleić |
|---------------|-----------|
| `APPLE_TEAM_ID` | np. `AB12CD34EF` |
| `PROVISIONING_PROFILE_NAME` | **dokładna nazwa** profilu z Apple (np. `GhostLink Development`) |
| `BUILD_CERTIFICATE_BASE64` | plik `.p12` zakodowany w Base64 (skrypt poniżej) |
| `P12_PASSWORD` | hasło do pliku `.p12` |
| `BUILD_PROVISIONING_PROFILE_BASE64` | plik `.mobileprovision` w Base64 |
| `KEYCHAIN_PASSWORD` | dowolne silne hasło (np. `GhostLinkCI2026!`) – tylko dla runnera |

### PowerShell – zakoduj pliki na sekrety (Windows)

```powershell
cd "c:\Users\user\Documents\ghost\GhostLink"
.\scripts\encode-signing-secrets.ps1 -P12Path "C:\sciezka\Certificates.p12" -ProfilePath "C:\sciezka\GhostLink.mobileprovision"
```

Skrypt wypisze gotowe linie do skopiowania do GitHub Secrets.

Ręcznie:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\sciezka\cert.p12")) | Set-Clipboard
# wklej jako BUILD_CERTIFICATE_BASE64

[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\sciezka\profile.mobileprovision")) | Set-Clipboard
# wklej jako BUILD_PROVISIONING_PROFILE_BASE64
```

---

## 3. Jak zbudować .ipa na GitHubie

1. Wypchnij kod: `git push` na branch `main`.
2. Wejdź: **Actions** → **Build IPA** → **Run workflow**.
3. **export_method:** wybierz `development` (domyślnie) lub `ad-hoc`.
4. Po zielonym buildzie: **Artifacts** → pobierz `GhostLink-<numer>.zip` → w środku jest **GhostLink.ipa**.
5. Zainstaluj przez **AltStore** (Open in AltStore / Install).

Workflow bez sekretów: **Build Check (no IPA)** – tylko test kompilacji na symulatorze.

---

## 4. Wypchnięcie projektu (PowerShell)

```powershell
cd "c:\Users\user\Documents\ghost"
git add .
git commit -m "Add GitHub Actions IPA build"
git push origin main
```

---

## 5. Typowe błędy

| Błąd | Rozwiązanie |
|------|-------------|
| Brakujące sekrety | Uzupełnij wszystkie 6 sekretów z tabeli |
| `No signing certificate` | Zły typ certyfikatu vs `export_method` |
| `Provisioning profile doesn't match` | Bundle ID w profilu = `edu.lab.ghostlink` |
| Ad Hoc – nie instaluje się | UDID telefonu musi być w profilu |
| `PROVISIONING_PROFILE_NAME` | To **nazwa** profilu, nie UUID |

---

## 6. Pliki CI w repo

```
.github/workflows/build-ipa.yml      ← buduje .ipa (wymaga sekretów)
.github/workflows/build-check.yml  ← kompilacja testowa
GhostLink/ci/ExportOptions.plist    ← szablon (w CI generowany automatycznie)
GhostLink/scripts/encode-signing-secrets.ps1
```
