import 'package:flutter/material.dart';
import 'package:ratchasima/apptheme.dart';
import 'package:ratchasima/component/korat_ui.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedType = 'ทั้งหมด';

  final List<Map<String, dynamic>> _historyList = [
    {
      'type': 'ร้องเรียน',
      'title': 'แจ้งปัญหาถนนชำรุด',
      'description': 'เรื่องถูกบันทึกไว้ในระบบและรอตรวจสอบจากเจ้าหน้าที่',
      'timestamp': 'วันนี้ 09:25',
      'status': 'รับเรื่องแล้ว',
      'icon': Icons.report_problem_rounded,
      'color': AppColors.error,
    },
    {
      'type': 'OTOP',
      'title': 'คำสั่งซื้อกระเป๋าสานมือ',
      'description': 'รอชำระเงินผ่าน QR Code เพื่อยืนยันคำสั่งซื้อ',
      'timestamp': 'เมื่อวาน 18:10',
      'status': 'รอชำระเงิน',
      'icon': Icons.shopping_bag_rounded,
      'color': AppColors.primary,
    },
    {
      'type': 'ข่าว',
      'title': 'เปิดกิจกรรมส่งเสริมการท่องเที่ยวโคราช',
      'description': 'คุณเปิดอ่านข่าวประชาสัมพันธ์ล่าสุด',
      'timestamp': '31 ส.ค. 2569',
      'status': 'ดูล่าสุด',
      'icon': Icons.campaign_rounded,
      'color': AppColors.info,
    },
    {
      'type': 'ท่องเที่ยว',
      'title': 'อนุสาวรีย์ท้าวสุรนารี (ย่าโม)',
      'description': 'บันทึกเป็นรายการเข้าชมล่าสุดจากหน้าท่องเที่ยว',
      'timestamp': '30 ส.ค. 2569',
      'status': 'เข้าชมแล้ว',
      'icon': Icons.place_rounded,
      'color': AppColors.success,
    },
    {
      'type': 'สวัสดิการ',
      'title': 'ตรวจสอบสิทธิประโยชน์สำหรับประชาชน',
      'description': 'รายการที่เปิดดูจากหน้าสวัสดิการชาวโคราช',
      'timestamp': '29 ส.ค. 2569',
      'status': 'ดูล่าสุด',
      'icon': Icons.volunteer_activism_rounded,
      'color': AppColors.warning,
    },
  ];

  List<String> get _types {
    final names = _historyList.map((item) => item['type'] as String).toSet();
    return ['ทั้งหมด', ...names];
  }

  List<Map<String, dynamic>> get _filteredHistory {
    if (_selectedType == 'ทั้งหมด') return _historyList;
    return _historyList.where((item) => item['type'] == _selectedType).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredHistory = _filteredHistory;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: KoratAppBar(
        title: 'ประวัติ',
        subtitle: 'กิจกรรม รายการที่เปิดดู และสถานะล่าสุด',
        actions: [
          KoratAppBarAction(
            tooltip: 'ล้างประวัติ',
            icon: Icons.delete_sweep_outlined,
            onPressed: _historyList.isEmpty ? () {} : _showClearHistoryDialog,
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          20,
          18,
          20,
          100 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          _HistoryFilter(
            types: _types,
            selectedType: _selectedType,
            onSelected: (type) => setState(() => _selectedType = type),
          ),
          const SizedBox(height: 20),
          _HistorySectionHeader(
            title: _selectedType == 'ทั้งหมด' ? 'กิจกรรมล่าสุด' : _selectedType,
            count: filteredHistory.length,
          ),
          const SizedBox(height: 12),
          if (filteredHistory.isEmpty)
            const KoratStateView(
              state: KoratViewState.empty,
              title: 'ไม่มีประวัติการใช้งาน',
              message: 'กิจกรรมและรายการที่คุณเปิดดูจะแสดงที่นี่',
            )
          else
            ...List.generate(
              filteredHistory.length,
              (index) => _HistoryCard(
                item: filteredHistory[index],
              ),
            ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'ล้างประวัติทั้งหมด',
          style: TextStyle(fontFamily: 'Kanit', fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'คุณต้องการลบประวัติการใช้งานทั้งหมดใช่หรือไม่?',
          style: TextStyle(fontFamily: 'Sarabun', height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _historyList.clear();
                _selectedType = 'ทั้งหมด';
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('ล้างประวัติ'),
          ),
        ],
      ),
    );
  }
}

class _HistoryFilter extends StatelessWidget {
  const _HistoryFilter({
    required this.types,
    required this.selectedType,
    required this.onSelected,
  });

  final List<String> types;
  final String selectedType;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final type = types[index];
          final selected = type == selectedType;
          return ChoiceChip(
            selected: selected,
            showCheckmark: false,
            label: Text(type),
            onSelected: (_) => onSelected(type),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            side: BorderSide(
              color: selected ? AppColors.primary : AppColors.border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            labelStyle: TextStyle(
              fontFamily: 'Sarabun',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: selected ? AppColors.surface : AppColors.textSecondary,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          );
        },
      ),
    );
  }
}

class _HistorySectionHeader extends StatelessWidget {
  const _HistorySectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Kanit',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          '$count รายการ',
          style: const TextStyle(
            fontFamily: 'Sarabun',
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final color = item['color'] as Color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showHistoryDetail(context, item),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Row(
                children: [
                  Container(width: 5, height: 128, color: color),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(item['icon'] as IconData,
                                    color: color, size: 23),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 5),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  item['type'] as String,
                                  style: TextStyle(
                                    fontFamily: 'Sarabun',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: color,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                item['timestamp'] as String,
                                style: const TextStyle(
                                  fontFamily: 'Sarabun',
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 9),
                          Text(
                            item['title'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['description'] as String,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Sarabun',
                              fontSize: 13,
                              height: 1.4,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(99),
                                  border: Border.all(
                                      color: color.withValues(alpha: 0.2)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.circle, size: 7, color: color),
                                    const SizedBox(width: 7),
                                    Text(
                                      item['status'] as String,
                                      style: TextStyle(
                                        fontFamily: 'Sarabun',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.chevron_right_rounded,
                                  color: AppColors.primary),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showHistoryDetail(BuildContext context, Map<String, dynamic> item) {
    final color = item['color'] as Color;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child:
                        Icon(item['icon'] as IconData, color: color, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['type'] as String,
                          style: TextStyle(
                            fontFamily: 'Sarabun',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                        Text(
                          item['title'] as String,
                          style: const TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                item['description'] as String,
                style: const TextStyle(
                  fontFamily: 'Sarabun',
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.18)),
                ),
                child: Text(
                  'สถานะ: ${item['status']}',
                  style: TextStyle(
                    fontFamily: 'Sarabun',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('ปิด'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
