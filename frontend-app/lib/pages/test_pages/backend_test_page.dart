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

    final String baseUrl = ApiConfig.baseUrl;

    try {
      final url = Uri.parse('$baseUrl/hello');
      final response = await http.get(url);

      // 🔥 修复点 1：请求回来后，先检查页面还在不在
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _responseMessage =
              "Success! \nServer says: ${data['Message'] ?? data}";
        });
      } else {
        setState(() {
          _responseMessage = "Error: Server returned ${response.statusCode}";
        });
      }
    } catch (e) {
      // 🔥 修复点 2：在 catch 里也要检查，因为报错时页面可能也已经关了
      if (!mounted) return;

      setState(() {
        _responseMessage =
            "Connection Failed!\nCheck if C# app is running.\nError: $e";
      });
    } finally {
      // 🔥 修复点 3：finally 里也要检查
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
