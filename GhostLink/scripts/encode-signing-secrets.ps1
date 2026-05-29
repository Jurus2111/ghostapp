# Koduje cert.p12 i .mobileprovision do Base64 pod sekrety GitHub Actions.
# Uzycie:
#   .\encode-signing-secrets.ps1 -P12Path "C:\certs\dev.p12" -ProfilePath "C:\certs\GhostLink.mobileprovision"

param(
    [Parameter(Mandatory = $true)]
    [string]$P12Path,

    [Parameter(Mandatory = $true)]
    [string]$ProfilePath
)

function Encode-FileToBase64([string]$Path) {
    if (-not (Test-Path $Path)) {
        Write-Error "Brak pliku: $Path"
        exit 1
    }
    return [Convert]::ToBase64String([IO.File]::ReadAllBytes($Path))
}

$p12B64 = Encode-FileToBase64 $P12Path
$profB64 = Encode-FileToBase64 $ProfilePath

Write-Host ""
Write-Host "=== GITHUB SECRETS (Repository -> Settings -> Secrets -> Actions) ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "BUILD_CERTIFICATE_BASE64 =" -ForegroundColor Yellow
Write-Host "(dlugosc: $($p12B64.Length) znakow - wklej calosc ponizej)"
Write-Host $p12B64
Write-Host ""
Write-Host "BUILD_PROVISIONING_PROFILE_BASE64 =" -ForegroundColor Yellow
Write-Host "(dlugosc: $($profB64.Length) znakow)"
Write-Host $profB64
Write-Host ""
Write-Host "Dodatkowo ustaw recznie:" -ForegroundColor Green
Write-Host "  APPLE_TEAM_ID              = Twoj Team ID z Apple Developer"
Write-Host "  PROVISIONING_PROFILE_NAME  = Dokladna nazwa profilu (nie UUID)"
Write-Host "  P12_PASSWORD               = Haslo do pliku .p12"
Write-Host "  KEYCHAIN_PASSWORD          = Dowolne haslo (np. GhostLinkCI2026!)"
Write-Host ""

# Opcjonalnie do schowka (tylko cert - moze byc za duzy)
try {
    Set-Clipboard -Value $p12B64
    Write-Host "BUILD_CERTIFICATE_BASE64 skopiowany do schowka." -ForegroundColor DarkGray
} catch {
    Write-Host "Schowek: plik za duzy - skopiuj recznie z konsoli." -ForegroundColor DarkGray
}
