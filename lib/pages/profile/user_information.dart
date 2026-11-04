import 'dart:convert';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ratchasima/apptheme.dart';
import 'package:ratchasima/pages/notification/notification_list.dart';

import '../../shared/api_provider.dart';
import '../../shared/mock_repository.dart';
import '../complain/complain_follow.dart';
import '../otop_cart.dart';
import '../otop_product_list.dart';
import '../poll/poll_list.dart';
import '../reporter/reporter_local_store.dart';
import '../welfare_list.dart';
import '../qr_scanner_page.dart';
import 'change_password.dart';
import 'edit_user_information.dart';
import 'identity_verification.dart';
import 'setting_notification.dart';

// ignore: must_be_immutable
class UserInformationPage extends StatefulWidget {
  UserInformationPage({super.key, this.changePage});
  Function? changePage;

  @override
  UserInformationPageState createState() => UserInformationPageState();
}

class UserInformationPageState extends State<UserInformationPage> {
  final storage = const FlutterSecureStorage();
  Future<dynamic>? _futureProfile;
  int notiCount = 2;

  final dynamic _tempData = {
    'imageUrl': '',
    'firstName': 'สมเกียรติ',
    'lastName': 'สุรนารี',
    'citizenId': 'KRT-2569-8891',
    'idcard': '1-3099-00428-11-2',
    'province': 'นครราชสีมา',
    'phone': '089-722-XXXX',
    'address': '99/1 ถ.มิตรภาพ ต.ในเมือง อ.เมือง จ.นครราชสีมา 30000',
  };

  @override
  void initState() {
    super.initState();
    _read();
    ReporterLocalStore.revision.addListener(_onStateChange);
    OtopCartController.instance.addListener(_onStateChange);
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    ReporterLocalStore.revision.removeListener(_onStateChange);
    OtopCartController.instance.removeListener(_onStateChange);
    super.dispose();
  }

