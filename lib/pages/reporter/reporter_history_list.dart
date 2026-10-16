import 'package:flutter/material.dart';
import 'package:ratchasima/apptheme.dart';
import 'package:ratchasima/component/korat_ui.dart';

import 'reporter_history_form.dart';
import 'reporter_local_store.dart';

class ReporterHistoryList extends StatefulWidget {
  const ReporterHistoryList({super.key, this.title, this.username});

  final String? title;
  final String? username;

  @override
  State<ReporterHistoryList> createState() => _ReporterHistoryListState();
}

class _ReporterHistoryListState extends State<ReporterHistoryList> {
  final _searchController = TextEditingController();
  String _selectedStatus = 'ทั้งหมด';

  List<Map<String, String>> get _reports => ReporterLocalStore.reports;

  @override
  void initState() {
    super.initState();
    ReporterLocalStore.revision.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    ReporterLocalStore.revision.removeListener(_refresh);
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filteredReports {
    final query = _searchController.text.trim().toLowerCase();
    return _reports.where((report) {
      final matchesStatus = _selectedStatus == 'ทั้งหมด' || report['status'] == _selectedStatus;
      final text = '${report['title']} ${report['category']}'.toLowerCase();
      return matchesStatus && (query.isEmpty || text.contains(query));
    }).toList();
  }

  Color _statusColor(String code) {
    switch (code) {
      case 'A':
        return AppColors.warning;
      case 'C':
        return AppColors.success;
      case 'D':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reports = _filteredReports;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: KoratAppBar(
        title: 'ติดตามสถานะการแจ้งเหตุ',
        subtitle: 'ข้อมูลตัวอย่างในเครื่อง',
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryBright]),
              borderRadius: KoratRadius.lg,
            ),
            child: Row(children: [
              Container(width: 52, height: 52, decoration: BoxDecoration(color: AppColors.surface.withValues(alpha: 0.18), shape: BoxShape.circle), child: const Icon(Icons.track_changes_rounded, color: AppColors.surface, size: 28)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('เรื่องที่คุณแจ้งไว้', style: TextStyle(color: AppColors.surface, fontFamily: 'Kanit', fontSize: 19, fontWeight: FontWeight.w600)), const SizedBox(height: 3), Text('${_reports.length} รายการที่กำลังติดตาม', style: const TextStyle(color: AppColors.surface, fontFamily: 'Sarabun', fontSize: 12))])),
            ]),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(hintText: 'ค้นหาเรื่องที่แจ้ง', prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary), suffixIcon: _searchController.text.isEmpty ? null : IconButton(onPressed: () { _searchController.clear(); setState(() {}); }, icon: const Icon(Icons.close_rounded)), filled: true, fillColor: AppColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.4))),
          ),
          const SizedBox(height: 14),
          SizedBox(height: 38, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: const ['ทั้งหมด', 'รอดำเนินการ', 'กำลังดำเนินการ', 'ดำเนินการแล้ว'].length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (context, index) { final status = const ['ทั้งหมด', 'รอดำเนินการ', 'กำลังดำเนินการ', 'ดำเนินการแล้ว'][index]; final selected = _selectedStatus == status; return ChoiceChip(label: Text(status), selected: selected, onSelected: (_) => setState(() => _selectedStatus = status), selectedColor: AppColors.primary, backgroundColor: AppColors.surface, side: BorderSide(color: selected ? AppColors.primary : AppColors.border), labelStyle: TextStyle(color: selected ? AppColors.surface : AppColors.textSecondary, fontFamily: 'Kanit', fontSize: 11, fontWeight: selected ? FontWeight.w600 : FontWeight.w400), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))); })),
          const SizedBox(height: 22),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('รายการแจ้งเหตุ', style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Kanit', fontSize: 20, fontWeight: FontWeight.w600)), Text('${reports.length} รายการ', style: const TextStyle(color: AppColors.primary, fontFamily: 'Sarabun', fontSize: 12))]),
          const SizedBox(height: 10),
          if (reports.isEmpty)
            const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Center(child: Text('ไม่พบรายการที่ค้นหา', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Sarabun'))))
          else
            ...reports.map((report) => _ReportCard(report: report, statusColor: _statusColor(report['statusCode']!), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReporterHistortForm(url: '', code: report['code'], model: report))))),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report, required this.statusColor, required this.onTap});
  final Map<String, String> report;
  final Color statusColor;
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
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(13)),
                  child: Icon(Icons.assignment_outlined, color: statusColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [Expanded(child: Text(report['category']!, style: TextStyle(color: statusColor, fontFamily: 'Kanit', fontSize: 11, fontWeight: FontWeight.w600))), Text(report['date']!, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Sarabun', fontSize: 10))]),
                      const SizedBox(height: 4),
                      Text(report['title']!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Kanit', fontSize: 16, fontWeight: FontWeight.w600, height: 1.2)),
                      const SizedBox(height: 8),
                      Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text(report['status']!, style: TextStyle(color: statusColor, fontFamily: 'Kanit', fontSize: 10, fontWeight: FontWeight.w600))), const Spacer(), const Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 22)]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
