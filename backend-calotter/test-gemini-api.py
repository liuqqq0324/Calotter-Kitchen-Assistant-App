#!/usr/bin/env python3
"""
测试 Gemini API Key 是否可用
使用方法: python test-gemini-api.py
"""

import os
import json
import requests
from pathlib import Path

# 读取 .env 文件
env_file = Path(__file__).parent / ".env"
api_key = None

if env_file.exists():
    with open(env_file, 'r', encoding='utf-8') as f:
        for line in f:
            if line.startswith("GEMINI_API_KEY="):
                api_key = line.split("=", 1)[1].strip().strip('"').strip("'")
                break

if not api_key:
    print("Error: GEMINI_API_KEY not found in .env file")
    exit(1)

print("Testing Gemini API Key...")
print(f"API Key: {api_key[:20]}...")
print()

# Build request
url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key={api_key}"

payload = {
    "contents": [{
        "parts": [{
            "text": "hi"
        }]
    }]
}

headers = {
    "Content-Type": "application/json"
}

print(f"Sending request: POST {url}")
print("Message: hi")
print()

try:
    response = requests.post(url, json=payload, headers=headers, timeout=10)
    
    if response.status_code == 200:
        print("SUCCESS: API call successful!")
        print()
        print("Response:")
        data = response.json()
        if 'candidates' in data and len(data['candidates']) > 0:
            if 'content' in data['candidates'][0] and 'parts' in data['candidates'][0]['content']:
                response_text = data['candidates'][0]['content']['parts'][0]['text']
                print(response_text)
            else:
                print(json.dumps(data, indent=2, ensure_ascii=False))
        else:
            print(json.dumps(data, indent=2, ensure_ascii=False))
        print()
        print("API Key is valid and not rate limited")
    else:
        print(f"FAILED: API call failed!")
        print()
        print(f"HTTP Status Code: {response.status_code}")
        print("Error Details:")
        try:
            error_data = response.json()
            print(json.dumps(error_data, indent=2, ensure_ascii=False))
        except:
            print(response.text)
        
        # Check for quota error
        error_text = response.text
        if response.status_code == 429 or "quota" in error_text.lower() or "Quota exceeded" in error_text:
            print()
            print("WARNING: Rate limit error (429) detected")
            print("API Key has reached quota limit. Please retry later or check quota settings.")
        
        exit(1)

except requests.exceptions.RequestException as e:
    print(f"Request failed: {e}")
    exit(1)
