# GitHub Actions → GhostLink.ipa (tylko AltStore)

Ten projekt buduje **wyłącznie** plik do sideloadu przez [AltStore](https://altstore.io).

**Nie** używamy sekretów Apple w GitHubie. **Nie** publikujemy w App Store.

Pełna instrukcja instalacji: **[ALTSTORE_PL.md](ALTSTORE_PL.md)**

---

## Workflow

| Nazwa | Plik | Efekt |
|-------|------|--------|
| **Build IPA for AltStore** | `.github/workflows/build-ipa.yml` | Artefakt `GhostLink.ipa` |

Uruchamia się przy każdym `git push` na `main` lub ręcznie: Actions → Run workflow.

---

## Pobranie IPA

1. Actions → ostatni zielony run  
2. **Artifacts** → `GhostLink-ipa`  
3. Rozpakuj zip → `GhostLink.ipa`  
4. AltStore na iPhone → **+** → wybierz plik  

---

## Push z Windows (PowerShell)

```powershell
cd "c:\Users\user\Documents\ghost"
git add .
git commit -m "Twoja zmiana"
git push origin main
```

Repozytorium: [github.com/Jurus2111/ghostapp](https://github.com/Jurus2111/ghostapp)
