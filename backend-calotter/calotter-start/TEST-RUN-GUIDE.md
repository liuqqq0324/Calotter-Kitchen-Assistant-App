# 测试运行和日志记录指南

## 方法一：使用提供的脚本（最简单）

### PowerShell 脚本

```powershell
# 运行所有测试并保存输出
.\run-tests-with-log.ps1

# 运行指定测试类
.\run-tests-with-log.ps1 -TestName "UserRegistrationAndLoginIntegrationTest"

# 指定输出文件名
.\run-tests-with-log.ps1 -OutputFile "my-test-log.log"
```

### Batch 脚本（Windows CMD）

```cmd
# 运行所有测试并保存输出
run-tests-with-log.bat

# 运行指定测试类
run-tests-with-log.bat UserRegistrationAndLoginIntegrationTest

# 指定输出文件名
run-tests-with-log.bat "" my-test-log.log
```

## 方法二：直接使用 PowerShell 命令

### 同时显示和保存输出（推荐）

```powershell
# 运行所有测试，同时显示在终端和保存到文件
mvn test 2>&1 | Tee-Object -FilePath "test-output.log"

# 运行指定测试
mvn test -Dtest=UserRegistrationAndLoginIntegrationTest 2>&1 | Tee-Object -FilePath "test-output.log"

# 带时间戳的文件名
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
mvn test 2>&1 | Tee-Object -FilePath "test-output-$timestamp.log"
```

### 只保存到文件（不显示在终端）

```powershell
# 保存所有输出（包括错误）到文件
mvn test > test-output.log 2>&1

# 运行指定测试
mvn test -Dtest=UserRegistrationAndLoginIntegrationTest > test-output.log 2>&1
```

### 追加到现有文件

```powershell
# 追加输出到现有文件
mvn test 2>&1 | Tee-Object -FilePath "test-output.log" -Append
```

## 方法三：使用 CMD 命令

```cmd
# 保存所有输出到文件
mvn test > test-output.log 2>&1

# 运行指定测试
mvn test -Dtest=UserRegistrationAndLoginIntegrationTest > test-output.log 2>&1

# 追加到现有文件
mvn test >> test-output.log 2>&1
```

## 方法四：使用 Maven Surefire 报告

Maven 会自动生成测试报告：

```
target/surefire-reports/
├── TEST-*.xml          # 测试结果XML
└── *.txt               # 测试输出文本
```

查看报告：
```bash
# 查看所有测试报告
cat target/surefire-reports/*.txt

# 查看特定测试报告
cat target/surefire-reports/TEST-UserRegistrationAndLoginIntegrationTest.txt
```

## 方法五：详细调试输出

```powershell
# 保存详细调试信息
mvn test -X 2>&1 | Tee-Object -FilePath "test-debug.log"

# 保存错误详情
mvn test -e 2>&1 | Tee-Object -FilePath "test-error.log"
```

## 输出文件说明

- `2>&1` - 将标准错误重定向到标准输出（确保错误信息也被保存）
- `Tee-Object` - PowerShell命令，同时显示和保存输出
- `>` - 覆盖文件
- `>>` - 追加到文件

## 推荐工作流程

1. **日常测试**：使用 `Tee-Object` 同时查看和保存
   ```powershell
   mvn test 2>&1 | Tee-Object -FilePath "test-output.log"
   ```

2. **CI/CD 或后台运行**：只保存到文件
   ```powershell
   mvn test > test-output.log 2>&1
   ```

3. **调试问题**：保存详细日志
   ```powershell
   mvn test -X -e 2>&1 | Tee-Object -FilePath "test-debug.log"
   ```

## 查看日志文件

```powershell
# 在 PowerShell 中查看
Get-Content test-output.log

# 分页查看
Get-Content test-output.log | More

# 查看最后50行
Get-Content test-output.log -Tail 50

# 在编辑器中打开
notepad test-output.log
code test-output.log  # VS Code
```

## 示例：运行集成测试并保存日志

```powershell
# 进入测试目录
cd backend-calotter\calotter-start

# 运行所有集成测试并保存
mvn test -Dtest=*IntegrationTest 2>&1 | Tee-Object -FilePath "integration-tests-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

# 或者使用脚本
.\run-tests-with-log.ps1 -TestName "*IntegrationTest"
```
