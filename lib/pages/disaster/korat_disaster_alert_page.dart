import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../apptheme.dart';
import '../../component/korat_ui.dart';
import '../../shared/local_notification_service.dart';

class KoratDisasterAlertPage extends StatefulWidget {
  const KoratDisasterAlertPage({super.key});

  @override
  State<KoratDisasterAlertPage> createState() => _KoratDisasterAlertPageState();
}

class _KoratDisasterAlertPageState extends State<KoratDisasterAlertPage> {
  String _selectedCategory = 'ทั้งหมด';

  final List<String> _categories = [
    'ทั้งหมด',
    'ระดับน้ำลำตะคอง',
    'สภาพอากาศ',
    'ฝุ่น PM 2.5',
    'ประกาศด่วนจังหวัด',
  ];

  late List<Map<String, dynamic>> _alerts = [
    {
      'id': 1,
      'category': 'ระดับน้ำลำตะคอง',
      'title': 'เฝ้าระวังระดับน้ำลำตะคอง ช่วงไหลผ่านเขตเทศบาลนครราชสีมา',
      'severity': 'warning', // critical, warning, watch, info
      'severityText': 'เตือนภัย / เตรียมพร้อม',
      'date': 'วันนี้ 15:40 น.',
      'location': 'ชุมชนมิตรภาพ ซอย 4, ชุมชนสำโรงจันทร์, ประตูระบายน้ำข่อยงาม',
      'summary':
          'มวลน้ำจากลำตะคองตอนบน (ปากช่อง-สีคิ้ว) กำลังไหลเข้าเขตเทศบาล ระดับน้ำในตลิ่งเพิ่มขึ้นประมาณ 25-35 ซม. ยังต่ำกว่าตลิ่ง 60 ซม. เจ้าหน้าที่เตรียมเครื่องสูบน้ำ 14 จุด',
      'damStatus': 'เขื่อนลำตะคองจุ 214.5 ล้าน ลบ.ม. (68.1%) อยู่ในเกณฑ์ปลอดภัย',
      'checklist': [
        'ยกของและเครื่องใช้ไฟฟ้าขึ้นที่สูงอย่างน้อย 50 ซม.',
        'ย้ายยานพาหนะไปจอดบริเวณพื้นที่ดอน หรือลานจอดที่เทศบาลจัดเตรียม',
        'ผู้ป่วยติดเตียงและเด็กเล็ก ให้เตรียมยารักษาโรคและเอกสารสำคัญ',
      ],
      'hotline': '044-242044',
      'hotlineName': 'ศูนย์ ปภ. เทศบาลนครราชสีมา',
    },
    {
      'id': 2,
      'category': 'สภาพอากาศ',
      'title': 'เตือนพายุฤดูร้อน ฝนฟ้าคะนอง และลมกระโชกแรงในพื้นที่โคราช',
      'severity': 'watch',
      'severityText': 'เฝ้าระวัง',
      'date': 'วันนี้ 12:00 น.',
      'location': 'อ.เมือง, อ.ปากช่อง, อ.สีคิ้ว, อ.โนนไทย, อ.พิมาย, อ.เฉลิมพระเกียรติ',
      'summary':
          'มวลอากาศเย็นจากจีนปะทะความร้อนในภาคอีสาน ทำให้มีโอกาสเกิดพายุฤดูร้อน ฝนฟ้าคะนองร้อยละ 60 ของพื้นที่ ลมกระโชกแรง และอาจมีลูกเห็บตกบางแห่ง',
      'damStatus': null,
      'checklist': [
        'หลีกเลี่ยงการอยู่ในที่โล่งแจ้ง ใต้ต้นไม้ใหญ่ และป้ายโฆษณาที่ไม่มั่นคง',
        'ตรวจสอบความแข็งแรงของหลังคาบ้านและสิ่งปลูกสร้าง',
        'ระมัดระวังอันตรายจากฟ้าผ่า งดใช้อุปกรณ์อิเล็กทรอนิกส์กลางแจ้ง',
      ],
      'hotline': '1182',
      'hotlineName': 'สายด่วนกรมอุตุนิยมวิทยา',
    },
    {
      'id': 3,
      'category': 'ฝุ่น PM 2.5',
      'title': 'รายงานดัชนีคุณภาพอากาศและฝุ่นละออง PM 2.5 ประจำวัน',
      'severity': 'info',
      'severityText': 'ปกติ / แจ้งเพื่อทราบ',
      'date': 'วันนี้ 07:00 น.',
      'location': 'สถานีตรวจวัด ต.ในเมือง อ.เมืองนครราชสีมา',
      'summary':
          'ค่าฝุ่น PM 2.5 เฉลี่ย 24 ชม. ตรวจวัดได้ 18.2 µg/m³ (AQI 42) คุณภาพอากาศอยู่ในเกณฑ์ดีมาก ทัศนวิสัยแจ่มใส ประชาชนสามารถทำกิจกรรมกลางแจ้งได้ตามปกติ',
      'damStatus': null,
      'checklist': [
        'ประชาชนทั่วไปและกลุ่มเสี่ยงทำกิจกรรมกลางแจ้งได้ตามปกติ',
        'ร่วมมือกันงดการเผาในที่โล่งและวัสดุทางการเกษตรเพื่อคงอากาศบริสุทธิ์',
      ],
      'hotline': '1669',
      'hotlineName': 'สายด่วนการแพทย์ฉุกเฉินโคราช',
    },
    {
      'id': 4,
      'category': 'ประกาศด่วนจังหวัด',
      'title': 'เปิดใช้งานทางหลวงพิเศษระหว่างเมือง M6 ปากช่อง-เลี่ยงเมืองโคราช ฟรี',
      'severity': 'info',
      'severityText': 'ประกาศด่วนจังหวัด',
      'date': 'เมื่อวานนี้',
      'location': 'ทางหลวงพิเศษระหว่างเมืองหมายเลข 6 (ช่วงปากช่อง - ขอนแก่น/ขามทะเลสอ)',
      'summary':
          'จังหวัดนครราชสีมาประสานกรมทางหลวง เปิดให้รถยนต์ 4 ล้อ วิ่งบนมอเตอร์เวย์ M6 ได้ฟรีตลอด 24 ชั่วโมง เพื่อระบายการจราจรบนถนนมิตรภาพสายหลัก',
      'damStatus': null,
      'checklist': [
        'จำกัดความเร็วไม่เกิน 80 กม./ชม. บนเส้นทางชั่วคราว',
        'ห้ามรถจักรยานยนต์ รถบรรทุก และรถโดยสารขนาดใหญ่ขึ้นใช้งาน',
        'เตรียมน้ำมันเชื้อเพลิงให้เพียงพอ เนื่องจากยังไม่มีสถานีบริการน้ำมันบนสายทาง',
      ],
      'hotline': '1586',
      'hotlineName': 'สายด่วนกรมทางหลวง',
    },
  ];

