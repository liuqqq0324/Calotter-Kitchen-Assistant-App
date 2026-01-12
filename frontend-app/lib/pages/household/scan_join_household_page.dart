// lib/pages/household/scan_join_household_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:personal_sous_chef/services/household_service.dart';

/// 扫描二维码加入厨房页面
class ScanJoinHouseholdPage extends StatefulWidget {
  const ScanJoinHouseholdPage({Key? key}) : super(key: key);

  @override
  State<ScanJoinHouseholdPage> createState() => _ScanJoinHouseholdPageState();
}

class _ScanJoinHouseholdPageState extends State<ScanJoinHouseholdPage> {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture barcodeCapture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = barcodeCapture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });
    controller.stop();

    try {
      // 解析二维码内容（可能是邀请码，或JSON格式）
      String inviteCode = code.trim();

      // 如果是JSON格式，解析它
      if (code.startsWith('{')) {
        try {
          final data = jsonDecode(code);
          inviteCode = data['code']?.toString() ?? code;
        } catch (e) {
          // 如果JSON解析失败，使用原始code
          inviteCode = code;
        }
      }

      // 调用加入厨房的API
      final result = await HouseholdService.joinHousehold(inviteCode: inviteCode);

      if (!mounted) return;

      if (result['success'] == true) {
        // 成功加入
        Navigator.pop(context, true); // 返回成功
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('成功加入厨房！'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // 加入失败
        setState(() {
          _errorMessage = result['error'] ?? '加入失败';
        });
        // 延迟后重新开始扫描
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && !_isProcessing) {
            controller.start();
            setState(() {
              _errorMessage = null;
            });
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '错误: $e';
      });
      // 延迟后重新开始扫描
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && !_isProcessing) {
          controller.start();
          setState(() {
            _errorMessage = null;
          });
        }
      });
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('扫描二维码加入厨房'),
        backgroundColor: Colors.orange.shade100,
      ),
      body: Stack(
        children: [
          // 扫描区域
          MobileScanner(
            controller: controller,
            onDetect: _handleBarcode,
          ),
          // 扫描框指示器
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.orange,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // 提示文字
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '将二维码放入框内扫描',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          // 处理中遮罩
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '正在处理...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // 错误提示
          if (_errorMessage != null && !_isProcessing)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

