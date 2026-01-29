#!/bin/bash
# 测试 Gemini API Key 是否可用
# 使用方法: ./test-gemini-api.sh

# 从 .env 文件读取 API Key
ENV_FILE=".env"
if [ ! -f "$ENV_FILE" ]; then
    echo "错误: 找不到 .env 文件"
    exit 1
fi

# 读取 GEMINI_API_KEY
API_KEY=$(grep "^GEMINI_API_KEY=" "$ENV_FILE" | cut -d'=' -f2 | tr -d ' ' | tr -d '"')

if [ -z "$API_KEY" ]; then
    echo "错误: 在 .env 文件中找不到 GEMINI_API_KEY"
    exit 1
fi

echo "正在测试 Gemini API Key..."
echo "API Key: ${API_KEY:0:20}..."
echo ""

# 构建请求
URL="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=$API_KEY"

BODY='{
  "contents": [{
    "parts": [{
      "text": "hi"
    }]
  }]
}'

echo "发送请求: POST $URL"
echo "消息内容: hi"
echo ""

# 发送请求
RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST "$URL" \
  -H "Content-Type: application/json" \
  -d "$BODY")

HTTP_STATUS=$(echo "$RESPONSE" | grep "HTTP_STATUS" | cut -d':' -f2)
BODY_CONTENT=$(echo "$RESPONSE" | sed '/HTTP_STATUS/d')

if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "✅ API 调用成功！"
    echo ""
    echo "响应内容:"
    echo "$BODY_CONTENT" | jq -r '.candidates[0].content.parts[0].text' 2>/dev/null || echo "$BODY_CONTENT"
    echo ""
    echo "✅ API Key 可用，未达到限额"
else
    echo "❌ API 调用失败！"
    echo ""
    echo "HTTP 状态码: $HTTP_STATUS"
    echo "错误详情:"
    echo "$BODY_CONTENT" | jq '.' 2>/dev/null || echo "$BODY_CONTENT"
    echo ""
    
    # 检查是否是配额错误
    if echo "$BODY_CONTENT" | grep -q "429\|quota\|Quota exceeded"; then
        echo "⚠️  检测到配额限制错误（429）"
        echo "API Key 已达到使用限额，请稍后重试或检查配额设置"
    fi
    
    exit 1
fi