  List<Map<String, dynamic>> get _filteredAlerts {
    if (_selectedCategory == 'ทั้งหมด') return _alerts;
    return _alerts
        .where((item) => item['category'] == _selectedCategory)
        .toList();
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'critical':
        return const Color(0xFFDC2626); // Red
      case 'warning':
        return const Color(0xFFEA580C); // Vibrant Orange
      case 'watch':
        return const Color(0xFFD97706); // Amber Gold
      case 'info':
      default:
        return const Color(0xFF2563EB); // Royal Blue
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity) {
      case 'critical':
        return Icons.emergency_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'watch':
        return Icons.radar_rounded;
      case 'info':
      default:
        return Icons.info_outline_rounded;
    }
  }

  void _callHotline(String number) async {
    final clean = number.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _triggerTestAlert({
    required String title,
    required String body,
    required String category,
    required String severity,
  }) async {
    HapticFeedback.heavyImpact();

    // Show local push notification
    try {
      await KoratNotificationService.instance.showDisasterAlert(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
      );
    } catch (_) {}

    if (!mounted) return;

    // Show in-app bottom sheet confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _getSeverityColor(severity),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.notifications_active_rounded,
                color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'ส่ง Push Notification ทดสอบเรียบร้อย!\nดูที่แถบแจ้งเตือนด้านบนเครื่อง',
                style: const TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openTestSimulator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.paddingOf(ctx).bottom + 20,
          ),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.science_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'เครื่องมือทดสอบการแจ้งเตือนฉุกเฉิน',
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'จำลองการส่ง Push Notification เข้ามือถือทันที',
                          style: TextStyle(
                            fontFamily: 'Sarabun',
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'เลือกสถานการณ์ที่ต้องการทดสอบ:',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              _buildTestScenarioItem(
                icon: Icons.water_drop_rounded,
                title: 'เตือนระดับน้ำลำตะคองขึ้นสูง',
                subtitle: 'แจ้งเตือนระดับน้ำเพิ่ม 35 ซม. เตรียมยกของขึ้นที่สูง',
                color: const Color(0xFFEA580C),
                onTap: () {
                  Navigator.pop(ctx);
                  _triggerTestAlert(
                    title: '[เตือนภัยลำตะคอง] ระดับน้ำเพิ่มขึ้น 35 ซม.',
                    body:
                        'มวลน้ำไหลเข้าเขตเทศบาลนครราชสีมา ชุมชนมิตรภาพ ซอย 4 โปรดยกของขึ้นที่สูงทันที',
                    category: 'ระดับน้ำลำตะคอง',
                    severity: 'warning',
                  );
                },
              ),
              _buildTestScenarioItem(
                icon: Icons.thunderstorm_rounded,
                title: 'เตือนพายุฤดูร้อน & ลูกเห็บตก',
                subtitle: 'ฝนฟ้าคะนอง ลมกระโชกแรง ในเขต อ.เมือง และ อ.ปากช่อง',
                color: const Color(0xFFD97706),
                onTap: () {
                  Navigator.pop(ctx);
                  _triggerTestAlert(
                    title: '[เตือนพายุฤดูร้อน] นครราชสีมา ลมกระโชกแรง',
                    body:
                        'ระวังพายุฤดูร้อน ลมกระโชกแรง และลูกเห็บตก หลีกเลี่ยงการอยู่ในที่โล่งแจ้งใต้ต้นไม้ใหญ่',
                    category: 'สภาพอากาศ',
                    severity: 'watch',
                  );
                },
              ),
              _buildTestScenarioItem(
                icon: Icons.air_rounded,
                title: 'เตือนภัยวิกฤตฝุ่น PM 2.5',
                subtitle: 'ค่าฝุ่นพุ่งเกินเกณฑ์มาตรฐานสีแดง 75 µg/m³',
                color: const Color(0xFFDC2626),
                onTap: () {
                  Navigator.pop(ctx);
                  _triggerTestAlert(
                    title: '[เตือนวิกฤตฝุ่น PM 2.5] ค่าฝุ่น 78 µg/m³',
                    body:
                        'ดัชนีอากาศมีผลกระทบต่อสุขภาพ งดกิจกรรมกลางแจ้งและสวมหน้ากาก N95 ตลอดเวลา',
                    category: 'ฝุ่น PM 2.5',
                    severity: 'critical',
                  );
                },
              ),
              _buildTestScenarioItem(
                icon: Icons.campaign_rounded,
                title: 'ประกาศด่วนจังหวัดนครราชสีมา',
                subtitle: 'เปิดเส้นทางพิเศษ มอเตอร์เวย์ M6 ระบายการจราจร',
                color: const Color(0xFF2563EB),
                onTap: () {
                  Navigator.pop(ctx);
                  _triggerTestAlert(
                    title: '[ประกาศด่วนจังหวัด] เปิดใช้มอเตอร์เวย์ M6 ฟรี',
                    body:
                        'เปิดให้รถยนต์ 4 ล้อ สัญจรชั่วคราวปากช่อง-โคราช เพื่อระบายรถติดบนถนนมิตรภาพ',
                    category: 'ประกาศด่วนจังหวัด',
                    severity: 'info',
                  );
                },
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.help_outline_rounded,
                        size: 20, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'เมื่อกดปุ่ม ระบบจะส่ง Local Push Notification จำลองขึ้นบนหน้าจอมือถือทันที',
                        style: TextStyle(
                          fontFamily: 'Sarabun',
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTestScenarioItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.22), width: 1.1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Sarabun',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ยิงแจ้งเตือน',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alerts = _filteredAlerts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: KoratAppBar(
        title: 'เตือนภัยพิบัติฉุกเฉิน',
        subtitle: 'ศูนย์ข้อมูลและแจ้งเตือนภัยจังหวัดนครราชสีมา',
        showBack: true,
        actions: [
          KoratAppBarAction(
            tooltip: 'ทดสอบการแจ้งเตือน',
            icon: Icons.science_rounded,
            onPressed: _openTestSimulator,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openTestSimulator,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.notification_add_rounded, size: 20),
        label: const Text(
          'ทดสอบ Push Alert',
          style: TextStyle(fontFamily: 'Kanit', fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          100 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Status Card
            _buildLiveStatusHero(),
            const SizedBox(height: 18),

            // Category Filter Pills
            _buildCategoryFilter(),
            const SizedBox(height: 18),

            // Alert List Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ประกาศเตือนภัยล่าสุด (${alerts.length})',
                  style: const TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 3.5,
                        backgroundColor: Color(0xFF10B981),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'เฝ้าระวัง 24 ชม.',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Alert Cards
            if (alerts.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: KoratStateView(
                    state: KoratViewState.empty,
                    title: 'ไม่มีประกาศในหมวดนี้',
                    message: 'สถานการณ์ในพื้นที่อยู่ในระดับปกติ',
                  ),
                ),
              )
            else
              ...alerts.map((item) => _buildAlertCard(item)),

            const SizedBox(height: 16),
            // Emergency Hotlines Card
            _buildEmergencyContactsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveStatusHero() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF261C14),
            Color(0xFF422212),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'สถานะเฝ้าระวังระดับสีเหลือง',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'อัปเดต 15:40 น.',
                style: TextStyle(
                  fontFamily: 'Sarabun',
                  fontSize: 11.5,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'ศูนย์เฝ้าระวังเตือนภัยเมืองโคราช',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ติดตามสถานการณ์น้ำท่วมลำตะคอง สภาพอากาศ และประกาศฉุกเฉิน 32 อำเภอ',
            style: TextStyle(
              fontFamily: 'Sarabun',
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 14),
          // 3 Indicator Pills
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.water_drop_rounded,
                  label: 'เขื่อนลำตะคอง',
                  value: '68.1%',
                  sub: 'ปกติ',
                  color: const Color(0xFF0284C7),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.cloud_outlined,
                  label: 'เรดาร์ฝน',
                  value: '60%',
                  sub: 'มีฝนฟ้าคะนอง',
                  color: const Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.air_rounded,
                  label: 'PM 2.5',
                  value: '18 µg',
                  sub: 'อากาศดีมาก',
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
    required String sub,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Sarabun',
                    fontSize: 10.5,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Kanit',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Sarabun',
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                cat,
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              onSelected: (_) => setState(() => _selectedCategory = cat),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> item) {
    final severity = item['severity'] as String;
    final color = _getSeverityColor(severity);
    final icon = _getSeverityIcon(severity);
    final checklist = item['checklist'] as List<String>;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar with Severity
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item['severityText'],
                    style: const TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item['category'],
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
                const Spacer(),
                Text(
                  item['date'],
                  style: const TextStyle(
                    fontFamily: 'Sarabun',
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: const TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                // Location Pin
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 15, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item['location'],
                        style: const TextStyle(
                          fontFamily: 'Sarabun',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item['summary'],
                  style: const TextStyle(
                    fontFamily: 'Sarabun',
                    fontSize: 13.5,
                    height: 1.45,
                    color: AppColors.textPrimary,
                  ),
                ),

                if (item['damStatus'] != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            const Color(0xFF0284C7).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 15, color: Color(0xFF0284C7)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item['damStatus'],
                            style: const TextStyle(
                              fontFamily: 'Sarabun',
                              fontSize: 12,
                              color: Color(0xFF0369A1),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Checklist / Actions
                const Text(
                  'ข้อแนะนำการปฏิบัติตัว:',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                ...checklist.map(
                  (step) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(
                            step,
                            style: const TextStyle(
                              fontFamily: 'Sarabun',
                              fontSize: 12.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                // Hotline button
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone_in_talk_rounded,
                          size: 16, color: Color(0xFF059669)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${item['hotlineName']} (${item['hotline']})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _callHotline(item['hotline']),
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          foregroundColor: const Color(0xFF059669),
                          side: const BorderSide(color: Color(0xFF059669)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.call, size: 13),
                        label: const Text(
                          'โทรทันที',
                          style: TextStyle(fontFamily: 'Kanit', fontSize: 11.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.contact_phone_rounded,
                  color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'สายด่วนช่วยเหลือฉุกเฉิน 24 ชั่วโมง',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildHotlineRow('ปภ. จังหวัดนครราชสีมา (แจ้งเหตุด่วนสาธารณภัย)', '1784'),
          const Divider(height: 12),
          _buildHotlineRow('ศูนย์บรรเทาสาธารณภัยเทศบาลนครราชสีมา', '044-242044'),
          const Divider(height: 12),
          _buildHotlineRow('สายด่วนการแพทย์ฉุกเฉิน (กู้ชีพโคราช)', '1669'),
          const Divider(height: 12),
          _buildHotlineRow('สายด่วนชลประทาน (ระดับน้ำเขื่อน-ลำตะคอง)', '1460'),
          const Divider(height: 12),
          _buildHotlineRow('ดับเพลิง / กู้ภัยนครราชสีมา', '199'),
        ],
      ),
    );
  }

  Widget _buildHotlineRow(String name, String number) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontFamily: 'Sarabun',
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          number,
          style: const TextStyle(
            fontFamily: 'Kanit',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _callHotline(number),
          icon: const Icon(Icons.phone_rounded,
              size: 18, color: Color(0xFF059669)),
          visualDensity: VisualDensity.compact,
          tooltip: 'โทรออก',
        ),
      ],
    );
  }
}

