import 'package:flutter/material.dart';
import 'package:ratchasima/apptheme.dart';
import 'package:ratchasima/component/korat_ui.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _sent = true;
    });
  }

  void goBack() => Navigator.maybePop(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: KoratAppBar(
        title: 'ลืมรหัสผ่าน',
        subtitle: 'รับลิงก์ตั้งรหัสผ่านใหม่แบบ local mock',
        showBack: true,
        onBack: goBack,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          20,
          28,
          20,
          32 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: _sent ? _buildSuccess() : _buildForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.lock_reset_rounded,
                color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 18),
          const Text(
            'กรอกอีเมลของคุณ',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'ระบบจะแสดงสถานะจำลองว่าส่งลิงก์ตั้งรหัสผ่านใหม่แล้ว',
            style: TextStyle(
              fontFamily: 'Sarabun',
              fontSize: 14,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final text = (value ?? '').trim();
              if (text.isEmpty) return 'กรุณากรอกอีเมล';
              if (!text.contains('@')) return 'รูปแบบอีเมลไม่ถูกต้อง';
              return null;
            },
            decoration: const InputDecoration(
              labelText: 'อีเมล',
              prefixIcon: Icon(Icons.email_rounded, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 18),
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
                  : const Text('ส่งลิงก์ตั้งรหัสผ่าน'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: AppColors.primarySoft,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_read_rounded,
              color: AppColors.primary, size: 38),
        ),
        const SizedBox(height: 18),
        const Text(
          'ส่งคำขอเรียบร้อย',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'เราได้จำลองการส่งลิงก์ไปที่ ${_emailController.text.trim()} แล้ว',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Sarabun',
            fontSize: 14,
            height: 1.45,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: goBack,
            child: const Text('กลับเข้าสู่ระบบ'),
          ),
        ),
      ],
    );
  }
}
