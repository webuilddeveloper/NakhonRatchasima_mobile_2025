import 'package:flutter/material.dart';
import 'package:ratchasima/apptheme.dart';
import 'package:ratchasima/component/korat_ui.dart';

import 'reporter_form.dart';

class ReporterListCategory extends StatefulWidget {
  const ReporterListCategory({super.key, this.title});
  final String? title;
  @override
  State<ReporterListCategory> createState() => _ReporterListCategoryState();
}

class _ReporterListCategoryState extends State<ReporterListCategory> {
  final _searchController = TextEditingController();
  final List<Map<String, Object>> _categories = [
    {'code': 'LOCAL-ROAD', 'title': 'ถนนและการจราจร', 'subtitle': 'ถนนชำรุด หลุมบ่อ ป้ายจราจร หรือการสัญจร', 'icon': Icons.traffic_rounded, 'color': AppColors.primary},
    {'code': 'LOCAL-LIGHT', 'title': 'ไฟฟ้าสาธารณะ', 'subtitle': 'ไฟถนนดับ เสาไฟชำรุด หรือสายไฟไม่ปลอดภัย', 'icon': Icons.lightbulb_outline_rounded, 'color': AppColors.warning},
    {'code': 'LOCAL-WASTE', 'title': 'สิ่งแวดล้อมและขยะ', 'subtitle': 'ขยะตกค้าง น้ำเสีย มลพิษ หรือพื้นที่สกปรก', 'icon': Icons.recycling_rounded, 'color': AppColors.success},
    {'code': 'LOCAL-WATER', 'title': 'น้ำประปาและสาธารณูปโภค', 'subtitle': 'น้ำไม่ไหล ท่อแตก หรือสาธารณูปโภคชำรุด', 'icon': Icons.water_drop_outlined, 'color': AppColors.info},
    {'code': 'LOCAL-OTHER', 'title': 'เหตุเดือดร้อนทั่วไป', 'subtitle': 'ปัญหาในชุมชนที่ต้องการให้หน่วยงานช่วยตรวจสอบ', 'icon': Icons.support_agent_rounded, 'color': AppColors.primaryBright},
  ];

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final categories = _categories.where((item) => '${item['title']} ${item['subtitle']}'.toLowerCase().contains(query)).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: KoratAppBar(title: widget.title ?? 'แจ้งปัญหา', showBack: true, onBack: () => Navigator.pop(context)),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 18, 16, 28), children: [
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: AppColors.surface, borderRadius: KoratRadius.lg, border: Border.all(color: AppColors.border)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('เลือกหัวข้อที่ต้องการแจ้ง', style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Kanit', fontSize: 21, fontWeight: FontWeight.w600)), SizedBox(height: 5), Text('เลือกหมวดหมู่ให้ตรงกับปัญหา เพื่อส่งเรื่องไปยังหน่วยงานที่เกี่ยวข้อง', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Sarabun', fontSize: 13, height: 1.35))])),
        const SizedBox(height: 16),
        TextField(controller: _searchController, onChanged: (_) => setState(() {}), decoration: InputDecoration(hintText: 'ค้นหาหัวข้อแจ้งปัญหา', prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary), filled: true, fillColor: AppColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.4)))),
        const SizedBox(height: 22),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('หัวข้อแจ้งปัญหา', style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Kanit', fontSize: 20, fontWeight: FontWeight.w600)), Text('${categories.length} หัวข้อ', style: const TextStyle(color: AppColors.primary, fontFamily: 'Sarabun', fontSize: 12))]),
        const SizedBox(height: 10),
        if (categories.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Center(child: Text('ไม่พบหัวข้อที่ค้นหา', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Sarabun')))) else ...categories.map((item) => _CategoryCard(item: item, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReporterFormPage(title: item['title'] as String, code: item['code'] as String))))),
      ]),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.item, required this.onTap});
  final Map<String, Object> item;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) { final color = item['color'] as Color; return Container(margin: const EdgeInsets.only(bottom: 11), child: Material(color: AppColors.surface, borderRadius: KoratRadius.md, child: InkWell(onTap: onTap, borderRadius: KoratRadius.md, child: Padding(padding: const EdgeInsets.all(15), child: Row(children: [Container(width: 52, height: 52, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(15)), child: Icon(item['icon'] as IconData, color: color, size: 27)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item['title'] as String, style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Kanit', fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 3), Text(item['subtitle'] as String, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Sarabun', fontSize: 12, height: 1.25))])), Icon(Icons.chevron_right_rounded, color: color, size: 25)])))); }
}
