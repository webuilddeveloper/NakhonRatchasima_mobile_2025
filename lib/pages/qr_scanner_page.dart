import 'package:flutter/material.dart';
import 'package:ratchasima/apptheme.dart';
import 'package:ratchasima/component/korat_ui.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  bool _isScanning = false;
  String? _result;

  void goBack() => Navigator.maybePop(context);

  Future<void> _mockScan() async {
    setState(() {
      _isScanning = true;
      _result = null;
    });
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _isScanning = false;
      _result = 'KC-LOCAL-PROFILE-${DateTime.now().millisecondsSinceEpoch}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: KoratAppBar(
        title: 'สแกน QR Code',
        subtitle: 'จำลองการสแกนข้อมูลสมาชิกและบริการ',
        showBack: true,
        onBack: goBack,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          20,
          24,
          20,
          32 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Center(
                      child: Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 118,
                        color: Colors.white.withValues(alpha: 0.16),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 210,
                      height: 210,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                  if (_isScanning)
                    Center(
                      child: Container(
                        width: 210,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBright,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ผลการสแกน',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _result ?? 'กดปุ่มด้านล่างเพื่อจำลองการสแกน QR Code',
                  style: const TextStyle(
                    fontFamily: 'Sarabun',
                    fontSize: 14,
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isScanning ? null : _mockScan,
              icon: _isScanning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.qr_code_scanner_rounded),
              label: Text(_isScanning ? 'กำลังสแกน...' : 'เริ่มสแกน'),
            ),
          ),
        ],
      ),
    );
  }
}
