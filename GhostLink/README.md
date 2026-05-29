# GHOSTLINK v1.0

Aplikacja iOS (SwiftUI) – środowisko laboratoryjne / edukacyjne.  
**Login:** `revishef` / `revishef`

## Wymagania

- macOS + Xcode 14+
- iOS 15+ (ProMotion: animacje 120 FPS przez `TimelineView`)
- AltStore lub Apple Developer do podpisu `.ipa`

## Kompilacja

1. Otwórz `GhostLink.xcodeproj` w Xcode.
2. Ustaw **Team** w Signing & Capabilities.
3. Wygeneruj ikony (opcjonalnie na Mac/Windows z Pythonem):

```bash
pip install pillow
python scripts/generate_icons.py
```

4. **Product → Archive → Distribute App → Ad Hoc** → eksport `.ipa` do AltStore.

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

## AltStore

1. Zbuduj `.ipa` (Ad Hoc z Twoim UDID).
2. AltStore → Install from file / AltServer.
3. Odśwież certyfikat co 7 dni (darmowe Apple ID) lub 1 rok (płatne).

## GitHub Actions → .ipa bez Maca

Instrukcja krok po kroku (sekrety Apple, Run workflow, pobranie IPA):

**[docs/GITHUB_ACTIONS_PL.md](docs/GITHUB_ACTIONS_PL.md)**

- Workflow **Build IPA** – podpisany plik do AltStore (wymaga 6 sekretów).
- Workflow **Build Check** – tylko test kompilacji (bez sekretów).

---

**Wyłącznie do autoryzowanych ćwiczeń w izolowanej sieci uczelni.**
