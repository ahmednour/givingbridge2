# PowerShell script to update the API base URL in frontend/web/config.js
# Usage:
#   .\scripts\set-network-ip.ps1 localhost
#   .\scripts\set-network-ip.ps1 192.168.1.100

param(
    [Parameter(Mandatory=$true)]
    [string]$IP
)

$configPath = Join-Path $PSScriptRoot "..\frontend\web\config.js"

# Validate IP format
$isLocalhost = ($IP -eq "localhost") -or ($IP -eq "127.0.0.1")
$ipRegex = "^(\d{1,3}\.){3}\d{1,3}$"

if (-not $isLocalhost -and $IP -notmatch $ipRegex) {
    Write-Host "❌ Error: Invalid IP address format" -ForegroundColor Red
    Write-Host "Expected format: xxx.xxx.xxx.xxx or 'localhost'"
    exit 1
}

# Read current config
try {
    $config = Get-Content $configPath -Raw
} catch {
    Write-Host "❌ Error reading config file: $_" -ForegroundColor Red
    exit 1
}

# Update the IP
$newConfig = $config -replace 'API_BASE_URL: "http://[^:]+:3000/api"', "API_BASE_URL: `"http://$IP:3000/api`""
$newConfig = $newConfig -replace 'SOCKET_URL: "http://[^:]+:3000"', "SOCKET_URL: `"http://$IP:3000`""

# Write updated config
try {
    Set-Content -Path $configPath -Value $newConfig -NoNewline
    Write-Host "✅ Successfully updated config.js" -ForegroundColor Green
    Write-Host "📝 API_BASE_URL: http://$IP:3000/api"
    Write-Host "📝 SOCKET_URL: http://$IP:3000"
    Write-Host ""
    Write-Host "📦 Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Rebuild frontend: docker-compose build frontend"
    Write-Host "  2. Restart frontend: docker-compose up -d frontend"
    
    if (-not $isLocalhost) {
        Write-Host ""
        Write-Host "🔥 Firewall setup (Run as Administrator):" -ForegroundColor Yellow
        Write-Host '  netsh advfirewall firewall add rule name="GivingBridge Backend" dir=in action=allow protocol=TCP localport=3000'
        Write-Host '  netsh advfirewall firewall add rule name="GivingBridge Frontend" dir=in action=allow protocol=TCP localport=8080'
    }
} catch {
    Write-Host "❌ Error writing config file: $_" -ForegroundColor Red
    exit 1
}
