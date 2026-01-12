#!/bin/bash
# 测试厨房邀请功能 API

BASE_URL="http://localhost:8080"
echo "=========================================="
echo "测试厨房邀请功能 API"
echo "=========================================="

# 检查 jq 是否安装
if ! command -v jq &> /dev/null; then
    echo "警告: jq 未安装，将使用 grep 解析 JSON"
    USE_JQ=false
else
    USE_JQ=true
fi

# 1. 创建两个测试用户（如果不存在）
echo ""
echo "1. 创建测试用户..."
echo "创建用户1..."
USER1_RESPONSE=$(curl -s -X POST "$BASE_URL/api/user/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser1",
    "email": "test1@example.com",
    "password": "password123"
  }')
if [ "$USE_JQ" = true ]; then
    echo "$USER1_RESPONSE" | jq '.'
else
    echo "$USER1_RESPONSE"
fi

echo "创建用户2..."
USER2_RESPONSE=$(curl -s -X POST "$BASE_URL/api/user/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser2",
    "email": "test2@example.com",
    "password": "password123"
  }')
if [ "$USE_JQ" = true ]; then
    echo "$USER2_RESPONSE" | jq '.'
else
    echo "$USER2_RESPONSE"
fi

# 2. 用户1登录获取token（注册时已经返回了token，直接使用）
echo ""
echo "2. 用户1登录..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/user/login" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser1",
    "password": "password123"
  }')
if [ "$USE_JQ" = true ]; then
    TOKEN1=$(echo $LOGIN_RESPONSE | jq -r '.data.token // empty')
    USER1_ID=$(echo $LOGIN_RESPONSE | jq -r '.data.userId // empty')
    # 如果登录失败，尝试从注册响应中获取
    if [ -z "$TOKEN1" ] || [ "$TOKEN1" = "null" ]; then
        TOKEN1=$(echo $USER1_RESPONSE | jq -r '.data.token // empty')
        USER1_ID=$(echo $USER1_RESPONSE | jq -r '.data.userId // empty')
    fi
else
    TOKEN1=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | head -1 | cut -d'"' -f4)
    USER1_ID=$(echo $LOGIN_RESPONSE | grep -o '"userId":[0-9]*' | head -1 | cut -d':' -f2)
    # 如果登录失败，尝试从注册响应中获取
    if [ -z "$TOKEN1" ]; then
        TOKEN1=$(echo $USER1_RESPONSE | grep -o '"token":"[^"]*' | head -1 | cut -d'"' -f4)
        USER1_ID=$(echo $USER1_RESPONSE | grep -o '"userId":[0-9]*' | head -1 | cut -d':' -f2)
    fi
fi
echo "User1 ID: $USER1_ID"
echo "Token: ${TOKEN1:0:20}..."

