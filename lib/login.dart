import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ratchasima/apptheme.dart';
import 'package:ratchasima/menu.dart';
import 'package:ratchasima/pages/auth/forgot_password.dart';
import 'package:ratchasima/pages/auth/register.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.title});

  final String? title;

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _storage = const FlutterSecureStorage();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _acceptedPolicy = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> loginWithGuest() async => _loginLocal(category: 'guest');

  Future<void> _loginWithThaiD() async {
    if (!_acceptedPolicy) {
      _showMessage('กรุณายอมรับนโยบายความเป็นส่วนตัวก่อนเข้าสู่ระบบ');
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    await _saveLocalProfile(
      category: 'thaid',
      username: 'thaid-user',
      firstName: 'สมชาย',
      lastName: 'โคราช',
      idcard: '1300000000000',
      email: 'thaid.user@example.com',
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    _goToMenu();
  }

  Future<void> _loginLocal({required String category}) async {
    if (!_acceptedPolicy) {
      _showMessage('กรุณายอมรับนโยบายความเป็นส่วนตัวก่อนเข้าสู่ระบบ');
      return;
    }
    if (_usernameController.text.trim().isEmpty) {
      _showMessage('กรุณากรอกชื่อผู้ใช้งาน');
      return;
    }
    if (_passwordController.text.trim().isEmpty) {
      _showMessage('กรุณากรอกรหัสผ่าน');
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    await _saveLocalProfile(
      category: category,
      username: _usernameController.text.trim(),
      firstName: 'ผู้ใช้งาน',
      lastName: 'Korat Connect',
      idcard: '',
      email: '${_usernameController.text.trim()}@local.app',
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    _goToMenu();
  }

  Future<void> _saveLocalProfile({
    required String category,
    required String username,
    required String firstName,
    required String lastName,
    required String idcard,
    required String email,
  }) async {
    final profile = {
      'code': 'LOCAL-${DateTime.now().millisecondsSinceEpoch}',
      'username': username,
      'category': category,
      'prefixName': category == 'thaid' ? 'นาย' : '',
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': '044000000',
      'idcard': idcard,
      'imageUrl': '',
      'isActive': true,
      'status': 'A',
      'province': 'นครราชสีมา',
    };

    await _storage.write(key: 'dataUserLoginDDPM', value: jsonEncode(profile));
    await _storage.write(key: 'localProfile', value: jsonEncode(profile));
    await _storage.write(
        key: 'profileCode2', value: profile['code'].toString());
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'profileCategory', value: category);
    await _storage.write(key: 'profileFirstName', value: firstName);
    await _storage.write(key: 'profileLastName', value: lastName);
    await _storage.write(key: 'profileImageUrl', value: '');
    await _storage.write(key: 'idcard', value: idcard);
  }

  void _goToMenu() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Menu()),
      (route) => false,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Sarabun'),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openPolicy() async {
    final uri = Uri.parse('https://policy.we-builds.com/khubdee');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/105050040_2965853846974764_5395773976979469213_n.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.16),
                      AppColors.background.withValues(alpha: 0.96),
                      AppColors.background,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
                children: [
                  const Text(
                    'Korat Connect',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'เข้าสู่บริการเมืองโคราชในที่เดียว',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Sarabun',
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 42),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A282429),
                          blurRadius: 22,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'เข้าสู่ระบบ',
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _LoginField(
                          controller: _usernameController,
                          label: 'ชื่อผู้ใช้งาน',
                          icon: Icons.person_rounded,
                        ),
                        const SizedBox(height: 12),
                        _LoginField(
                          controller: _passwordController,
                          label: 'รหัสผ่าน',
                          icon: Icons.lock_rounded,
                          obscureText: true,
                        ),
                        const SizedBox(height: 12),
                        _PolicyCheckbox(
                          value: _acceptedPolicy,
                          onChanged: (value) =>
                              setState(() => _acceptedPolicy = value),
                          onPolicyTap: _openPolicy,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : loginWithGuest,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('เข้าสู่ระบบ'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _loginWithThaiD,
                            icon: Image.asset(
                              'assets/icons/icon_ThaiD.png',
                              width: 56,
                              height: 30,
                              fit: BoxFit.contain,
                            ),
                            label: const Text('เข้าสู่ระบบด้วย ThaiD'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordPage(),
                                ),
                              ),
                              child: const Text('ลืมรหัสผ่าน'),
                            ),
                            const Text('|',
                                style: TextStyle(color: AppColors.border)),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterPage(
                                    username: '',
                                    password: '',
                                    facebookID: '',
                                    appleID: '',
                                    googleID: '',
                                    lineID: '',
                                    email: '',
                                    imageUrl: '',
                                    category: 'guest',
                                    prefixName: '',
                                    firstName: '',
                                    lastName: '',
                                  ),
                                ),
                              ),
                              child: const Text('สมัครสมาชิก'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
      ),
    );
  }
}

class _PolicyCheckbox extends StatelessWidget {
  const _PolicyCheckbox({
    required this.value,
    required this.onChanged,
    required this.onPolicyTap,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onPolicyTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          activeColor: AppColors.primary,
          onChanged: (checked) => onChanged(checked ?? false),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Wrap(
              children: [
                const Text(
                  'ฉันยอมรับ ',
                  style: TextStyle(
                    fontFamily: 'Sarabun',
                    color: AppColors.textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: onPolicyTap,
                  child: const Text(
                    'นโยบายความเป็นส่วนตัว',
                    style: TextStyle(
                      fontFamily: 'Sarabun',
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const Text(
                  ' ก่อนเข้าสู่ระบบ',
                  style: TextStyle(
                    fontFamily: 'Sarabun',
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
