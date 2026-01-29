# Test Gemini API Key
# Usage: .\test-gemini-api.ps1

# Enable TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Read API Key from .env file
$envFile = ".\.env"
if (-not (Test-Path $envFile)) {
    Write-Host "Error: .env file not found" -ForegroundColor Red
    exit 1
}

# Read GEMINI_API_KEY
$apiKey = ""
Get-Content $envFile | ForEach-Object {
    if ($_ -match "^GEMINI_API_KEY=(.+)$") {
        $apiKey = $matches[1].Trim()
    }
}

if ([string]::IsNullOrEmpty($apiKey)) {
    Write-Host "Error: GEMINI_API_KEY not found in .env file" -ForegroundColor Red
    exit 1
}

Write-Host "Testing Gemini API Key..." -ForegroundColor Yellow
Write-Host "API Key: $($apiKey.Substring(0, [Math]::Min(20, $apiKey.Length)))..." -ForegroundColor Gray
Write-Host ""

# Build request
$url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=$apiKey"

$body = @{
    contents = @(
        @{
            parts = @(
                @{
                    text = "hi"
                }
            )
        }
    )
} | ConvertTo-Json -Depth 10

Write-Host "Sending request: POST $url" -ForegroundColor Cyan
Write-Host "Message: hi" -ForegroundColor Cyan
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json" -ErrorAction Stop
    
    Write-Host "SUCCESS: API call successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Response:" -ForegroundColor Yellow
    if ($response.candidates -and $response.candidates[0].content -and $response.candidates[0].content.parts) {
        $responseText = $response.candidates[0].content.parts[0].text
        Write-Host $responseText -ForegroundColor White
    } else {
        Write-Host ($response | ConvertTo-Json -Depth 10) -ForegroundColor White
    }
    Write-Host ""
    Write-Host "API Key is valid and not rate limited" -ForegroundColor Green
    
} catch {
    Write-Host "FAILED: API call failed!" -ForegroundColor Red
    Write-Host ""
    
    $statusCode = $null
    $responseBody = $null
    
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "HTTP Status Code: $statusCode" -ForegroundColor Red
        
        try {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $responseBody = $reader.ReadToEnd()
            $reader.Close()
            $stream.Close()
        } catch {
            # Ignore stream reading errors
        }
    }
    
    if ($responseBody) {
        Write-Host "Error Details:" -ForegroundColor Red
        Write-Host $responseBody -ForegroundColor Red
        
        if ($responseBody -match "429" -or $responseBody -match "quota" -or $responseBody -match "Quota exceeded") {
            Write-Host ""
            Write-Host "WARNING: Rate limit error (429) detected" -ForegroundColor Yellow
            Write-Host "API Key has reached quota limit. Please retry later or check quota settings." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    exit 1
}