# 3. 用户1创建厨房
echo ""
echo "3. 用户1创建厨房..."
HOUSEHOLD_RESPONSE=$(curl -s -X POST "$BASE_URL/api/household" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN1" \
  -d "{
    \"name\": \"测试厨房\",
    \"ownerId\": $USER1_ID
  }")
if [ "$USE_JQ" = true ]; then
    HOUSEHOLD_ID=$(echo $HOUSEHOLD_RESPONSE | jq -r '.data.id')
    INVITE_CODE=$(echo $HOUSEHOLD_RESPONSE | jq -r '.data.inviteCode')
    echo "$HOUSEHOLD_RESPONSE" | jq '.'
else
    HOUSEHOLD_ID=$(echo $HOUSEHOLD_RESPONSE | grep -o '"id":[0-9]*' | cut -d':' -f2)
    INVITE_CODE=$(echo $HOUSEHOLD_RESPONSE | grep -o '"inviteCode":"[^"]*' | cut -d'"' -f4)
    echo "$HOUSEHOLD_RESPONSE"
fi
echo "厨房ID: $HOUSEHOLD_ID"
echo "邀请码: $INVITE_CODE"

# 4. 测试重新生成邀请码
echo ""
echo "4. 测试重新生成邀请码..."
NEW_INVITE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/household/$HOUSEHOLD_ID/regenerate-invite-code?ownerId=$USER1_ID" \
  -H "Authorization: Bearer $TOKEN1")
if [ "$USE_JQ" = true ]; then
    NEW_INVITE_CODE=$(echo $NEW_INVITE_RESPONSE | jq -r '.data.inviteCode')
    echo "$NEW_INVITE_RESPONSE" | jq '.'
else
    NEW_INVITE_CODE=$(echo $NEW_INVITE_RESPONSE | grep -o '"inviteCode":"[^"]*' | cut -d'"' -f4)
    echo "$NEW_INVITE_RESPONSE"
fi
echo "新邀请码: $NEW_INVITE_CODE"
if [ "$INVITE_CODE" != "$NEW_INVITE_CODE" ]; then
  echo "✅ 邀请码已更新"
else
  echo "❌ 邀请码未更新"
fi

# 5. 用户2通过邀请码加入
echo ""
echo "6. 用户2通过邀请码加入..."
JOIN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/household/join?inviteCode=$NEW_INVITE_CODE&userId=$USER2_ID" \
  -H "Authorization: Bearer $TOKEN2")
if [ "$USE_JQ" = true ]; then
    echo "$JOIN_RESPONSE" | jq '.'
else
    echo "$JOIN_RESPONSE"
fi

# 6. 获取用户2加入的厨房列表
echo ""
echo "7. 获取用户2加入的厨房列表..."
JOINED_RESPONSE=$(curl -s -X GET "$BASE_URL/api/household/user/$USER2_ID/joined" \
  -H "Authorization: Bearer $TOKEN2")
if [ "$USE_JQ" = true ]; then
    echo "$JOINED_RESPONSE" | jq '.'
else
    echo "$JOINED_RESPONSE"
fi

# 7. 用户2切换当前厨房
echo ""
echo "8. 用户2切换当前厨房..."
SWITCH_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/household/$HOUSEHOLD_ID/switch?userId=$USER2_ID" \
  -H "Authorization: Bearer $TOKEN2")
if [ "$USE_JQ" = true ]; then
    echo "$SWITCH_RESPONSE" | jq '.'
else
    echo "$SWITCH_RESPONSE"
fi

# 9. 用户1邀请用户2（通过用户名）
echo ""
echo "9. 用户1邀请用户2（通过用户名）..."
INVITE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/household/$HOUSEHOLD_ID/invite?usernameOrEmail=testuser2&inviterId=$USER1_ID" \
  -H "Authorization: Bearer $TOKEN1")
if [ "$USE_JQ" = true ]; then
    echo "$INVITE_RESPONSE" | jq '.'
else
    echo "$INVITE_RESPONSE"
fi

# 9. 用户2退出厨房
echo ""
echo "10. 用户2退出厨房..."
LEAVE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/api/household/$HOUSEHOLD_ID/leave?userId=$USER2_ID" \
  -H "Authorization: Bearer $TOKEN2")
if [ "$USE_JQ" = true ]; then
    echo "$LEAVE_RESPONSE" | jq '.'
else
    echo "$LEAVE_RESPONSE"
fi

# 10. 用户2重新加入
echo ""
echo "11. 用户2重新通过邀请码加入..."
JOIN_RESPONSE2=$(curl -s -X POST "$BASE_URL/api/household/join?inviteCode=$NEW_INVITE_CODE&userId=$USER2_ID" \
  -H "Authorization: Bearer $TOKEN2")
if [ "$USE_JQ" = true ]; then
    echo "$JOIN_RESPONSE2" | jq '.'
else
    echo "$JOIN_RESPONSE2"
fi

# 11. 用户1踢出用户2
echo ""
echo "12. 用户1踢出用户2..."
REMOVE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/api/household/$HOUSEHOLD_ID/members/$USER2_ID?ownerId=$USER1_ID" \
  -H "Authorization: Bearer $TOKEN1")
if [ "$USE_JQ" = true ]; then
    echo "$REMOVE_RESPONSE" | jq '.'
else
    echo "$REMOVE_RESPONSE"
fi

echo ""
echo "=========================================="
echo "测试完成！"
echo "=========================================="

