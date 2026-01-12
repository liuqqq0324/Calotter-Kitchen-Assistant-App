// lib/pages/household/household_manage_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_sous_chef/services/household_service.dart';
import 'package:personal_sous_chef/widgets/invite_qr_code_widget.dart';
import 'package:personal_sous_chef/widgets/sketchy_button.dart';
import 'package:personal_sous_chef/widgets/sketchy_card.dart';
import 'package:personal_sous_chef/pages/household/scan_join_household_page.dart';
import 'package:flutter/services.dart';

/// 厨房管理页面
/// 包含邀请码、二维码、加入、退出、切换等功能
class HouseholdManagePage extends StatefulWidget {
  const HouseholdManagePage({Key? key}) : super(key: key);

  @override
  State<HouseholdManagePage> createState() => _HouseholdManagePageState();
}

class _HouseholdManagePageState extends State<HouseholdManagePage> {
  Map<String, dynamic>? _currentHousehold;
  List<Map<String, dynamic>> _joinedHouseholds = [];
  bool _isLoading = true;
  final TextEditingController _inviteCodeController = TextEditingController();
  final TextEditingController _inviteUserController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHouseholdData();
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    _inviteUserController.dispose();
    super.dispose();
  }

  Future<void> _loadHouseholdData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 获取当前厨房
      final currentResult = await HouseholdService.getCurrentHousehold();
      if (currentResult['success'] == true && currentResult['data'] != null) {
        _currentHousehold = currentResult['data'];
      }

      // 获取已加入的厨房列表
      final joinedResult = await HouseholdService.getJoinedHouseholds();
      if (joinedResult['success'] == true && joinedResult['data'] != null) {
        _joinedHouseholds = List<Map<String, dynamic>>.from(joinedResult['data']);
      }
    } catch (e) {
      print('Error loading household data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _joinByInviteCode() async {
    final inviteCode = _inviteCodeController.text.trim();
    if (inviteCode.isEmpty) {
      _showSnackBar('请输入邀请码', isError: true);
      return;
    }

    try {
      final result = await HouseholdService.joinHousehold(inviteCode: inviteCode);
      if (result['success'] == true) {
        _showSnackBar('成功加入厨房！');
        _inviteCodeController.clear();
        await _loadHouseholdData();
      } else {
        _showSnackBar(result['error'] ?? '加入失败', isError: true);
      }
    } catch (e) {
      _showSnackBar('网络错误: $e', isError: true);
    }
  }

  Future<void> _regenerateInviteCode() async {
    if (_currentHousehold == null) {
      _showSnackBar('没有当前厨房', isError: true);
      return;
    }

    final householdId = _currentHousehold!['id'] as int;
    final ownerId = _currentHousehold!['ownerId'] as int;
    final userId = await HouseholdService.getUserId();

    if (userId != ownerId) {
      _showSnackBar('只有厨房所有者可以重新生成邀请码', isError: true);
      return;
    }

    try {
      final result = await HouseholdService.regenerateInviteCode(householdId: householdId);
      if (result['success'] == true) {
        _showSnackBar('邀请码已重新生成');
        await _loadHouseholdData();
      } else {
        _showSnackBar(result['error'] ?? '重新生成失败', isError: true);
      }
    } catch (e) {
      _showSnackBar('网络错误: $e', isError: true);
    }
  }

  Future<void> _switchHousehold(int householdId) async {
    try {
      final result = await HouseholdService.switchCurrentHousehold(householdId: householdId);
      if (result['success'] == true) {
        _showSnackBar('已切换到该厨房');
        await _loadHouseholdData();
      } else {
        _showSnackBar(result['error'] ?? '切换失败', isError: true);
      }
    } catch (e) {
      _showSnackBar('网络错误: $e', isError: true);
    }
  }

  Future<void> _leaveHousehold(int householdId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出这个厨房吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final result = await HouseholdService.leaveHousehold(householdId: householdId);
      if (result['success'] == true) {
        _showSnackBar('已退出厨房');
        await _loadHouseholdData();
      } else {
        _showSnackBar(result['error'] ?? '退出失败', isError: true);
      }
    } catch (e) {
      _showSnackBar('网络错误: $e', isError: true);
    }
  }

  Future<void> _inviteUser() async {
    if (_currentHousehold == null) {
      _showSnackBar('没有当前厨房', isError: true);
      return;
    }

    final usernameOrEmail = _inviteUserController.text.trim();
    if (usernameOrEmail.isEmpty) {
      _showSnackBar('请输入用户名或邮箱', isError: true);
      return;
    }

    final householdId = _currentHousehold!['id'] as int;
    try {
      final result = await HouseholdService.inviteUser(
        householdId: householdId,
        usernameOrEmail: usernameOrEmail,
      );
      if (result['success'] == true) {
        _showSnackBar('邀请已发送');
        _inviteUserController.clear();
      } else {
        _showSnackBar(result['error'] ?? '邀请失败', isError: true);
      }
    } catch (e) {
      _showSnackBar('网络错误: $e', isError: true);
    }
  }

  Future<void> _copyInviteCode(String inviteCode) async {
    await Clipboard.setData(ClipboardData(text: inviteCode));
    _showSnackBar('邀请码已复制到剪贴板');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Kitchen Management',
            style: GoogleFonts.caveat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kitchen Management',
          style: GoogleFonts.caveat(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadHouseholdData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 当前厨房信息
              if (_currentHousehold != null) ...[
                _buildCurrentHouseholdCard(),
                const SizedBox(height: 24),
              ],

              // 加入厨房
              _buildJoinSection(),
              const SizedBox(height: 24),

              // 已加入的厨房列表
              _buildJoinedHouseholdsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentHouseholdCard() {
    final inviteCode = _currentHousehold!['inviteCode'] as String? ?? '';
    final householdName = _currentHousehold!['name'] as String? ?? 'Unknown';
    final ownerId = _currentHousehold!['ownerId'] as int? ?? 0;

    return SketchyCard(
      backgroundColor: Colors.orange.shade50,
      borderColor: Colors.orange.shade700,
      borderWidth: 2.0,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Kitchen',
            style: GoogleFonts.kalam(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            householdName,
            style: GoogleFonts.caveat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // 邀请码
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Invite Code: ',
                        style: GoogleFonts.kalam(fontSize: 14),
                      ),
                      Text(
                        inviteCode,
                        style: GoogleFonts.caveat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () => _copyInviteCode(inviteCode),
                tooltip: '复制邀请码',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 二维码
          Center(
            child: InviteQrCodeWidget(
              inviteCode: inviteCode,
              householdName: householdName,
              size: 200,
            ),
          ),
          const SizedBox(height: 16),
          // 重新生成邀请码按钮（仅 owner）
          FutureBuilder<int?>(
            future: HouseholdService.getUserId(),
            builder: (context, snapshot) {
              final userId = snapshot.data;
              if (userId == ownerId && inviteCode.isNotEmpty) {
                return SketchyButton(
                  text: 'Regenerate Invite Code',
                  backgroundColor: Colors.orange.shade100,
                  borderColor: Colors.orange.shade700,
                  onPressed: _regenerateInviteCode,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildJoinSection() {
    return SketchyCard(
      backgroundColor: Colors.white,
      borderColor: Colors.black87,
      borderWidth: 2.0,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Join Kitchen',
            style: GoogleFonts.kalam(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // 扫描二维码按钮
          SketchyButton(
            text: 'Scan QR Code',
            backgroundColor: Colors.blue.shade100,
            borderColor: Colors.blue.shade700,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScanJoinHouseholdPage(),
                ),
              );
              if (result == true) {
                await _loadHouseholdData();
              }
            },
          ),
          const SizedBox(height: 16),
          // 输入邀请码
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inviteCodeController,
                  decoration: InputDecoration(
                    labelText: 'Enter Invite Code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: GoogleFonts.kalam(),
                ),
              ),
              const SizedBox(width: 8),
              SketchyButton(
                text: 'Join',
                backgroundColor: Colors.green.shade100,
                borderColor: Colors.green.shade700,
                onPressed: _joinByInviteCode,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJoinedHouseholdsList() {
    if (_joinedHouseholds.isEmpty) {
      return SketchyCard(
        backgroundColor: Colors.grey.shade100,
        borderColor: Colors.grey.shade400,
        borderWidth: 2.0,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No kitchens joined yet',
            style: GoogleFonts.kalam(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Joined Kitchens',
          style: GoogleFonts.kalam(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._joinedHouseholds.map((household) => _buildHouseholdCard(household)),
      ],
    );
  }

  Widget _buildHouseholdCard(Map<String, dynamic> household) {
    final householdId = household['id'] as int? ?? 0;
    final householdName = household['name'] as String? ?? 'Unknown';
    final inviteCode = household['inviteCode'] as String? ?? '';
    final ownerId = household['ownerId'] as int? ?? 0;
    final isCurrent = _currentHousehold?['id'] == householdId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: SketchyCard(
        backgroundColor: isCurrent ? Colors.orange.shade50 : Colors.white,
        borderColor: isCurrent ? Colors.orange.shade700 : Colors.black87,
        borderWidth: 2.0,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            householdName,
                            style: GoogleFonts.caveat(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Current',
                                style: GoogleFonts.kalam(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Code: $inviteCode',
                        style: GoogleFonts.kalam(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (!isCurrent)
                  Expanded(
                    child: SketchyButton(
                      text: 'Switch',
                      backgroundColor: Colors.blue.shade100,
                      borderColor: Colors.blue.shade700,
                      onPressed: () => _switchHousehold(householdId),
                    ),
                  ),
                if (!isCurrent) const SizedBox(width: 8),
                Expanded(
                  child: FutureBuilder<int?>(
                    future: HouseholdService.getUserId(),
                    builder: (context, snapshot) {
                      final userId = snapshot.data;
                      // Owner 不能退出自己的厨房
                      if (userId == ownerId) {
                        return const SizedBox.shrink();
                      }
                      return SketchyButton(
                        text: 'Leave',
                        backgroundColor: Colors.red.shade100,
                        borderColor: Colors.red.shade700,
                        onPressed: () => _leaveHousehold(householdId),
                      );
                    },
                  ),
                ),
              ],
            ),
            // 邀请用户（仅 owner）
            FutureBuilder<int?>(
              future: HouseholdService.getUserId(),
              builder: (context, snapshot) {
                final userId = snapshot.data;
                if (userId == ownerId && isCurrent) {
                  return Column(
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _inviteUserController,
                              decoration: InputDecoration(
                                labelText: 'Username or Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                isDense: true,
                              ),
                              style: GoogleFonts.kalam(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SketchyButton(
                            text: 'Invite',
                            backgroundColor: Colors.green.shade100,
                            borderColor: Colors.green.shade700,
                            onPressed: _inviteUser,
                          ),
                        ],
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

