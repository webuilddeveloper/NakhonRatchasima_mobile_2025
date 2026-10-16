import 'package:flutter/material.dart';
import 'package:ratchasima/apptheme.dart';
import 'package:ratchasima/component/korat_ui.dart';

import 'complain_add_detail.dart';

class ComplainDetail extends StatefulWidget {
  const ComplainDetail({super.key});

  @override
  State<ComplainDetail> createState() => _ComplainDetailState();
}

class _ComplainDetailState extends State<ComplainDetail> {
  final _searchController = TextEditingController();

  final _categories = const [
    {'title': 'ควันพิษและมลพิษ', 'subtitle': 'กลิ่น ควัน หรือมลพิษที่กระทบชุมชน', 'icon': Icons.cloud_rounded, 'color': AppColors.primary},
    {'title': 'ขยะมูลฝอย', 'subtitle': 'ขยะตกค้าง จุดทิ้งขยะ หรือการจัดเก็บ', 'icon': Icons.delete_outline_rounded, 'color': AppColors.success},
    {'title': 'มลพิษทางเสียง', 'subtitle': 'เสียงดังรบกวนในชุมชน', 'icon': Icons.volume_up_rounded, 'color': AppColors.warning},
    {'title': 'สัตว์จรจัด', 'subtitle': 'สัตว์จรจัดในพื้นที่สาธารณะ', 'icon': Icons.pets_rounded, 'color': AppColors.info},
    {'title': 'ต้นไม้และพื้นที่สีเขียว', 'subtitle': 'ต้นไม้กีดขวางหรือชำรุด', 'icon': Icons.forest_rounded, 'color': AppColors.success},
    {'title': 'ประปาและน้ำเสีย', 'subtitle': 'น้ำไม่ไหล ท่อแตก หรือน้ำเสีย', 'icon': Icons.water_drop_outlined, 'color': AppColors.info},
    {'title': 'ถนนและทางเท้า', 'subtitle': 'ถนนชำรุด หลุมบ่อ หรือทางเท้า', 'icon': Icons.directions_car_filled_outlined, 'color': AppColors.primaryBright},
    {'title': 'ไฟฟ้าสาธารณะ', 'subtitle': 'ไฟถนนดับหรืออุปกรณ์ชำรุด', 'icon': Icons.bolt_rounded, 'color': AppColors.warning},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final items = _categories.where((item) => '${item['title']} ${item['subtitle']}'.toLowerCase().contains(query)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: KoratAppBar(title: 'แจ้งปัญหา', showBack: true, onBack: () => Navigator.pop(context)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryBright], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: KoratRadius.lg,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Icon(Icons.campaign_rounded, color: AppColors.surface, size: 30), SizedBox(width: 10), Text('แจ้งปัญหาในพื้นที่', style: TextStyle(color: AppColors.surface, fontFamily: 'Kanit', fontSize: 20, fontWeight: FontWeight.w600))]),
                SizedBox(height: 8),
                Text('เลือกหัวข้อที่ตรงกับปัญหา เพื่อให้ส่งเรื่องได้รวดเร็วและตรงหน่วยงาน', style: TextStyle(color: AppColors.surface, fontFamily: 'Sarabun', fontSize: 12, height: 1.35)),
              ],
            ),
          ),
       
          const SizedBox(height: 14),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'ค้นหาหัวข้อแจ้งปัญหา',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.4)),
            ),
          ),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('เลือกหัวข้อ', style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Kanit', fontSize: 20, fontWeight: FontWeight.w600)), Text('${items.length} หัวข้อ', style: const TextStyle(color: AppColors.primary, fontFamily: 'Sarabun', fontSize: 12))]),
          const SizedBox(height: 10),
          if (items.isEmpty)
            const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Center(child: Text('ไม่พบหัวข้อที่ค้นหา', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Sarabun'))))
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.98),
              itemBuilder: (context, index) {
                final item = items[index];
                return _CategoryCard(
                  item: item,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ComplainAddDetail(label: item['title'] as String, code: item['title'] as String))),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.item, required this.onTap});

  final Map<String, Object> item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = item['color'] as Color;
    return Material(
      color: AppColors.surface,
      borderRadius: KoratRadius.md,
      child: InkWell(
        onTap: onTap,
        borderRadius: KoratRadius.md,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(15)), child: Icon(item['icon'] as IconData, color: color, size: 27)),
              const SizedBox(height: 10),
              Text(item['title'] as String, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Kanit', fontSize: 15, fontWeight: FontWeight.w600, height: 1.15)),
              const SizedBox(height: 4),
              Expanded(child: Text(item['subtitle'] as String, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Sarabun', fontSize: 11, height: 1.2))),
              Align(alignment: Alignment.bottomRight, child: Icon(Icons.arrow_forward_rounded, color: color, size: 19)),
            ],
          ),
        ),
      ),
    );
  }
}