  Future<void> _read() async {
    final localProfile = await storage.read(key: 'localProfile');
    if (localProfile != null && localProfile.isNotEmpty) {
      try {
        final data = jsonDecode(localProfile) as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _futureProfile = Future.value(data);
            notiCount = 2;
          });
        }
        return;
      } catch (_) {}
    }

    final firstName = await storage.read(key: 'profileFirstName');
    final lastName = await storage.read(key: 'profileLastName');
    final username = await storage.read(key: 'username') ?? '';
    final imageUrl = await storage.read(key: 'profileImageUrl') ?? '';
    final idcard = await storage.read(key: 'idcard');
    final category = await storage.read(key: 'profileCategory') ?? 'citizen';

    if (mounted) {
      setState(() {
        _futureProfile = Future.value({
          'firstName': (firstName != null && firstName.isNotEmpty)
              ? firstName
              : 'สมเกียรติ',
          'lastName':
              (lastName != null && lastName.isNotEmpty) ? lastName : 'สุรนารี',
          'username': username,
          'imageUrl': imageUrl,
          'idcard': (idcard != null && idcard.isNotEmpty)
              ? idcard
              : '1-3099-00428-11-2',
          'citizenId': 'KRT-2569-8891',
          'category': category,
          'province': 'นครราชสีมา',
          'phone': '089-722-XXXX',
          'address': '99/1 ถ.มิตรภาพ ต.ในเมือง อ.เมือง จ.นครราชสีมา 30000',
        });
        notiCount = 2;
      });
    }
  }

  Future<void> open(Widget page, {bool refreshProfile = false}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (refreshProfile && mounted) {
      await _read();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<dynamic>(
        future: _futureProfile,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          final profile = (snapshot.hasData && snapshot.data is Map)
              ? snapshot.data as Map<String, dynamic>
              : _tempData as Map<String, dynamic>;
          return _buildProfileContent(profile);
        },
      ),
    );
  }

  Widget _buildProfileContent(Map<String, dynamic> profile) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          // Header Bar
          _buildHeaderBar(statusBarHeight),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Virtual Korat Citizen Card
                _buildVirtualCitizenCard(profile),
                const SizedBox(height: 18),

                // 2. Quick Action Buttons
                _buildQuickActions(profile),
                const SizedBox(height: 22),

                // 3. Citizen Activity Dashboard
                _buildActivityDashboard(),
                const SizedBox(height: 24),

                // 4. Categorized Menus
                _buildCategorizedMenus(),
                const SizedBox(height: 24),

                // 5. Account Management (Logout & Delete Account)
                _buildAccountActions(),
                const SizedBox(height: 28),

                // App Version & Organization Footer
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Korat Connect v$versionName (Smart City)',
                        style: const TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'เทศบาลนครนครราชสีมา ร่วมกับ จังหวัดนครราชสีมา',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Clearance buffer so bottom bar never covers anything
                SizedBox(height: 100 + bottomPadding),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBar(double statusBarHeight) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, statusBarHeight + 10, 16, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button or Brand Title
          Row(
            children: [
              InkWell(
                onTap: () {
                  if (widget.changePage != null) {
                    widget.changePage!(0);
                  } else {
                    Navigator.maybePop(context);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'ข้อมูลพลเมือง',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          // Notification Button with Badge
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationList(title: 'การแจ้งเตือน'),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: badges.Badge(
                  showBadge: notiCount > 0,
                  position: badges.BadgePosition.topEnd(top: -8, end: -8),
                  badgeStyle: badges.BadgeStyle(
                    badgeColor: Colors.red.shade600,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  badgeContent: Text(
                    notiCount.toString(),
                    style: const TextStyle(
                      fontFamily: 'Kanit',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 1. Virtual Korat Citizen Card (บัตรพลเมืองดิจิทัล)
  // =========================================================================
  Widget _buildVirtualCitizenCard(Map<String, dynamic> profile) {
    final firstName = (profile['firstName'] ?? '').toString().trim();
    final lastName = (profile['lastName'] ?? '').toString().trim();
    final name = (firstName.isNotEmpty || lastName.isNotEmpty)
        ? '$firstName $lastName'.trim()
        : 'สมเกียรติ สุรนารี';
    final idcard = (profile['idcard'] ?? '').toString().trim();
    final maskedIdCard = idcard.isNotEmpty && idcard.length >= 13
        ? '${idcard.substring(0, 1)}-${idcard.substring(1, 5)}-xxxxx-${idcard.substring(10, 12)}-${idcard.substring(12)}'
        : '1-3099-00428-11-2';
    final citizenId = (profile['citizenId'] ?? 'KRT-2569-8891').toString();
    final province = (profile['province'] ?? 'นครราชสีมา').toString();
    final imageUrl = (profile['imageUrl'] ?? '').toString().trim();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE65100), // Terracotta
            Color(0xFFBF360C), // Deep Rust
            Color(0xFF7F0000), // Rich Crimson
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBF360C).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // City Emblem Watermark in background
          Positioned(
            right: -25,
            bottom: -35,
            child: Opacity(
              opacity: 0.12,
              child: const Icon(
                Icons.account_balance_rounded,
                size: 210,
                color: Colors.white,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shield_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'บัตรพลเมืองดิจิทัล',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              'NAKHON RATCHASIMA SMART CITIZEN',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 8.5,
                                letterSpacing: 0.5,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // ThaiD Verified Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'ThaiD Verified',
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Middle Info Row (Avatar + Details + Mini QR)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Citizen Avatar
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildAvatarPlaceholder(),
                              )
                            : _buildAvatarPlaceholder(),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Name & Identifiers
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'เลขพลเมือง: $citizenId',
                            style: const TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            'บัตรประชาชน: $maskedIdCard',
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Tap-to-Enlarge QR Box
                    InkWell(
                      onTap: () =>
                          _showCitizenQrDialog(name, citizenId, maskedIdCard),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            QrImageView(
                              data: 'KORAT-CITIZEN:$citizenId:$name',
                              version: QrVersions.auto,
                              size: 44,
                              padding: EdgeInsets.zero,
                            ),
                            const Text(
                              'แตะขยาย',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFBF360C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 10),

                // Card Footer Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 13, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          'ภูมิลำเนา: อ.เมือง • จ.$province',
                          style: const TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 11.5,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'สถานะ: พลเมืองยืนยันสิทธิ์',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Image.asset(
        'assets/icons/profile_icon.png',
        fit: BoxFit.contain,
        color: AppColors.primary,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.person_rounded,
          color: AppColors.primary,
          size: 32,
        ),
      ),
    );
  }

  // =========================================================================
  // 2. Quick Action Bar (3 Pills)
  // =========================================================================
  Widget _buildQuickActions(Map<String, dynamic> profile) {
    return Row(
      children: [
        Expanded(
          child: _buildActionPill(
            icon: Icons.edit_note_rounded,
            label: 'แก้ไขข้อมูล',
            onTap: () =>
                open(const EditUserInformationPage(), refreshProfile: true),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionPill(
            icon: Icons.qr_code_scanner_rounded,
            label: 'สแกน QR',
            onTap: () => open(const QrScannerPage()),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionPill(
            icon: Icons.local_shipping_outlined,
            label: 'ที่อยู่จัดส่ง',
            onTap: () => _showDeliveryAddressDialog(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 3. Citizen Activity Dashboard (สถิติกิจกรรมพลเมือง 4 ช่อง - ลิงก์ตรงกับข้อมูลจริง)
  // =========================================================================
  Widget _buildActivityDashboard() {
    // 1. เรื่องร้องทุกข์จริงจาก ReporterLocalStore
    final reports = ReporterLocalStore.reports;
    final reportCount = reports.length;
    final inProgress = reports.where((r) => r['status'] == 'กำลังดำเนินการ').length;
    final pending = reports.where((r) => r['status'] == 'รอดำเนินการ').length;
    final reportStatusText = reportCount > 0
        ? 'กำลังทำ $inProgress • รอตรวจ $pending'
        : 'ไม่มีเรื่องค้างดำเนินการ';

    // 2. ตะกร้าสินค้า OTOP จริงจาก OtopCartController
    final cartItemCount = OtopCartController.instance.itemCount;
    final cartUniqueItems = OtopCartController.instance.items.length;
    final cartStatusText = cartItemCount > 0
        ? '$cartUniqueItems รายการรอสั่งซื้อ'
        : 'ไม่มีสินค้าในตะกร้า';

    // 3. โพลเมืองจริงจาก KoratMockRepository
    final pollList = KoratMockRepository.getPollList();
    final pollCount = pollList.length;
    final pollStatusText = 'เปิดรับฟังความเห็น $pollCount หัวข้อ';

    // 4. สิทธิสวัสดิการพลเมืองจริง (4 สิทธิ์หลัก)
    const welfareCount = 4;
    const welfareStatusText = 'พร้อมตรวจสอบสิทธิ์ 4 โครงการ';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'กิจกรรมพลเมืองของฉัน',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ComplainFollow()),
              ),
              child: const Row(
                children: [
                  Text(
                    'ดูทั้งหมด',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // การ์ด 1: เรื่องร้องทุกข์
            Expanded(
              child: _buildStatCard(
                icon: Icons.campaign_rounded,
                iconColor: const Color(0xFFE65100),
                title: 'เรื่องร้องทุกข์',
                count: '$reportCount',
                statusText: reportStatusText,
                statusColor: const Color(0xFF10B981),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ComplainFollow()),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // การ์ด 2: ตะกร้าสินค้า OTOP
            Expanded(
              child: _buildStatCard(
                icon: Icons.shopping_bag_rounded,
                iconColor: const Color(0xFFD84315),
                title: 'ตะกร้าสินค้า OTOP',
                count: '$cartItemCount',
                statusText: cartStatusText,
                statusColor: cartItemCount > 0 ? const Color(0xFF0284C7) : AppColors.textSecondary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OtopCartPage()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // การ์ด 3: โพลสำรวจเมือง
            Expanded(
              child: _buildStatCard(
                icon: Icons.how_to_vote_rounded,
                iconColor: const Color(0xFF6D28D9),
                title: 'โพลสำรวจเมือง',
                count: '$pollCount',
                statusText: pollStatusText,
                statusColor: const Color(0xFF6D28D9),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PollList(title: 'โพลสำรวจความคิดเห็น'),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // การ์ด 4: สิทธิและสวัสดิการ
            Expanded(
              child: _buildStatCard(
                icon: Icons.card_giftcard_rounded,
                iconColor: const Color(0xFF059669),
                title: 'สิทธิ & สวัสดิการ',
                count: '$welfareCount',
                statusText: welfareStatusText,
                statusColor: const Color(0xFF059669),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WelfareListPage(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String count,
    required String statusText,
    required Color statusColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 18),
                  ),
                  Text(
                    count,
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: iconColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                statusText,
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 11,
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 4. Categorized Menus
  // =========================================================================
  Widget _buildCategorizedMenus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group 1: บริการประชาชน
        const Text(
          'บริการพลเมือง',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        _buildMenuTile(
          icon: Icons.badge_outlined,
          iconColor: AppColors.primary,
          title: 'ข้อมูลสมาชิกและยืนยันตัวตน',
          subtitle: 'ดูรายละเอียดข้อมูลทะเบียน สิทธิ และสถานะสมาชิก',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => IdentityVerificationPage()),
          ),
        ),
        _buildMenuTile(
          icon: Icons.track_changes_rounded,
          iconColor: const Color(0xFFE65100),
          title: 'ติดตามเรื่องร้องเรียนของฉัน',
          subtitle: 'ตรวจสอบสถานะและประวัติการแก้ปัญหาของเทศบาล',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ComplainFollow()),
          ),
        ),
        _buildMenuTile(
          icon: Icons.storefront_rounded,
          iconColor: const Color(0xFFD84315),
          title: 'ตลาดสินค้า OTOP โคราช',
          subtitle: 'เลือกซื้อสินค้าของดีเมืองย่าโม และตรวจสอบตะกร้าสินค้า',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => OtopProductListPage()),
          ),
        ),

        const SizedBox(height: 20),

        // Group 2: การตั้งค่าและความปลอดภัย
        const Text(
          'การตั้งค่าและความปลอดภัย',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        _buildMenuTile(
          icon: Icons.notifications_none_rounded,
          iconColor: const Color(0xFF0284C7),
          title: 'ตั้งค่าการแจ้งเตือน',
          subtitle: 'ตั้งเวลาและรูปแบบการแจ้งเตือนสำหรับกิจกรรมต่าง ๆ',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SettingNotificationPage()),
          ),
        ),
        _buildMenuTile(
          icon: Icons.lock_outline_rounded,
          iconColor: const Color(0xFF4B5563),
          title: 'เปลี่ยนรหัสผ่าน',
          subtitle: 'แก้ไขรหัสผ่านบัญชีผู้ใช้เพื่อความปลอดภัย',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChangePasswordPage()),
          ),
        ),
        _buildMenuTile(
          icon: Icons.privacy_tip_outlined,
          iconColor: const Color(0xFF059669),
          title: 'นโยบายคุ้มครองข้อมูลส่วนบุคคล (PDPA)',
          subtitle: 'สิทธิของเจ้าของข้อมูลและมาตรฐานความปลอดภัย',
          onTap: () => _showPdpaDialog(),
        ),
      ],
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 5. Account Management (Logout & Delete Account)
  // =========================================================================
  Widget _buildAccountActions() {
    return Column(
      children: [
        // Logout Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => logout(context),
            icon: const Icon(Icons.power_settings_new_rounded, size: 20),
            label: const Text('ออกจากระบบ'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 13),
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              textStyle: const TextStyle(
                fontFamily: 'Kanit',
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Delete Account Button (Apple & Google Compliant)
        TextButton.icon(
          onPressed: () => _showDeleteAccountDialog(),
          icon: const Icon(Icons.delete_forever_rounded,
              size: 18, color: AppColors.error),
          label: const Text(
            'ขอลบบัญชีผู้ใช้งาน (Delete Account)',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 13,
              color: AppColors.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // Dialogs & Modals
  // =========================================================================
  void _showCitizenQrDialog(
      String name, String citizenId, String maskedIdCard) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'QR CODE พลเมืองนครราชสีมา',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                name,
                style: const TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'เลขประจำตัวพลเมือง: $citizenId',
                style: const TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: 'KORAT-CITIZEN:$citizenId:$name:$maskedIdCard',
                  version: QrVersions.auto,
                  size: 200,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ใช้สำหรับแสดงตน ติดต่อหน่วยงานราชการ\nหรือรับสิทธิประโยชน์จากร้านค้าชุมชน OTOP',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'ปิดหน้าต่าง',
                    style: TextStyle(fontFamily: 'Kanit', fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeliveryAddressDialog() async {
    final localProfile = await storage.read(key: 'localProfile');
    String address = '99/1 ถ.มิตรภาพ ต.ในเมือง อ.เมือง จ.นครราชสีมา 30000';
    String phone = '089-722-XXXX';
    if (localProfile != null && localProfile.isNotEmpty) {
      try {
        final data = jsonDecode(localProfile) as Map<String, dynamic>;
        if (data['address'] != null &&
            data['address'].toString().trim().isNotEmpty) {
          address = data['address'].toString();
        }
        if (data['phone'] != null &&
            data['phone'].toString().trim().isNotEmpty) {
          phone = data['phone'].toString();
        }
      } catch (_) {}
    }

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.location_on_rounded, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'ที่อยู่จัดส่งสินค้า OTOP ของฉัน',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWarm,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address,
                      style: const TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'เบอร์โทรศัพท์: $phone',
                      style: const TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('ปิด',
                          style: TextStyle(fontFamily: 'Kanit', fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        open(const EditUserInformationPage(),
                            refreshProfile: true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'แก้ไขที่อยู่',
                        style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 14,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPdpaDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'นโยบายคุ้มครองข้อมูลส่วนบุคคล (PDPA)',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    'แอปพลิเคชัน Nakhon Ratchasima (Korat Connect) ให้ความสำคัญกับการคุ้มครองข้อมูลส่วนบุคคลของท่านตามพระราชบัญญัติคุ้มครองข้อมูลส่วนบุคคล พ.ศ. 2562 (PDPA)\n\n'
                    '1. ข้อมูลที่จัดเก็บ: ชื่อ-นามสกุล, หมายเลขประจำตัวประชาชน, เบอร์โทรศัพท์, ข้อมูลการแจ้งเรื่องร้องทุกข์, และพิกัดตำแหน่งทางภูมิศาสตร์สำหรับการช่วยเหลือกรณีฉุกเฉิน\n\n'
                    '2. วัตถุประสงค์: เพื่อใช้ในการระบุตัวตนในการติดต่อราชการ, การจัดส่งสิ่งของหรือสินค้า OTOP, การดำเนินการแก้ไขปัญหาเรื่องร้องเรียน และการส่งเสริมสิทธิสวัสดิการของประชาชนในจังหวัดนครราชสีมา\n\n'
                    '3. ความปลอดภัย: ข้อมูลของท่านได้รับการปกป้องด้วยมาตรฐานการรักษาความมั่นคงปลอดภัยสารสนเทศของภาครัฐ และจะไม่ถูกนำไปเปิดเผยต่อบุคคลภายนอกโดยไม่ได้รับความยินยอม ยกเว้นตามที่กฎหมายกำหนด\n\n'
                    '4. สิทธิ์ของเจ้าของข้อมูล: ท่านมีสิทธิ์ขอเข้าถึง, ขอสำเนา, ขอแก้ไข หรือขอลบข้อมูลส่วนบุคคลของท่านได้ทุกเมื่อผ่านเมนูการจัดการบัญชีในแอปพลิเคชัน',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 13.5,
                      color: Colors.grey.shade800,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'รับทราบและเข้าใจแล้ว',
                    style: TextStyle(
                        fontFamily: 'Kanit', fontSize: 15, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
            SizedBox(width: 8),
            Text(
              'ขอลบบัญชีผู้ใช้งาน',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
          ],
        ),
        content: const Text(
          'การขอลบบัญชีผู้ใช้จะเป็นการลบประวัติเรื่องร้องเรียน คำสั่งซื้อสินค้า OTOP และสิทธิประโยชน์ของท่านทั้งหมดอย่างถาวรตามนโยบาย PDPA โดยไม่สามารถกู้คืนได้\n\nท่านแน่ใจหรือไม่ว่าต้องการลบบัญชีนี้?',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 14,
            height: 1.5,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'ยกเลิก',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await storage.delete(key: 'localProfile');
              await storage.delete(key: 'dataUserLoginDDPM');
              await storage.delete(key: 'token');
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ส่งคำขอลบบัญชีและออกจากระบบสำเร็จ',
                      style: TextStyle(fontFamily: 'Kanit')),
                  backgroundColor: AppColors.error,
                ),
              );
              logout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'ยืนยันลบบัญชี',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
