import 'package:badges/badges.dart' as badges;
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ratchasima/apptheme.dart';
import 'package:ratchasima/pages/notification/notification_list.dart';

import '../../shared/api_provider.dart';
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
  _UserInformationPageState createState() => _UserInformationPageState();
}

class _UserInformationPageState extends State<UserInformationPage> {
  final storage = new FlutterSecureStorage();
  Future<dynamic>? _futureProfile;
  // Future<dynamic>? _futureAboutUs;
  dynamic _tempData = {'imageUrl': '', 'firstName': '', 'lastName': ''};

  @override
  void initState() {
    _read();
    // _futureAboutUs = postDio('${aboutUsApi}read', {});

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<dynamic>(
        future: _futureProfile,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return card(snapshot.data);
          } else if (snapshot.hasError) {
            return card(_tempData);
          } else {
            return card(_tempData);
          }
        },
      ),
    );
  }

  // _read() async {
  //   print('--------read profile---------');
  //   var profileCode = await storage.read(key: 'profileCode2');

  //   if (profileCode != '' && profileCode != null) {
  //     var response = await postDio(profileReadApi, {"code": profileCode});

  //     setState(() {
  //       _futureProfile = Future.value(response[0]);
  //     });

  //   }
  // }
  int notiCount = 0;
  _read() async {
    print('--------read profile---------');
    final localProfile = await storage.read(key: 'localProfile');
    if (localProfile != null && localProfile.isNotEmpty) {
      final data = jsonDecode(localProfile) as Map<String, dynamic>;
      setState(() {
        _futureProfile = Future.value(data);
        notiCount = 2;
      });
      return;
    }

    final firstName = await storage.read(key: 'profileFirstName') ?? '';
    final lastName = await storage.read(key: 'profileLastName') ?? '';
    final username = await storage.read(key: 'username') ?? '';
    final imageUrl = await storage.read(key: 'profileImageUrl') ?? '';
    final idcard = await storage.read(key: 'idcard') ?? '';
    final category = await storage.read(key: 'profileCategory') ?? 'guest';
    setState(() {
      _futureProfile = Future.value({
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'imageUrl': imageUrl,
        'idcard': idcard,
        'category': category,
        'province': 'นครราชสีมา',
      });
      notiCount = 2;
    });
  }

  card(dynamic model) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    final firstName = (model['firstName'] ?? '').toString().trim();
    final lastName = (model['lastName'] ?? '').toString().trim();
    final fullName = '$firstName $lastName'.trim();
    final hasName = fullName.isNotEmpty;
    final badgeTop = statusBarHeight + (hasName ? 138 : 108);
    final actionsTop = statusBarHeight + (hasName ? 176 : 146);
    final heroHeight = (statusBarHeight + (hasName ? 242 : 212))
        .clamp(270.0, 310.0)
        .toDouble();

    Future<void> open(Widget page, {bool refreshProfile = false}) async {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page),
      );
      if (refreshProfile && mounted) {
        await _read();
      }
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topCenter,
            children: [
              SizedBox(
                child: Stack(
                  children: [
                    SizedBox(
                      height: heroHeight,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        child: Opacity(
                          opacity: 0.28,
                          child: Image.asset(
                            'assets/images/2023092591204e43fd5532c7506d03b582dc08c7152255.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: statusBarHeight + 8,
                left: 16,
                child: InkWell(
                  onTap: () {
                    if (widget.changePage != null) {
                      widget.changePage!(0);
                    } else {
                      Navigator.maybePop(context);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: statusBarHeight + 8,
                right: 16,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationList(
                            title: 'แจ้งเตือน',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: badges.Badge(
                        showBadge: notiCount > 0,
                        position: badges.BadgePosition.topEnd(top: -8, end: -8),
                        badgeStyle: badges.BadgeStyle(
                          badgeColor: Colors.red.shade600,
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          borderRadius: BorderRadius.circular(12),
                          elevation: 2,
                        ),
                        badgeContent: Text(
                          notiCount > 99 ? '99+' : notiCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: AppColors.primary,
                          size: 23,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 80,
                width: 80,
                margin: EdgeInsets.only(top: statusBarHeight + 24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x24282429),
                      blurRadius: 14,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: model['imageUrl'] != ''
                      ? CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: model['imageUrl'] != null
                              ? NetworkImage(model['imageUrl'])
                              : null,
                        )
                      : Container(
                          padding: const EdgeInsets.all(14),
                          color: AppColors.primarySoft,
                          child: Image.asset(
                            'assets/icons/profile_icon.png',
                            fit: BoxFit.contain,
                            color: AppColors.primary,
                          ),
                        ),
                ),
              ),
              if (hasName)
                Container(
                  height: 30,
                  margin: EdgeInsets.only(
                    top: statusBarHeight + 108,
                    left: 20.0,
                    right: 20.0,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Sarabun',
                      fontSize: 18.0,
                      color: AppColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
              Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 11),
                margin: EdgeInsets.only(
                  top: badgeTop,
                  left: 20.0,
                  right: 20.0,
                  bottom: 30.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 17,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'ชาวโคราช',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                margin: EdgeInsets.only(
                  top: actionsTop,
                  left: 20.0,
                  right: 20.0,
                  bottom: 30.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _profileActionButton(
                      icon: Icons.qr_code_scanner_rounded,
                      label: 'สแกน QR',
                      onTap: () => open(const QrScannerPage()),
                    ),
                    const SizedBox(width: 18),
                    _profileActionButton(
                      icon: Icons.edit_square,
                      label: 'แก้ไขข้อมูล',
                      onTap: () => open(
                        EditUserInformationPage(),
                        refreshProfile: true,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                margin: EdgeInsets.only(top: heroHeight),
                constraints: const BoxConstraints(
                  minHeight: 200,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 4, 2, 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'ตั้งค่าผู้ใช้',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IdentityVerificationPage(),
                          ),
                        ),
                        child: buttonMenuUser(
                          Icons.badge_outlined,
                          'ข้อมูลสมาชิก',
                          'ดูรายละเอียดข้อมูลของสมาชิก เช่น ชื่อ ที่อยู่ และเบอร์โทรศัพท์',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 12, 2, 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'ตั้งค่าอื่นๆ',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingNotificationPage(),
                          ),
                        ),
                        child: buttonMenuUser(
                          Icons.notifications_none_rounded,
                          'ตั้งค่าการแจ้งเตือน',
                          'ตั้งเวลาและรูปแบบการแจ้งเตือนสำหรับกิจกรรมต่าง ๆ',
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangePasswordPage(),
                          ),
                        ),
                        child: buttonMenuUser(
                          Icons.lock_outline_rounded,
                          'เปลี่ยนรหัสผ่าน',
                          'เปลี่ยนรหัสผ่านบัญชีของคุณได้ที่นี่',
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 4),
                        alignment: Alignment.centerRight,
                        child: Text(
                          versionName,
                          style: TextStyle(
                            fontSize: 9,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 14),
                        child: TextButton.icon(
                          onPressed: () => logout(context),
                          icon: const Icon(Icons.power_settings_new, size: 20),
                          label: const Text('ออกจากระบบ'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                            textStyle: const TextStyle(
                              fontFamily: 'Sarabun',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 80,
          )
        ],
      ),
    );
  }

  Widget _profileActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primarySoft),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14282429),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Sarabun',
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buttonMenuUser(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
          color: AppColors.surface,
        ),
        margin: const EdgeInsets.only(bottom: 6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Sarabun',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Sarabun',
                        fontSize: 12,
                        height: 1.3,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  color: AppColors.primarySoft,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
