import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ratchasima/apptheme.dart';
import 'package:ratchasima/component/korat_ui.dart';

class EditUserInformationPage extends StatefulWidget {
  const EditUserInformationPage({super.key});

  @override
  State<EditUserInformationPage> createState() =>
      _EditUserInformationPageState();
}

class _EditUserInformationPageState extends State<EditUserInformationPage> {
  final _storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _idCardController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocalProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _idCardController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalProfile() async {
    final raw = await _storage.read(key: 'localProfile');
    final fallback = {
      'firstName': await _storage.read(key: 'profileFirstName') ?? '',
      'lastName': await _storage.read(key: 'profileLastName') ?? '',
      'phone': '',
      'email': '',
      'idcard': await _storage.read(key: 'idcard') ?? '',
      'address': '',
    };
    final data = raw == null || raw.isEmpty
        ? fallback
        : jsonDecode(raw) as Map<String, dynamic>;

    _firstNameController.text = (data['firstName'] ?? '').toString();
    _lastNameController.text = (data['lastName'] ?? '').toString();
    _phoneController.text = (data['phone'] ?? '').toString();
    _emailController.text = (data['email'] ?? '').toString();
    _idCardController.text = (data['idcard'] ?? '').toString();
    _addressController.text = (data['address'] ?? '').toString();

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final raw = await _storage.read(key: 'localProfile');
    final data = raw == null || raw.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(raw) as Map<String, dynamic>;

    data.addAll({
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'idcard': _idCardController.text.trim(),
      'address': _addressController.text.trim(),
      'province': data['province'] ?? 'นครราชสีมา',
      'imageUrl': data['imageUrl'] ?? '',
      'category': data['category'] ?? 'guest',
      'status': 'A',
      'isActive': true,
    });

    await _storage.write(key: 'localProfile', value: jsonEncode(data));
    await _storage.write(key: 'dataUserLoginDDPM', value: jsonEncode(data));
    await _storage.write(key: 'profileFirstName', value: data['firstName']);
    await _storage.write(key: 'profileLastName', value: data['lastName']);
    await _storage.write(key: 'idcard', value: data['idcard']);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'บันทึกข้อมูล local เรียบร้อย',
          style: TextStyle(fontFamily: 'Sarabun'),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context, true);
  }

  void goBack() => Navigator.maybePop(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: KoratAppBar(
        title: 'แก้ไขข้อมูล',
        subtitle: 'บันทึกข้อมูลผู้ใช้ไว้ในเครื่อง',
        showBack: true,
        onBack: goBack,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
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
                          'ข้อมูลสมาชิก',
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ProfileField(
                          controller: _firstNameController,
                          label: 'ชื่อ',
                          icon: Icons.badge_rounded,
                        ),
                        const SizedBox(height: 12),
                        _ProfileField(
                          controller: _lastNameController,
                          label: 'นามสกุล',
                          icon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 12),
                        _ProfileField(
                          controller: _phoneController,
                          label: 'เบอร์โทรศัพท์',
                          icon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        _ProfileField(
                          controller: _emailController,
                          label: 'อีเมล',
                          icon: Icons.email_rounded,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        _ProfileField(
                          controller: _idCardController,
                          label: 'เลขบัตรประชาชน',
                          icon: Icons.credit_card_rounded,
                          keyboardType: TextInputType.number,
                          requiredField: false,
                        ),
                        const SizedBox(height: 12),
                        _ProfileField(
                          controller: _addressController,
                          label: 'ที่อยู่',
                          icon: Icons.home_rounded,
                          maxLines: 3,
                          requiredField: false,
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _save,
                            child: const Text('บันทึกข้อมูล'),
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

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.requiredField = true,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool requiredField;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: requiredField
          ? (value) {
              if ((value ?? '').trim().isEmpty) return 'กรุณากรอก$label';
              return null;
            }
          : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
      ),
    );
  }
}
