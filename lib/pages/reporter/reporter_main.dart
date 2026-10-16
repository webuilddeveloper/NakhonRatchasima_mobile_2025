import 'package:flutter/material.dart';
import 'package:ratchasima/apptheme.dart';
import 'package:ratchasima/component/korat_ui.dart';

import 'reporter_history_list.dart';
import 'reporter_list_category.dart';

class ReporterMain extends StatelessWidget {
  const ReporterMain({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: KoratAppBar(title: title ?? 'แจ้งเหตุ / แจ้งปัญหา'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryBright]),
              borderRadius: KoratRadius.lg,
            ),
            child: const Row(children: [
              Icon(Icons.campaign_rounded, color: AppColors.surface, size: 42),
              SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('เสียงของคุณสำคัญ', style: TextStyle(color: AppColors.surface, fontFamily: 'Kanit', fontSize: 22, fontWeight: FontWeight.w600)), SizedBox(height: 4), Text('แจ้งปัญหาในพื้นที่ และติดตามความคืบหน้าได้ในที่เดียว', style: TextStyle(color: AppColors.surface, fontFamily: 'Sarabun', fontSize: 13, height: 1.3))])),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('เลือกสิ่งที่ต้องการทำ', style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Kanit', fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _ActionCard(icon: Icons.add_task_rounded, title: 'แจ้งปัญหา', subtitle: 'ส่งเรื่องร้องเรียนหรือแจ้งเหตุในพื้นที่', color: AppColors.primary, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReporterListCategory(title: 'แจ้งปัญหา')))),
          _ActionCard(icon: Icons.track_changes_rounded, title: 'ติดตามปัญหา', subtitle: 'ตรวจสอบสถานะและความคืบหน้าของเรื่องที่แจ้ง', color: AppColors.info, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReporterHistoryList(title: 'ติดตามปัญหา')))),
          const SizedBox(height: 20),
          const Text('ภาพรวมการแจ้งปัญหา', style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Kanit', fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(children: [Expanded(child: _StatCard(value: '3', label: 'เรื่องทั้งหมด', icon: Icons.assignment_outlined)), const SizedBox(width: 10), Expanded(child: _StatCard(value: '1', label: 'กำลังดำเนินการ', icon: Icons.autorenew_rounded))]),
          const SizedBox(height: 10),
          Row(children: [Expanded(child: _StatCard(value: '1', label: 'รอดำเนินการ', icon: Icons.schedule_rounded)), const SizedBox(width: 10), Expanded(child: _StatCard(value: '1', label: 'ดำเนินการแล้ว', icon: Icons.check_circle_outline_rounded))]),
          const SizedBox(height: 18),
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: KoratRadius.md), child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20), SizedBox(width: 10), Expanded(child: Text('ข้อมูลภาพรวมเป็นข้อมูลตัวอย่างในเครื่องชั่วคราว เพื่อใช้ทดสอบ Flow ก่อนเชื่อมต่อ API จริง', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Sarabun', fontSize: 12, height: 1.35)))])),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 10), child: Material(color: AppColors.surface, borderRadius: KoratRadius.md, child: InkWell(onTap: onTap, borderRadius: KoratRadius.md, child: Padding(padding: const EdgeInsets.all(15), child: Row(children: [Container(width: 52, height: 52, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: color, size: 27)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Kanit', fontSize: 17, fontWeight: FontWeight.w600)), Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Sarabun', fontSize: 12))])), Icon(Icons.chevron_right_rounded, color: color, size: 26)]))));
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label, required this.icon});
  final String value;
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.surface, borderRadius: KoratRadius.md, border: Border.all(color: AppColors.border)), child: Row(children: [Icon(icon, color: AppColors.primary, size: 25), const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(color: AppColors.primary, fontFamily: 'Kanit', fontSize: 22, fontWeight: FontWeight.w700)), Text(label, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Sarabun', fontSize: 11))])]));
}
