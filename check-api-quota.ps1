# 检查 Gemini API 配额脚本
# 发送简短消息测试 API 是否可用，检查是否超过每日配额

$ErrorActionPreference = "Stop"

# 读取 API Key
$envFile = "backend-calotter\.env"
if (-not (Test-Path $envFile)) {
    Write-Host "错误: 找不到 .env 文件" -ForegroundColor Red
    exit 1
}

$apiKey = $null
Get-Content $envFile | ForEach-Object {
    if ($_ -match "^GEMINI_API_KEY=(.+)$") {
        $apiKey = $matches[1].Trim()
    }
}

if ([string]::IsNullOrEmpty($apiKey)) {
    Write-Host "错误: 找不到 GEMINI_API_KEY" -ForegroundColor Red
    exit 1
}

Write-Host "正在测试 API..." -ForegroundColor Yellow

# API 配置
$model = "gemini-2.5-flash"
$apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent"
$headers = @{
    "x-goog-api-key" = $apiKey
    "Content-Type" = "application/json"
}
$body = '{"contents":[{"parts":[{"text":"Hi"}]}]}'

try {
    $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $body -ErrorAction Stop
    
    if ($response.candidates -and $response.candidates.Count -gt 0) {
        $text = $response.candidates[0].content.parts[0].text
        Write-Host "成功! API 配额正常" -ForegroundColor Green
        Write-Host "响应: $text" -ForegroundColor Green
        exit 0
    }
}
catch {
    $statusCode = $null
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
    }
    
    Write-Host "请求失败!" -ForegroundColor Red
    Write-Host "错误: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($statusCode -eq 429) {
        Write-Host "检测到配额超限 (429)!" -ForegroundColor Red
        exit 1
    }
    
    # 尝试解析错误详情
    try {
        if ($_.Exception.Response) {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $errorJson = $reader.ReadToEnd() | ConvertFrom-Json
            if ($errorJson.error -and $errorJson.error.message) {
                $msg = $errorJson.error.message
                Write-Host "错误详情: $msg" -ForegroundColor Red
                if ($msg -match "quota|rate limit|RESOURCE_EXHAUSTED|429") {
                    Write-Host "这是配额相关错误!" -ForegroundColor Red
                }
            }
        }
    }
    catch {
        # 忽略解析错误
    }
    
    exit 1
}
