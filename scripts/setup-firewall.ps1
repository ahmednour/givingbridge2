# PowerShell script to setup Windows Firewall rules for GivingBridge
# Must be run as Administrator
# Usage:
#   .\scripts\setup-firewall.ps1 add    # Add firewall rules
#   .\scripts\setup-firewall.ps1 remove # Remove firewall rules

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("add", "remove")]
    [string]$Action
)

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "❌ Error: This script must be run as Administrator" -ForegroundColor Red
    Write-Host ""
    Write-Host "Right-click PowerShell and select 'Run as Administrator', then run:" -ForegroundColor Yellow
    Write-Host "  .\scripts\setup-firewall.ps1 $Action"
    exit 1
}

if ($Action -eq "add") {
    Write-Host "🔥 Adding Windows Firewall rules..." -ForegroundColor Yellow
    
    # Add rule for Backend (port 3000)
    try {
        netsh advfirewall firewall add rule name="GivingBridge Backend" dir=in action=allow protocol=TCP localport=3000 | Out-Null
        Write-Host "✅ Added rule for Backend (port 3000)" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Warning: Could not add Backend rule (may already exist)" -ForegroundColor Yellow
    }
    
    # Add rule for Frontend (port 8080)
    try {
        netsh advfirewall firewall add rule name="GivingBridge Frontend" dir=in action=allow protocol=TCP localport=8080 | Out-Null
        Write-Host "✅ Added rule for Frontend (port 8080)" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Warning: Could not add Frontend rule (may already exist)" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "✅ Firewall setup complete!" -ForegroundColor Green
    Write-Host "You can now access the application from other devices on your network."
    
} elseif ($Action -eq "remove") {
    Write-Host "🔥 Removing Windows Firewall rules..." -ForegroundColor Yellow
    
    # Remove Backend rule
    try {
        netsh advfirewall firewall delete rule name="GivingBridge Backend" | Out-Null
        Write-Host "✅ Removed rule for Backend" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Warning: Could not remove Backend rule (may not exist)" -ForegroundColor Yellow
    }
    
    # Remove Frontend rule
    try {
        netsh advfirewall firewall delete rule name="GivingBridge Frontend" | Out-Null
        Write-Host "✅ Removed rule for Frontend" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Warning: Could not remove Frontend rule (may not exist)" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "✅ Firewall rules removed!" -ForegroundColor Green
}
