import 'package:flutter/foundation.dart';

class ReporterLocalStore {
  ReporterLocalStore._();

  static final revision = ValueNotifier<int>(0);

  static final List<Map<String, String>> reports = [
    {
      'code': 'LOCAL-001',
      'title': 'ถนนชำรุดบริเวณชุมชนหนองไผ่ล้อม',
      'category': 'ถนนและการจราจร',
      'description': 'พบพื้นผิวถนนเป็นหลุมหลายจุด ขอให้หน่วยงานเข้าตรวจสอบและแก้ไข',
      'date': '1 ก.ย. 2569',
      'status': 'กำลังดำเนินการ',
      'statusCode': 'A',
    },
    {
      'code': 'LOCAL-002',
      'title': 'ไฟส่องสว่างดับในซอยมิตรภาพ',
      'category': 'ไฟฟ้าสาธารณะ',
      'description': 'ไฟส่องสว่างดับช่วงกลางคืน ทำให้ประชาชนสัญจรไม่สะดวก',
      'date': '28 ส.ค. 2569',
      'status': 'รอดำเนินการ',
      'statusCode': 'N',
    },
  ];

  static void add({
    required String title,
    required String category,
    required String description,
  }) {
    final now = DateTime.now();
    reports.insert(0, {
      'code': 'LOCAL-${now.millisecondsSinceEpoch}',
      'title': title,
      'category': category,
      'description': description,
      'date': '${now.day}/${now.month}/${now.year + 543}',
      'status': 'รอดำเนินการ',
      'statusCode': 'N',
    });
    revision.value++;
  }
}
