// lib/widgets/invite_qr_code_widget.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// 邀请二维码组件
/// 用于显示厨房邀请码的二维码
class InviteQrCodeWidget extends StatelessWidget {
  final String inviteCode;
  final String householdName;
  final double? size;

  const InviteQrCodeWidget({
    Key? key,
    required this.inviteCode,
    required this.householdName,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 生成包含邀请码的二维码数据
    // 格式：直接使用邀请码，扫描后解析
    final qrData = inviteCode;
    final qrSize = size ?? 200.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 二维码
          QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: qrSize,
            backgroundColor: Colors.white,
            errorCorrectionLevel: QrErrorCorrectLevel.M,
          ),
          const SizedBox(height: 16),
          // 邀请码文本
          Text(
            '邀请码',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            inviteCode,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          // 厨房名称
          if (householdName.isNotEmpty) ...[
            Text(
              householdName,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

