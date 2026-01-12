#!/bin/bash
# 简化的厨房邀请功能测试脚本

BASE_URL="http://localhost:8080"

echo "=========================================="
echo "测试厨房邀请功能 API"
echo "=========================================="

# 1. 用户1登录
echo ""
echo "1. 用户1登录..."
LOGIN1=$(curl -s -X POST "$BASE_URL/api/user/login" \
  -H "Content-Type: application/json" \
  -d '{"usernameOrEmail": "testuser1", "password": "password123"}')
echo "$LOGIN1" | python3 -m json.tool 2>/dev/null || echo "$LOGIN1"

TOKEN1=$(echo "$LOGIN1" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['token'])" 2>/dev/null)
USER1_ID=$(echo "$LOGIN1" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['userId'])" 2>/dev/null)

if [ -z "$TOKEN1" ] || [ "$TOKEN1" = "None" ]; then
    echo "❌ 用户1登录失败"
    exit 1
fi
echo "✅ User1 ID: $USER1_ID, Token: ${TOKEN1:0:30}..."

# 2. 用户2登录
echo ""
echo "2. 用户2登录..."
LOGIN2=$(curl -s -X POST "$BASE_URL/api/user/login" \
  -H "Content-Type: application/json" \
  -d '{"usernameOrEmail": "testuser2", "password": "password123"}')
echo "$LOGIN2" | python3 -m json.tool 2>/dev/null || echo "$LOGIN2"

TOKEN2=$(echo "$LOGIN2" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['token'])" 2>/dev/null)
USER2_ID=$(echo "$LOGIN2" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['userId'])" 2>/dev/null)

if [ -z "$TOKEN2" ] || [ "$TOKEN2" = "None" ]; then
    echo "❌ 用户2登录失败"
    exit 1
fi
echo "✅ User2 ID: $USER2_ID"

# 3. 用户1创建厨房
echo ""
echo "3. 用户1创建厨房..."
CREATE_HOUSEHOLD=$(curl -s -X POST "$BASE_URL/api/household" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN1" \
  -d "{\"name\": \"测试厨房\", \"ownerId\": $USER1_ID}")
echo "$CREATE_HOUSEHOLD" | python3 -m json.tool 2>/dev/null || echo "$CREATE_HOUSEHOLD"

HOUSEHOLD_ID=$(echo "$CREATE_HOUSEHOLD" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['id'])" 2>/dev/null)
INVITE_CODE=$(echo "$CREATE_HOUSEHOLD" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['inviteCode'])" 2>/dev/null)

if [ -z "$HOUSEHOLD_ID" ] || [ "$HOUSEHOLD_ID" = "None" ]; then
    echo "❌ 创建厨房失败"
    exit 1
fi
echo "✅ 厨房ID: $HOUSEHOLD_ID, 邀请码: $INVITE_CODE"

# 4. 测试重新生成邀请码
echo ""
echo "4. 测试重新生成邀请码..."
REGEN=$(curl -s -X PUT "$BASE_URL/api/household/$HOUSEHOLD_ID/regenerate-invite-code?ownerId=$USER1_ID" \
  -H "Authorization: Bearer $TOKEN1")
echo "$REGEN" | python3 -m json.tool 2>/dev/null || echo "$REGEN"

NEW_INVITE_CODE=$(echo "$REGEN" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['inviteCode'])" 2>/dev/null)
if [ "$INVITE_CODE" != "$NEW_INVITE_CODE" ] && [ "$NEW_INVITE_CODE" != "None" ]; then
    echo "✅ 邀请码已更新: $NEW_INVITE_CODE"
    INVITE_CODE=$NEW_INVITE_CODE
else
    echo "⚠️  邀请码未更新或相同"
fi

# 5. 用户2通过邀请码加入
echo ""
echo "5. 用户2通过邀请码加入..."
JOIN=$(curl -s -X POST "$BASE_URL/api/household/join?inviteCode=$INVITE_CODE&userId=$USER2_ID" \
  -H "Authorization: Bearer $TOKEN2")
echo "$JOIN" | python3 -m json.tool 2>/dev/null || echo "$JOIN"

# 6. 获取用户2加入的厨房列表
echo ""
echo "6. 获取用户2加入的厨房列表..."
JOINED=$(curl -s -X GET "$BASE_URL/api/household/user/$USER2_ID/joined" \
  -H "Authorization: Bearer $TOKEN2")
echo "$JOINED" | python3 -m json.tool 2>/dev/null || echo "$JOINED"

# 7. 用户2切换当前厨房
echo ""
echo "7. 用户2切换当前厨房..."
SWITCH=$(curl -s -X PUT "$BASE_URL/api/household/$HOUSEHOLD_ID/switch?userId=$USER2_ID" \
  -H "Authorization: Bearer $TOKEN2")
echo "$SWITCH" | python3 -m json.tool 2>/dev/null || echo "$SWITCH"

# 8. 用户1邀请用户2（通过用户名）
echo ""
echo "8. 用户1邀请用户2（通过用户名）..."
INVITE=$(curl -s -X POST "$BASE_URL/api/household/$HOUSEHOLD_ID/invite?usernameOrEmail=testuser2&inviterId=$USER1_ID" \
  -H "Authorization: Bearer $TOKEN1")
echo "$INVITE" | python3 -m json.tool 2>/dev/null || echo "$INVITE"

# 9. 用户2退出厨房
echo ""
echo "9. 用户2退出厨房..."
LEAVE=$(curl -s -X DELETE "$BASE_URL/api/household/$HOUSEHOLD_ID/leave?userId=$USER2_ID" \
  -H "Authorization: Bearer $TOKEN2")
echo "$LEAVE" | python3 -m json.tool 2>/dev/null || echo "$LEAVE"

# 10. 用户2重新加入
echo ""
echo "10. 用户2重新通过邀请码加入..."
JOIN2=$(curl -s -X POST "$BASE_URL/api/household/join?inviteCode=$INVITE_CODE&userId=$USER2_ID" \
  -H "Authorization: Bearer $TOKEN2")
echo "$JOIN2" | python3 -m json.tool 2>/dev/null || echo "$JOIN2"

# 11. 用户1踢出用户2
echo ""
echo "11. 用户1踢出用户2..."
REMOVE=$(curl -s -X DELETE "$BASE_URL/api/household/$HOUSEHOLD_ID/members/$USER2_ID?ownerId=$USER1_ID" \
  -H "Authorization: Bearer $TOKEN1")
echo "$REMOVE" | python3 -m json.tool 2>/dev/null || echo "$REMOVE"

echo ""
echo "=========================================="
echo "测试完成！"
echo "=========================================="

