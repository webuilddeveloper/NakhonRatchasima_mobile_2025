import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../apptheme.dart';
import '../../component/korat_ui.dart';

class KoratTransitRoute {
  final String routeNumber;
  final String routeName;
  final String origin;
  final String destination;
  final Color badgeColor;
  final Color textColor;
  final String colorName;
  final String operatingHours;
  final String fare;
  final String frequency;
  final List<String> stops;
  final List<String> highlights;

  const KoratTransitRoute({
    required this.routeNumber,
    required this.routeName,
    required this.origin,
    required this.destination,
    required this.badgeColor,
    required this.textColor,
    required this.colorName,
    required this.operatingHours,
    required this.fare,
    required this.frequency,
    required this.stops,
    required this.highlights,
  });
}

class KoratTransitPage extends StatefulWidget {
  const KoratTransitPage({super.key});

  @override
  State<KoratTransitPage> createState() => _KoratTransitPageState();
}

class _KoratTransitPageState extends State<KoratTransitPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'ทั้งหมด';

  final List<KoratTransitRoute> _routes = const [
    KoratTransitRoute(
      routeNumber: 'สาย 1',
      routeName: 'บขส.ใหม่ - หัวทะเล',
      origin: 'สถานีขนส่งผู้โดยสารแห่งที่ 2 (บขส.ใหม่)',
      destination: 'ตำบลหัวทะเล (โลตัสหัวทะเล)',
      badgeColor: Color(0xFFEA580C),
      textColor: Colors.white,
      colorName: 'รถขาว-แถบส้ม',
      operatingHours: '05:30 - 19:30 น.',
      fare: '8 - 10 บาท ตลอดสาย (นักเรียน 5 บาท)',
      frequency: 'ทุก 10-15 นาที',
      highlights: ['บขส.ใหม่', 'ตลาดแม่กิมเฮง', 'คลังพลาซ่า', 'หัวทะเล'],
      stops: [
        'สถานีขนส่ง บขส.ใหม่',
        'ตลาดประปา',
        'ประตูพลล้าน',
        'ตลาดแม่กิมเฮง',
        'คลังพลาซ่า อัษฎางค์',
        'ประตูชุมพล (ย่าโม)',
        'โรงเรียนสุรนารีวิทยา',
        'แยกหัวทะเล',
        'โลตัส หัวทะเล',
      ],
    ),
    KoratTransitRoute(
      routeNumber: 'สาย 2',
      routeName: 'หนองปรือ - บขส.เก่า',
      origin: 'บ้านหนองปรือ / หัวทะเล',
      destination: 'สถานีขนส่งผู้โดยสารแห่งที่ 1 (บขส.เก่า)',
      badgeColor: Color(0xFF0284C7),
      textColor: Colors.white,
      colorName: 'รถขาว-แถบน้ำเงิน',
      operatingHours: '05:45 - 19:00 น.',
      fare: '8 - 10 บาท ตลอดสาย',
      frequency: 'ทุก 15 นาที',
      highlights: ['อนุสาวรีย์ย่าโม', 'ตลาดแม่กิมเฮง', 'บขส.เก่า'],
      stops: [
        'หนองปรือ',
        'โลตัสหัวทะเล',
        'ค่ายสุรนารี',
        'อนุสาวรีย์ท้าวสุรนารี (ย่าโม)',
        'ตลาดแม่กิมเฮง',
        'สถานีดับเพลิงเทศบาล',
        'สถานีขนส่ง บขส.เก่า',
      ],
    ),
    KoratTransitRoute(
      routeNumber: 'สาย 7',
      routeName: 'เดอะมอลล์ - ม.ราชภัฏ - มทร.อีสาน',
      origin: 'ห้างสรรพสินค้าเดอะมอลล์ โคราช',
      destination: 'ม.เทคโนโลยีราชมงคลอีสาน (มทร.)',
      badgeColor: Color(0xFF7C3AED),
      textColor: Colors.white,
      colorName: 'รถสองแถวสีม่วง',
      operatingHours: '06:00 - 20:00 น.',
      fare: '8 - 10 บาท ตลอดสาย',
      frequency: 'ทุก 10 นาที',
      highlights: ['เดอะมอลล์', 'ม.ราชภัฏ', 'มทร.อีสาน', 'ตลาดประปา'],
      stops: [
        'เดอะมอลล์ โคราช',
        'ตลาดประปา',
        'โรงเรียนอัสสัมชัญนครราชสีมา',
        'วิทยาลัยเทคนิคนครราชสีมา',
        'มหาวิทยาลัยราชภัฏนครราชสีมา',
        'มหาวิทยาลัยเทคโนโลยีราชมงคลอีสาน',
      ],
    ),
    KoratTransitRoute(
      routeNumber: 'สาย 8',
      routeName: 'สถานีรถไฟจิระ - รพ.มหาราช - บขส.ใหม่',
      origin: 'สถานีรถไฟชุมทางถนนจิระ',
      destination: 'สถานีขนส่ง บขส.ใหม่',
      badgeColor: Color(0xFF059669),
      textColor: Colors.white,
      colorName: 'รถสองแถวสีเขียว',
      operatingHours: '05:30 - 19:30 น.',
      fare: '8 - 10 บาท ตลอดสาย',
      frequency: 'ทุก 12 นาที',
      highlights: ['สถานีรถไฟ', 'รพ.มหาราชนครราชสีมา', 'บขส.ใหม่'],
      stops: [
        'สถานีรถไฟจิระ / สถานีรถไฟนครราชสีมา',
        'ห้าแยกหัวรถไฟ',
        'ตลาดเทศบาล',
        'โรงพยาบาลมหาราชนครราชสีมา',
        'โรงเรียนราชสีมาวิทยาลัย',
        'สถานีขนส่ง บขส.ใหม่',
      ],
    ),
    KoratTransitRoute(
      routeNumber: 'สาย 14',
      routeName: 'เทอร์มินอล 21 - เซ็นทรัล - มทส. ประตู 1',
      origin: 'เทอร์มินอล 21 โคราช / บิ๊กซี',
      destination: 'ม.เทคโนโลยีสุรนารี (มทส. ประตู 1)',
      badgeColor: Color(0xFFD97706),
      textColor: Colors.white,
      colorName: 'รถสองแถวสีส้ม',
      operatingHours: '06:00 - 20:30 น.',
      fare: '10 - 15 บาท (ตามระยะทาง)',
      frequency: 'ทุก 10-15 นาที',
      highlights: ['เทอร์มินอล 21', 'เซ็นทรัลโคราช', 'มทส.'],
      stops: [
        'เทอร์มินอล 21 โคราช',
        'บิ๊กซี ซูเปอร์เซ็นเตอร์',
        'เซ็นทรัล โคราช',
        'โลตัสนครราชสีมา',
        'สนามกีฬาเฉลิมพระเกียรติ 80 พรรษา',
        'ม.เทคโนโลยีสุรนารี (ประตู 1 หอพักนักศึกษา)',
      ],
    ),
    KoratTransitRoute(
      routeNumber: 'สาย 17',
      routeName: 'บขส.ใหม่ - ประตูน้ำ - มทส. ประตู 2',
      origin: 'สถานีขนส่ง บขส.ใหม่',
      destination: 'ม.เทคโนโลยีสุรนารี (มทส. ประตู 2 โรงพยาบาล มทส.)',
      badgeColor: Color(0xFFCA8A04),
      textColor: Colors.white,
      colorName: 'รถสองแถวสีเหลือง',
      operatingHours: '06:00 - 20:00 น.',
      fare: '10 - 15 บาท',
      frequency: 'ทุก 15 นาที',
      highlights: ['บขส.ใหม่', 'ตลาดสวายเรียง', 'รพ.มหาวิทยาลัย มทส.'],
      stops: [
        'บขส.ใหม่',
        'สามแยกปักธงชัย',
        'ตลาดสวายเรียง',
        'โรงเรียนสุรธรรมพิทักษ์',
        'อ่างห้วยยาง',
        'โรงพยาบาลมหาวิทยาลัยเทคโนโลยีสุรนารี',
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<KoratTransitRoute> get _filteredRoutes {
    final query = _searchController.text.trim().toLowerCase();
    return _routes.where((r) {
      final matchesQuery = query.isEmpty ||
          r.routeNumber.toLowerCase().contains(query) ||
          r.routeName.toLowerCase().contains(query) ||
          r.stops.any((s) => s.toLowerCase().contains(query)) ||
          r.highlights.any((h) => h.toLowerCase().contains(query));

      if (!matchesQuery) return false;

      if (_selectedCategory == 'ผ่านย่าโม') {
        return r.highlights.contains('อนุสาวรีย์ย่าโม') || r.stops.any((s) => s.contains('ย่าโม'));
      } else if (_selectedCategory == 'ห้างสรรพสินค้า') {
        return r.stops.any((s) => s.contains('มอลล์') || s.contains('เทอร์มินอล') || s.contains('เซ็นทรัล') || s.contains('คลัง'));
      } else if (_selectedCategory == 'มหาวิทยาลัย') {
        return r.stops.any((s) => s.contains('มทส') || s.contains('ราชภัฏ') || s.contains('มทร'));
      } else if (_selectedCategory == 'บขส./รถไฟ') {
        return r.stops.any((s) => s.contains('บขส') || s.contains('รถไฟ'));
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final routes = _filteredRoutes;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: KoratAppBar(
        title: 'เส้นทางรถสองแถว & ขนส่ง',
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            color: AppColors.surface,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontFamily: 'Kanit', fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'ค้นหาสายรถ หรือจุดหมาย (เช่น ย่าโม, มทส, เซ็นทรัล)...',
                    hintStyle: const TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surfaceWarm,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Filter chips
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      'ทั้งหมด',
                      'ผ่านย่าโม',
                      'ห้างสรรพสินค้า',
                      'มหาวิทยาลัย',
                      'บขส./รถไฟ',
                    ].map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            cat,
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 12,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surfaceWarm,
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.border,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedCategory = cat);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Route List
          Expanded(
            child: routes.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.directions_bus_outlined,
                              size: 54, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          const Text(
                            'ไม่พบเส้นทางรถที่ค้นหา',
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'ลองค้นหาด้วยชื่อสถานที่ เช่น "ย่าโม" หรือ "บขส."',
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    itemCount: routes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = routes[index];
                      return _buildRouteCard(context, item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(BuildContext context, KoratTransitRoute item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showRouteDetailSheet(context, item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Route badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.badgeColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item.routeNumber,
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: item.textColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWarm,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.colorName,
                        style: const TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppColors.textSecondary),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.routeName,
                  style: const TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.trip_origin_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'ต้นทาง: ${item.origin}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF10B981)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'ปลายทาง: ${item.destination}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: item.highlights.map((h) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '• $h',
                        style: const TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRouteDetailSheet(BuildContext context, KoratTransitRoute item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.78,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Top drag handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.badgeColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item.routeNumber,
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: item.textColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.routeName,
                        style: const TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.border, height: 1),

              // Info Summary Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: AppColors.surfaceWarm,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetaItem(Icons.access_time_rounded, 'เวลาวิ่ง', item.operatingHours),
                    _buildMetaItem(Icons.payments_outlined, 'ค่าโดยสาร', item.fare.split(' ')[0] + ' ' + item.fare.split(' ')[1]),
                    _buildMetaItem(Icons.repeat_rounded, 'ความถี่', item.frequency),
                  ],
                ),
              ),

              // Stops Timeline
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      'จุดจอดตามลำดับเส้นทาง',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...List.generate(item.stops.length, (idx) {
                      final isFirst = idx == 0;
                      final isLast = idx == item.stops.length - 1;
                      final stop = item.stops[idx];

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: isFirst
                                      ? AppColors.primary
                                      : (isLast ? const Color(0xFF10B981) : Colors.white),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isFirst
                                        ? AppColors.primary
                                        : (isLast ? const Color(0xFF10B981) : item.badgeColor),
                                    width: 3,
                                  ),
                                ),
                              ),
                              if (!isLast)
                                Container(
                                  width: 2,
                                  height: 38,
                                  color: AppColors.border,
                                ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 1),
                              child: Text(
                                stop,
                                style: TextStyle(
                                  fontFamily: 'Kanit',
                                  fontSize: 14,
                                  fontWeight: (isFirst || isLast) ? FontWeight.w600 : FontWeight.w400,
                                  color: (isFirst || isLast) ? AppColors.textPrimary : const Color(0xFF4B5563),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 20),

                    // Quick call help
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.phone_in_talk_rounded, color: AppColors.primary),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ศูนย์ประสานงานขนส่ง บขส. นครราชสีมา',
                                  style: TextStyle(
                                    fontFamily: 'Kanit',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  'โทรสอบถามตารางเวลาเดินรถ: 044-256006',
                                  style: TextStyle(
                                    fontFamily: 'Kanit',
                                    fontSize: 11.5,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.call, color: AppColors.primary),
                            onPressed: () {
                              launchUrl(Uri.parse('tel:044256006'));
                            },
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
      },
    );
  }

  Widget _buildMetaItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Kanit',
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Kanit',
            fontSize: 10.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

