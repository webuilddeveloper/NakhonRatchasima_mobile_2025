import 'package:flutter/material.dart';
import 'package:ratchasima/apptheme.dart';
import 'package:ratchasima/component/korat_ui.dart';

class WelfareListPage extends StatefulWidget {
  const WelfareListPage({super.key});

  @override
  State<WelfareListPage> createState() => _WelfareListPageState();
}

class _WelfareListPageState extends State<WelfareListPage> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'ทั้งหมด';

  final List<Map<String, Object>> _welfareList = [
    {
      'title': 'เบี้ยยังชีพผู้สูงอายุ',
      'subtitle': 'เงินช่วยเหลือรายเดือนสำหรับผู้สูงอายุที่มีคุณสมบัติตามเกณฑ์',
      'category': 'ผู้สูงอายุ',
      'benefit': 'รับเงินช่วยเหลือรายเดือนตามช่วงอายุ',
      'eligibility': 'ผู้มีอายุ 60 ปีขึ้นไป และมีภูมิลำเนาอยู่ในจังหวัดนครราชสีมา',
      'status': 'เปิดรับคำขอ',
      'icon': Icons.elderly_rounded,
    },
    {
      'title': 'เงินอุดหนุนผู้พิการ',
      'subtitle': 'สิทธิช่วยเหลือและสนับสนุนคุณภาพชีวิตสำหรับผู้พิการ',
      'category': 'ผู้พิการ',
      'benefit': 'เงินสนับสนุนรายเดือนและบริการช่วยเหลือที่เกี่ยวข้อง',
      'eligibility': 'มีบัตรประจำตัวคนพิการและลงทะเบียนตามหลักเกณฑ์',
      'status': 'เปิดรับคำขอ',
      'icon': Icons.accessible_forward_rounded,
    },
    {
      'title': 'สิทธิหลักประกันสุขภาพ',
      'subtitle': 'เข้าถึงบริการสาธารณสุขใกล้บ้านตามสิทธิของคุณ',
      'category': 'สุขภาพ',
      'benefit': 'รับบริการตรวจรักษาและส่งเสริมสุขภาพตามสิทธิ',
      'eligibility': 'ประชาชนที่มีสิทธิหลักประกันสุขภาพแห่งชาติ',
      'status': 'พร้อมใช้',
      'icon': Icons.health_and_safety_rounded,
    },
    {
      'title': 'บัตรสวัสดิการแห่งรัฐ',
      'subtitle': 'ช่วยลดภาระค่าใช้จ่ายพื้นฐานสำหรับผู้มีรายได้น้อย',
      'category': 'รายได้น้อย',
      'benefit': 'ใช้สิทธิตามวงเงินและเงื่อนไขของโครงการภาครัฐ',
      'eligibility': 'ผู้ผ่านการตรวจสอบคุณสมบัติตามโครงการบัตรสวัสดิการแห่งรัฐ',
      'status': 'ตรวจสอบสิทธิ์',
      'icon': Icons.credit_card_rounded,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, Object>> get _filteredWelfare {
    final query = _searchController.text.trim().toLowerCase();
    return _welfareList.where((item) {
      final matchesCategory = _selectedCategory == 'ทั้งหมด' ||
          item['category'] == _selectedCategory;
      final searchable = '${item['title']} ${item['subtitle']} ${item['category']} ${item['benefit']} ${item['eligibility']}'.toLowerCase();
      return matchesCategory && (query.isEmpty || searchable.contains(query));
    }).toList();
  }

  void _showDetails(Map<String, Object> welfare) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WelfareDetails(welfare: welfare),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['ทั้งหมด', ..._welfareList.map((item) => item['category'] as String)];
    final items = _filteredWelfare;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: KoratAppBar(
        title: 'สวัสดิการชาวโคราช',
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryBright],
              ),
              borderRadius: KoratRadius.lg,
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.volunteer_activism_rounded,
                      color: AppColors.surface, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('สิทธิ์ที่คุณอาจได้รับ', style: TextStyle(color: AppColors.surface, fontFamily: 'Kanit', fontSize: 19, fontWeight: FontWeight.w600)),
                      SizedBox(height: 3),
                      Text('รวมข้อมูลสวัสดิการสำหรับคนโคราชไว้ในที่เดียว', style: TextStyle(color: AppColors.surface, fontFamily: 'Sarabun', fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'ค้นหาสวัสดิการหรือสิทธิ์ที่สนใจ',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
              suffixIcon: _searchController.text.isEmpty ? null : IconButton(onPressed: () { _searchController.clear(); setState(() {}); }, icon: const Icon(Icons.close_rounded)),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.4)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = categories[index];
                final selected = category == _selectedCategory;
                return ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedCategory = category),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                  labelStyle: TextStyle(
                    color: selected ? AppColors.surface : AppColors.textSecondary,
                    fontFamily: 'Kanit',
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                );
              },
            ),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('รายการสวัสดิการ', style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Kanit', fontSize: 20, fontWeight: FontWeight.w600)),
              Text('${items.length} รายการ', style: const TextStyle(color: AppColors.primary, fontFamily: 'Sarabun', fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: Text('ไม่พบสวัสดิการที่ค้นหา', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Sarabun'))))
          else
            ...items.asMap().entries.map((entry) => _WelfareCard(welfare: entry.value, onTap: () => _showDetails(entry.value))),
        ],
      ),
    );
  }
}

class _WelfareCard extends StatelessWidget {
  const _WelfareCard({required this.welfare, required this.onTap});
  final Map<String, Object> welfare;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: KoratRadius.md,
        child: InkWell(
          onTap: onTap,
          borderRadius: KoratRadius.md,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(width: 52, height: 52, decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle), child: Icon(welfare['icon'] as IconData, color: AppColors.primary, size: 27)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(welfare['title'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Kanit', fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 3), Text(welfare['subtitle'] as String, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Sarabun', fontSize: 12, height: 1.25)), const SizedBox(height: 7), Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text(welfare['status'] as String, style: const TextStyle(color: AppColors.success, fontFamily: 'Kanit', fontSize: 10, fontWeight: FontWeight.w600))), const Spacer(), const Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 22)])])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WelfareDetails extends StatelessWidget {
  const _WelfareDetails({required this.welfare});
  final Map<String, Object> welfare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)))),
          const SizedBox(height: 18),
          Row(children: [Container(width: 50, height: 50, decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle), child: Icon(welfare['icon'] as IconData, color: AppColors.primary, size: 26)), const SizedBox(width: 12), Expanded(child: Text(welfare['title'] as String, style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Kanit', fontSize: 20, fontWeight: FontWeight.w600)))]),
          const SizedBox(height: 20),
          _DetailRow(label: 'สิทธิประโยชน์', value: welfare['benefit'] as String, icon: Icons.card_giftcard_rounded),
          const SizedBox(height: 12),
          _DetailRow(label: 'คุณสมบัติเบื้องต้น', value: welfare['eligibility'] as String, icon: Icons.fact_check_outlined),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.surface, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))), child: const Text('เข้าใจแล้ว', style: TextStyle(fontFamily: 'Kanit', fontWeight: FontWeight.w600)))),
        ]),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(13)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: AppColors.primary, size: 20), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: AppColors.primary, fontFamily: 'Kanit', fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 2), Text(value, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Sarabun', fontSize: 12, height: 1.35))]))]));
}
