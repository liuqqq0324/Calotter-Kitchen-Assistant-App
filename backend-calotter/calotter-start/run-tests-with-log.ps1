# 运行测试并保存完整输出到文件
# 使用方法: .\run-tests-with-log.ps1

param(
    [string]$TestName = "",
    [string]$OutputFile = "test-output-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
)

$projectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectDir

Write-Host "开始运行测试，输出将保存到: $OutputFile" -ForegroundColor Green

if ($TestName -eq "") {
    # 运行所有测试
    mvn test 2>&1 | Tee-Object -FilePath $OutputFile
} else {
    # 运行指定测试
    mvn test -Dtest=$TestName 2>&1 | Tee-Object -FilePath $OutputFile
}

Write-Host "`n测试完成！输出已保存到: $OutputFile" -ForegroundColor Green
Write-Host "文件位置: $(Resolve-Path $OutputFile)" -ForegroundColor Cyan
