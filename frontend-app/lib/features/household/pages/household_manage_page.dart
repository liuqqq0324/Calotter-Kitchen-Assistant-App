// lib/pages/household/household_manage_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';
import 'package:personal_sous_chef/services/business/household_service.dart';
import 'package:personal_sous_chef/shared/widgets/buttons/invite_qr_code_widget.dart';
import 'package:personal_sous_chef/shared/widgets/common/section_title.dart';
import 'package:personal_sous_chef/shared/widgets/common/sketchy_button.dart';
import 'package:personal_sous_chef/shared/widgets/common/sketchy_card.dart';
import 'package:personal_sous_chef/shared/widgets/common/wood_background_scaffold.dart';
import 'package:personal_sous_chef/features/household/pages/scan_join_household_page.dart';

/// Profile 风格主色（与 profile_view_page 一致）
const Color _kPassportBrown = Color(0xFF6B4F4F);

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
        _joinedHouseholds = List<Map<String, dynamic>>.from(
          joinedResult['data'],
        );
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
      _showSnackBar('Please enter invite code', isError: true);
      return;
    }

    try {
      final result = await HouseholdService.joinHousehold(
        inviteCode: inviteCode,
      );
      if (result['success'] == true) {
        _showSnackBar('Successfully joined household!');
        _inviteCodeController.clear();
        await _loadHouseholdData();
      } else {
        _showSnackBar(result['error'] ?? 'Failed to join', isError: true);
      }
    } catch (e) {
      _showSnackBar('Network error: $e', isError: true);
    }
  }

  Future<void> _regenerateInviteCode() async {
    if (_currentHousehold == null) {
      _showSnackBar('No current household', isError: true);
      return;
    }

    final householdId = _currentHousehold!['id'] as int;
    final ownerId = _currentHousehold!['ownerId'] as int;
    final userId = await HouseholdService.getUserId();

    if (userId != ownerId) {
      _showSnackBar(
        'Only household owner can regenerate invite code',
        isError: true,
      );
      return;
    }

    try {
      final result = await HouseholdService.regenerateInviteCode(
        householdId: householdId,
      );
      if (result['success'] == true) {
        _showSnackBar('Invite code regenerated');
        await _loadHouseholdData();
      } else {
        _showSnackBar(result['error'] ?? 'Failed to regenerate', isError: true);
      }
    } catch (e) {
      _showSnackBar('Network error: $e', isError: true);
    }
  }

  Future<void> _switchHousehold(int householdId) async {
    try {
      final result = await HouseholdService.switchCurrentHousehold(
        householdId: householdId,
      );
      if (result['success'] == true) {
        _showSnackBar('Switched to household');
        await _loadHouseholdData();
      } else {
        _showSnackBar(result['error'] ?? 'Failed to switch', isError: true);
      }
    } catch (e) {
      _showSnackBar('Network error: $e', isError: true);
    }
  }

  Future<void> _leaveHousehold(int householdId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm Leave',
          style: GoogleFonts.kalam(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _kPassportBrown,
          ),
        ),
        content: Text(
          'Are you sure you want to leave this household?',
          style: GoogleFonts.kalam(fontSize: 16, color: _kPassportBrown),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.kalam(color: _kPassportBrown),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Confirm', style: GoogleFonts.kalam(color: _kPassportBrown)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final result = await HouseholdService.leaveHousehold(
        householdId: householdId,
      );
      if (result['success'] == true) {
        _showSnackBar('Left household');
        await _loadHouseholdData();
      } else {
        _showSnackBar(result['error'] ?? 'Failed to leave', isError: true);
      }
    } catch (e) {
      _showSnackBar('Network error: $e', isError: true);
    }
  }

  Future<void> _inviteUser() async {
    if (_currentHousehold == null) {
      _showSnackBar('No current household', isError: true);
      return;
    }

    final usernameOrEmail = _inviteUserController.text.trim();
    if (usernameOrEmail.isEmpty) {
      _showSnackBar('Please enter username or email', isError: true);
      return;
    }

    final householdId = _currentHousehold!['id'] as int;
    try {
      final result = await HouseholdService.inviteUser(
        householdId: householdId,
        usernameOrEmail: usernameOrEmail,
      );
      if (result['success'] == true) {
        _showSnackBar('Invitation sent');
        _inviteUserController.clear();
      } else {
        _showSnackBar(result['error'] ?? 'Failed to invite', isError: true);
      }
    } catch (e) {
      _showSnackBar('Network error: $e', isError: true);
    }
  }

  Future<void> _copyInviteCode(String inviteCode) async {
    await Clipboard.setData(ClipboardData(text: inviteCode));
    _showSnackBar('Invite code copied to clipboard');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.kalam()),
        backgroundColor: isError ? Colors.red.shade300 : Colors.green.shade300,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: _kPassportBrown),
      title: Text(
        'Kitchen Management',
        style: GoogleFonts.kalam(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: _kPassportBrown,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return WoodBackgroundScaffold(
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return WoodBackgroundScaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadHouseholdData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_currentHousehold != null) ...[
                _buildCurrentHouseholdCard(),
                const SizedBox(height: 24),
              ],
              _buildJoinSection(),
              const SizedBox(height: 24),
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
      backgroundColor: Colors.blue.shade50,
      borderColor: _kPassportBrown,
      borderWidth: 2.0,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle('Current Kitchen'),
          Text(
            householdName,
            style: GoogleFonts.caveat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _kPassportBrown,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _kPassportBrown.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Invite Code: ',
                        style: GoogleFonts.kalam(
                          fontSize: 14,
                          color: _kPassportBrown,
                        ),
                      ),
                      Text(
                        inviteCode,
                        style: GoogleFonts.caveat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: _kPassportBrown,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.copy),
                color: _kPassportBrown,
                onPressed: () => _copyInviteCode(inviteCode),
                tooltip: 'Copy invite code',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: InviteQrCodeWidget(
              inviteCode: inviteCode,
              householdName: householdName,
              size: 200,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<int?>(
            future: HouseholdService.getUserId(),
            builder: (context, snapshot) {
              final userId = snapshot.data;
              if (userId == ownerId && inviteCode.isNotEmpty) {
                return SketchyButton(
                  text: 'Regenerate Invite Code',
                  backgroundColor: Colors.green.shade100,
                  borderColor: Colors.green.shade700,
                  textColor: _kPassportBrown,
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
      backgroundColor: Colors.blue.shade50,
      borderColor: _kPassportBrown,
      borderWidth: 2.0,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle('Join Kitchen'),
          const SizedBox(height: 4),
          SketchyButton(
            text: 'Scan QR Code',
            backgroundColor: Colors.blue.shade100,
            borderColor: Colors.green.shade700,
            textColor: _kPassportBrown,
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
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inviteCodeController,
                  decoration: InputDecoration(
                    labelText: 'Enter Invite Code',
                    labelStyle: GoogleFonts.kalam(color: _kPassportBrown),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: _kPassportBrown),
                    ),
                  ),
                  style: GoogleFonts.kalam(color: _kPassportBrown),
                ),
              ),
              const SizedBox(width: 8),
              SketchyButton(
                text: 'Join',
                backgroundColor: Colors.green.shade100,
                borderColor: Colors.green.shade700,
                textColor: _kPassportBrown,
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
        backgroundColor: Colors.blue.shade50,
        borderColor: _kPassportBrown,
        borderWidth: 2.0,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No kitchens joined yet',
            style: GoogleFonts.kalam(
              fontSize: 16,
              color: _kPassportBrown.withOpacity(0.8),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Joined Kitchens'),
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
        backgroundColor: isCurrent ? Colors.blue.shade50 : Colors.white,
        borderColor: _kPassportBrown,
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
                              color: _kPassportBrown,
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
                                color: Colors.green.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Current',
                                style: GoogleFonts.kalam(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _kPassportBrown,
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
                          color: _kPassportBrown.withOpacity(0.8),
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
                      borderColor: Colors.green.shade700,
                      textColor: _kPassportBrown,
                      onPressed: () => _switchHousehold(householdId),
                    ),
                  ),
                if (!isCurrent) const SizedBox(width: 8),
                Expanded(
                  child: FutureBuilder<int?>(
                    future: HouseholdService.getUserId(),
                    builder: (context, snapshot) {
                      final userId = snapshot.data;
                      if (userId == ownerId) {
                        return const SizedBox.shrink();
                      }
                      return SketchyButton(
                        text: 'Leave',
                        backgroundColor: Colors.red.shade100,
                        borderColor: Colors.red.shade700,
                        textColor: _kPassportBrown,
                        onPressed: () => _leaveHousehold(householdId),
                      );
                    },
                  ),
                ),
              ],
            ),
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
                                labelStyle: GoogleFonts.kalam(color: _kPassportBrown),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: _kPassportBrown),
                                ),
                                isDense: true,
                              ),
                              style: GoogleFonts.kalam(color: _kPassportBrown),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SketchyButton(
                            text: 'Invite',
                            backgroundColor: Colors.green.shade100,
                            borderColor: Colors.green.shade700,
                            textColor: _kPassportBrown,
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
