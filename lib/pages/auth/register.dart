import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ratchasima/apptheme.dart';
import 'package:ratchasima/component/korat_ui.dart';
import 'package:ratchasima/menu.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
    required this.username,
    required this.password,
    required this.facebookID,
    required this.appleID,
    required this.googleID,
    required this.lineID,
    required this.email,
    required this.imageUrl,
    required this.category,
    required this.prefixName,
    required this.firstName,
    required this.lastName,
  });

  final String username;
  final String password;
  final String facebookID;
  final String appleID;
  final String googleID;
  final String lineID;
  final String email;
  final String imageUrl;
  final String category;
  final String prefixName;
  final String firstName;
  final String lastName;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _acceptedPolicy = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.username;
    _passwordController.text = widget.password;
    _emailController.text = widget.email;
    _firstNameController.text = widget.firstName;
    _lastNameController.text = widget.lastName;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    if (!_acceptedPolicy) {
      _showMessage('กรุณายอมรับข้อตกลงและนโยบายก่อนสมัครสมาชิก');
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));

    final profile = {
      'code': 'LOCAL-${DateTime.now().millisecondsSinceEpoch}',
      'username': _usernameController.text.trim(),
      'category': 'guest',
      'prefixName': '',
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'idcard': '',
      'imageUrl': '',
      'isActive': true,
      'status': 'A',
      'province': 'นครราชสีมา',
    };

    await _storage.write(key: 'dataUserLoginDDPM', value: jsonEncode(profile));
    await _storage.write(key: 'localProfile', value: jsonEncode(profile));
    await _storage.write(
        key: 'profileCode2', value: profile['code'].toString());
    await _storage.write(
        key: 'username', value: profile['username'].toString());
    await _storage.write(key: 'profileCategory', value: 'guest');
    await _storage.write(
        key: 'profileFirstName', value: profile['firstName'].toString());
    await _storage.write(
        key: 'profileLastName', value: profile['lastName'].toString());
    await _storage.write(key: 'profileImageUrl', value: '');
    await _storage.write(key: 'idcard', value: '');

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Menu()),
      (route) => false,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Sarabun')),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void goBack() => Navigator.maybePop(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: KoratAppBar(
        title: 'สมัครสมาชิก',
        subtitle: 'สร้างบัญชี local สำหรับใช้งาน Korat Connect',
        showBack: true,
        onBack: goBack,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          32 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ข้อมูลบัญชี',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _RegisterField(
                    controller: _usernameController,
                    label: 'ชื่อผู้ใช้งาน',
                    icon: Icons.person_rounded,
                  ),
                  const SizedBox(height: 12),
                  _RegisterField(
                    controller: _passwordController,
                    label: 'รหัสผ่าน',
                    icon: Icons.lock_rounded,
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  _RegisterField(
                    controller: _confirmPasswordController,
                    label: 'ยืนยันรหัสผ่าน',
                    icon: Icons.lock_reset_rounded,
                    obscureText: true,
                    validator: (value) {
                      if ((value ?? '').isEmpty) return 'กรุณายืนยันรหัสผ่าน';
                      if (value != _passwordController.text) {
                        return 'รหัสผ่านไม่ตรงกัน';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'ข้อมูลติดต่อ',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _RegisterField(
                    controller: _firstNameController,
                    label: 'ชื่อ',
                    icon: Icons.badge_rounded,
                  ),
                  const SizedBox(height: 12),
                  _RegisterField(
                    controller: _lastNameController,
                    label: 'นามสกุล',
                    icon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 12),
                  _RegisterField(
                    controller: _phoneController,
                    label: 'เบอร์โทรศัพท์',
                    icon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  _RegisterField(
                    controller: _emailController,
                    label: 'อีเมล',
                    icon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: _acceptedPolicy,
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (value) =>
                        setState(() => _acceptedPolicy = value ?? false),
                    title: const Text(
                      'ฉันยอมรับข้อตกลงการใช้งานและนโยบายความเป็นส่วนตัว',
                      style: TextStyle(
                        fontFamily: 'Sarabun',
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : const Text('สมัครและเข้าสู่ระบบ'),
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

class _RegisterField extends StatelessWidget {
  const _RegisterField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator ??
          (value) {
            if ((value ?? '').trim().isEmpty) return 'กรุณากรอก$label';
            return null;
          },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
      ),
    );
  }
}
