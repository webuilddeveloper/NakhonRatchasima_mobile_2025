import 'package:flutter/material.dart';
import 'package:ratchasima/pages/reporter/reporter_history_list.dart';

class ComplainFollow extends StatefulWidget {
  const ComplainFollow({super.key});

  @override
  State<ComplainFollow> createState() => _ComplainFollowState();
}

class _ComplainFollowState extends State<ComplainFollow> {
  @override
  Widget build(BuildContext context) => const ReporterHistoryList(title: 'ติดตามปัญหา');
}
