# ghostapp

Repozytorium **GHOSTLINK** – iOS (SwiftUI), build `.ipa` przez GitHub Actions.

| Folder / plik | Opis |
|---------------|------|
| [GhostLink/](GhostLink/) | Projekt Xcode |
| [.github/workflows/](.github/workflows/) | CI: **Build IPA** + **Build Check** |
| [GhostLink/docs/GITHUB_ACTIONS_PL.md](GhostLink/docs/GITHUB_ACTIONS_PL.md) | **Instrukcja IPA na GitHubie (PL)** |

## Szybki start

1. Ustaw [sekrety Apple w GitHub](GhostLink/docs/GITHUB_ACTIONS_PL.md#2-sekrety-w-github-settings--secrets-and-variables--actions).
2. Wypchnij kod (PowerShell):

```powershell
cd "c:\Users\user\Documents\ghost"
git add .
git commit -m "Add GitHub Actions IPA workflows"
git push origin main
```

3. GitHub → **Actions** → **Build IPA** → **Run workflow** → pobierz **Artifacts**.

Login aplikacji: `revishef` / `revishef`
