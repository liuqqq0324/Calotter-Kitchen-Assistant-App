// lib/pages/profile/backend_test_page.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:personal_sous_chef/config/api_config.dart';

class BackendTestPage extends StatefulWidget {
  const BackendTestPage({super.key});

  @override
  State<BackendTestPage> createState() => _BackendTestPageState();
}

class _BackendTestPageState extends State<BackendTestPage> {
  // 用于显示返回结果
  String _responseMessage = "Click the button to test connection";
  bool _isLoading = false;

  // 🔥 C# 后端测试逻辑
  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _responseMessage = "Connecting to C# Backend...";
    });

    // 🔥 2. 原来的那些 const IP 和 Port 统统删掉
    // 直接使用配置文件里的 baseUrl
    final String baseUrl = ApiConfig.baseUrl;

    // 打印一下方便调试，看看拼出来的对不对
    print("正在尝试连接: $baseUrl");

    try {
      // 假设你在 C# 里写的接口是 [HttpGet] public IActionResult Get() ...
      // 且 Controller 上的 Route 是 [Route("[controller]")] -> 对应 /weatherforecast 或 /hello
      final url = Uri.parse('$baseUrl/hello'); // 👈 记得改成你 C# 里的控制器名字

      final response = await http.get(url);

      if (response.statusCode == 200) {
        // 成功连通！
        final data = jsonDecode(response.body);
        setState(() {
          // 假设 C# 返回的是 { "Message": "..." }，注意 C# 默认属性首字母大写
          _responseMessage =
              "Success! \nServer says: ${data['Message'] ?? data}";
        });
      } else {
        setState(() {
          _responseMessage = "Error: Server returned ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage =
            "Connection Failed!\nCheck if C# app is running.\nError: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Backend Integration Test"),
        backgroundColor: Colors.purple.shade100, // 用个不同的颜色区分一下
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 状态显示区域
            Container(
              padding: const EdgeInsets.all(20),
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : SingleChildScrollView(
                        child: Text(
                          _responseMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: _responseMessage.contains("Success")
                                ? Colors.green
                                : Colors.black87,
                            fontWeight: _responseMessage.contains("Success")
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),

            // 测试按钮
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testConnection,
              icon: const Icon(Icons.network_check, color: Colors.white),
              label: const Text(
                "Ping C# Backend",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Note: Make sure your C# app is running via 'dotnet run' and check the port number.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
