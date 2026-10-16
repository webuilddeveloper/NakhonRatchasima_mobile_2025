import 'package:flutter/material.dart';
import 'package:ratchasima/apptheme.dart';
import 'package:ratchasima/component/korat_ui.dart';

class ReporterHistortForm extends StatelessWidget {
  const ReporterHistortForm({super.key, this.url, this.code, this.model, this.urlComment, this.urlGallery});

  final String? url;
  final String? code;
  final dynamic model;
  final String? urlComment;
  final String? urlGallery;

  Color _statusColor(String status) {
    switch (status) {
      case 'กำลังดำเนินการ':
        return AppColors.warning;
      case 'ดำเนินการแล้ว':
        return AppColors.success;
      case 'ยกเลิกการดำเนินการ':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = model is Map
        ? model.map<String, String>((key, value) => MapEntry(
              key.toString(),
              value?.toString() ?? '',
            ))
        : <String, String>{};
    final status = report['status'] ?? 'รอดำเนินการ';
    final color = _statusColor(status);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: KoratAppBar(title: 'รายละเอียดการแจ้งเหตุ', showBack: true, onBack: () => Navigator.pop(context)),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 18, 16, 28), children: [
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: AppColors.surface, borderRadius: KoratRadius.lg, border: Border.all(color: AppColors.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(width: 46, height: 46, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle), child: Icon(Icons.assignment_outlined, color: color, size: 25)), const SizedBox(width: 12), Expanded(child: Text(report['title'] ?? 'รายละเอียดเรื่องที่แจ้ง', style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Kanit', fontSize: 20, fontWeight: FontWeight.w600, height: 1.2)))]), const SizedBox(height: 18), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9)), child: Text(status, style: TextStyle(color: color, fontFamily: 'Kanit', fontSize: 12, fontWeight: FontWeight.w600))), const SizedBox(height: 16), const Divider(color: AppColors.border), const SizedBox(height: 12), _InfoRow(label: 'หมวดหมู่', value: report['category'] ?? 'ไม่ระบุ'), _InfoRow(label: 'วันที่แจ้ง', value: report['date'] ?? '-'), _InfoRow(label: 'รหัสอ้างอิง', value: report['code'] ?? code ?? '-'), const SizedBox(height: 12), Text(report['description'] ?? 'ยังไม่มีรายละเอียดเพิ่มเติม', style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Sarabun', fontSize: 14, height: 1.45))]),),
        const SizedBox(height: 18),
        const Text('ความคืบหน้าของเรื่อง', style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Kanit', fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _Timeline(status: status),
        const SizedBox(height: 18),
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: KoratRadius.md), child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20), SizedBox(width: 10), Expanded(child: Text('หน้านี้ใช้ข้อมูลตัวอย่างในเครื่องชั่วคราว เมื่อ API พร้อมแล้วสามารถเปลี่ยนแหล่งข้อมูลได้ภายหลัง', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Sarabun', fontSize: 12, height: 1.35)))])),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 92, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Sarabun', fontSize: 12))), Expanded(child: Text(value, style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Sarabun', fontSize: 13, fontWeight: FontWeight.w600)))]));
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    const steps = ['รอดำเนินการ', 'กำลังดำเนินการ', 'ดำเนินการแล้ว'];
    final active = status == 'ดำเนินการแล้ว' ? 2 : status == 'กำลังดำเนินการ' ? 1 : 0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: KoratRadius.md, border: Border.all(color: AppColors.border)),
      child: Column(
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final done = index <= active;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(width: 25, height: 25, decoration: BoxDecoration(color: done ? AppColors.primary : AppColors.background, shape: BoxShape.circle, border: Border.all(color: done ? AppColors.primary : AppColors.border)), child: done ? const Icon(Icons.check_rounded, color: AppColors.surface, size: 16) : null),
                  if (index < steps.length - 1) Container(width: 2, height: 28, color: index < active ? AppColors.primary : AppColors.border),
                ],
              ),
              const SizedBox(width: 12),
              Padding(padding: const EdgeInsets.only(top: 3), child: Text(entry.value, style: TextStyle(color: done ? AppColors.textPrimary : AppColors.textSecondary, fontFamily: 'Kanit', fontSize: 14, fontWeight: done ? FontWeight.w600 : FontWeight.w400))),
            ],
          );
        }).toList(),
      ),
    );
  }
}
