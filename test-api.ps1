# GivingBridge API Test Script
# Run this with: powershell -ExecutionPolicy Bypass -File test-api.ps1

Write-Host "`n=== GIVINGBRIDGE API TESTING ===" -ForegroundColor Cyan
Write-Host "Testing against: http://localhost:3000`n" -ForegroundColor Gray

$baseUrl = "http://localhost:3000/api"
$testResults = @()

function Test-Endpoint {
    param(
        [string]$TestName,
        [string]$Method,
        [string]$Url,
        [object]$Body = $null,
        [hashtable]$Headers = @{}
    )
    
    Write-Host "Testing: $TestName..." -NoNewline
    
    try {
        $params = @{
            Uri = "$baseUrl$Url"
            Method = $Method
            Headers = $Headers
            ContentType = 'application/json'
        }
        
        if ($Body) {
            $params.Body = ($Body | ConvertTo-Json -Depth 5)
        }
        
        $response = Invoke-RestMethod @params
        Write-Host " PASS" -ForegroundColor Green
        $script:testResults += @{Name=$TestName; Status="PASS"; Response=$response}
        return $response
    }
    catch {
        $errorMsg = $_.Exception.Message
        if ($_.ErrorDetails.Message) {
            $errorMsg = ($_.ErrorDetails.Message | ConvertFrom-Json).message
        }
        Write-Host " FAIL: $errorMsg" -ForegroundColor Red
        $script:testResults += @{Name=$TestName; Status="FAIL"; Error=$errorMsg}
        return $null
    }
}

# Test 1: Health Check
Write-Host "`n--- SYSTEM HEALTH ---" -ForegroundColor Yellow
$healthResponse = Invoke-RestMethod -Uri "http://localhost:3000/health" -Method GET
Write-Host "Testing: Backend Health..." -NoNewline
if ($healthResponse.status -eq "healthy") {
    Write-Host " PASS" -ForegroundColor Green
    $script:testResults += @{Name="Backend Health"; Status="PASS"}
} else {
    Write-Host " FAIL" -ForegroundColor Red
    $script:testResults += @{Name="Backend Health"; Status="FAIL"}
}

# Test 2: Authentication
Write-Host "`n--- AUTHENTICATION ---" -ForegroundColor Yellow

# Login as Donor
$donorLogin = Test-Endpoint -TestName "Login as Donor" -Method "POST" -Url "/auth/login" -Body @{
    email = "demo@example.com"
    password = "demo123"
}

if ($donorLogin) {
    Write-Host "  → User: $($donorLogin.user.name)" -ForegroundColor Gray
    Write-Host "  → Role: $($donorLogin.user.role)" -ForegroundColor Gray
    $donorToken = $donorLogin.token
}

# Login as Receiver
$receiverLogin = Test-Endpoint -TestName "Login as Receiver" -Method "POST" -Url "/auth/login" -Body @{
    email = "receiver@example.com"
    password = "receive123"
}

if ($receiverLogin) {
    Write-Host "  → User: $($receiverLogin.user.name)" -ForegroundColor Gray
    $receiverToken = $receiverLogin.token
}

# Login as Admin
$adminLogin = Test-Endpoint -TestName "Login as Admin" -Method "POST" -Url "/auth/login" -Body @{
    email = "admin@givingbridge.com"
    password = "admin123"
}

if ($adminLogin) {
    Write-Host "  → User: $($adminLogin.user.name)" -ForegroundColor Gray
    $adminToken = $adminLogin.token
}

# Test 3: Donations (if donor logged in)
if ($donorToken) {
    Write-Host "`n--- DONATIONS ---" -ForegroundColor Yellow
    
    # Get all donations
    Test-Endpoint -TestName "Get All Donations" -Method "GET" -Url "/donations" -Headers @{
        Authorization = "Bearer $donorToken"
    }
    
    # Create donation
    $newDonation = Test-Endpoint -TestName "Create Donation" -Method "POST" -Url "/donations" -Body @{
        title = "Test Donation $(Get-Date -Format 'HHmmss')"
        description = "This is a test donation created by automated testing script"
        category = "books"
        condition = "good"
        location = "Test City, Test Country"
    } -Headers @{
        Authorization = "Bearer $donorToken"
    }
    
    if ($newDonation) {
        Write-Host "  → Created donation ID: $($newDonation.donation.id)" -ForegroundColor Gray
        $donationId = $newDonation.donation.id
        
        # Get specific donation
        Test-Endpoint -TestName "Get Donation by ID" -Method "GET" -Url "/donations/$donationId" -Headers @{
            Authorization = "Bearer $donorToken"
        }
        
        # Update donation
        Test-Endpoint -TestName "Update Donation" -Method "PUT" -Url "/donations/$donationId" -Body @{
            title = "Updated Test Donation"
            description = "Updated description"
        } -Headers @{
            Authorization = "Bearer $donorToken"
        }
        
        # Delete donation
        Test-Endpoint -TestName "Delete Donation" -Method "DELETE" -Url "/donations/$donationId" -Headers @{
            Authorization = "Bearer $donorToken"
        }
    }
}

# Test 4: Requests (if receiver logged in)
if ($receiverToken) {
    Write-Host "`n--- REQUESTS ---" -ForegroundColor Yellow
    
    # Get all requests
    Test-Endpoint -TestName "Get All Requests" -Method "GET" -Url "/requests" -Headers @{
        Authorization = "Bearer $receiverToken"
    }
}

# Test 5: Admin Operations (if admin logged in)
if ($adminToken) {
    Write-Host "`n--- ADMIN OPERATIONS ---" -ForegroundColor Yellow
    
    # Get all users
    Test-Endpoint -TestName "Get All Users" -Method "GET" -Url "/users" -Headers @{
        Authorization = "Bearer $adminToken"
    }
}

# Summary
Write-Host "`n=== TEST SUMMARY ===" -ForegroundColor Cyan
$passed = ($testResults | Where-Object {$_.Status -eq "PASS"}).Count
$failed = ($testResults | Where-Object {$_.Status -eq "FAIL"}).Count
$total = $testResults.Count

Write-Host "Total Tests: $total" -ForegroundColor White
Write-Host "Passed: $passed" -ForegroundColor Green
Write-Host "Failed: $failed" -ForegroundColor $(if($failed -gt 0){"Red"}else{"Green"})

if ($failed -gt 0) {
    Write-Host "`nFailed Tests:" -ForegroundColor Red
    $testResults | Where-Object {$_.Status -eq "FAIL"} | ForEach-Object {
        Write-Host "  - $($_.Name): $($_.Error)" -ForegroundColor Red
    }
}

Write-Host "`n"

