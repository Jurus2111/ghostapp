# GHOSTLINK v1.0

Aplikacja iOS (SwiftUI) – środowisko laboratoryjne / edukacyjne.  
**Login:** `revishef` / `revishef`

## Wymagania

- **iOS 15+** na iPhone
- **AltStore** + **AltServer** (PC/Mac w tej samej sieci Wi‑Fi co telefon)
- Opcjonalnie: Mac + Xcode 14+ (lokalny build)

## Instalacja (jedyna metoda dystrybucji: AltStore)

**[docs/ALTSTORE_PL.md](docs/ALTSTORE_PL.md)** – pełna instrukcja.

Skrót: GitHub Actions buduje `GhostLink.ipa` → pobierz z **Artifacts** → AltStore → **+** → wybierz plik.

## Kompilacja lokalna (opcjonalnie, Mac)

1. Otwórz `GhostLink.xcodeproj` w Xcode.
2. Podłącz iPhone, wybierz Team (Apple ID) → **Run**.

Ikony: `python scripts/generate_icons.py` (wymaga `pip install pillow`).

## Moduły – jak działają

| Moduł | Działanie |
|--------|-----------|
| **Sniffer** | Przechwytywanie pakietów lab + status `NWPathMonitor`; eksport `.txt` |
| **Deauth** | Skan SSID (aktualna sieć + lista lab); symulacja deauth z logiem |
| **Fake AP** | Symulacja AP, live log połączeń, zapis w logach |
| **SMS Bomber** | Symulacja lokalna lub API Flask (`sms_backend/`) |
| **Harvester** | Lokalny WebView (klon UI), JS → zapis credentials na urządzeniu |

### Ograniczenia iOS (ważne na zajęciach)

Apple **nie pozwala** aplikacji ze sklepu/sideload na:

- prawdziwy monitor mode / deauth 802.11,
- tworzenie rogue AP z poziomu aplikacji,
- sniffing całego ruchu systemu bez specjalnych profili/entitlements.

W projekcie moduły sieciowe realizują pełny UX + logikę lab (symulacja + odczyt bieżącego SSID tam, gdzie iOS na to pozwala). Do testów „na żywo” użyjcie zewnętrznego sprzętu (Raspberry Pi, laptop Kali) zsynchronizowanego z logami aplikacji.

### SMS backend (lab)

```bash
cd sms_backend
pip install -r requirements.txt
python app.py
```

W aplikacji: wyłącz „Tryb symulacji”, ustaw URL `http://<IP_Maca>:5050`.

### Wi-Fi SSID (DEAUTH)

Dla odczytu nazwy sieci iOS może wymagać **Lokalizacji** oraz capability `Access WiFi Information` w profilu provisioning.

## Struktura

```
GhostLink/
  GhostLink/          # kod Swift
  GhostLink.xcodeproj
  sms_backend/        # Flask lab API
  scripts/            # generator ikon
```

## GitHub → IPA

Jeden workflow: **Build IPA for AltStore** – bez sekretów w repo.

Szczegóły: **[docs/GITHUB_ACTIONS_PL.md](docs/GITHUB_ACTIONS_PL.md)**

---

**Wyłącznie do autoryzowanych ćwiczeń w izolowanej sieci uczelni.**
