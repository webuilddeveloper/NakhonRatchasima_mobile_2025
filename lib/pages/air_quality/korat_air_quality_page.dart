import 'package:flutter/material.dart';
import '../../apptheme.dart';
import '../../component/korat_ui.dart';

class KoratAirQualityData {
  final String district;
  final String stationName;
  final int aqi;
  final double pm25;
  final double pm10;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String updateTime;

  const KoratAirQualityData({
    required this.district,
    required this.stationName,
    required this.aqi,
    required this.pm25,
    required this.pm10,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.updateTime,
  });

  String get statusText {
    if (aqi <= 25) return 'ดีมาก';
    if (aqi <= 50) return 'ดี';
    if (aqi <= 100) return 'ปานกลาง';
    if (aqi <= 200) return 'เริ่มมีผลกระทบ';
    return 'มีผลกระทบต่อสุขภาพ';
  }

  Color get statusColor {
    if (aqi <= 25) return const Color(0xFF0284C7);
    if (aqi <= 50) return const Color(0xFF10B981);
    if (aqi <= 100) return const Color(0xFFF59E0B);
    if (aqi <= 200) return const Color(0xFFEA580C);
    return const Color(0xFFDC2626);
  }

  IconData get statusIcon {
    if (aqi <= 50) return Icons.sentiment_very_satisfied_rounded;
    if (aqi <= 100) return Icons.sentiment_satisfied_rounded;
    if (aqi <= 200) return Icons.sentiment_dissatisfied_rounded;
    return Icons.masks_rounded;
  }

  String get healthAdvice {
    if (aqi <= 50) {
      return 'คุณภาพอากาศดีมาก เหมาะสำหรับการทำกิจกรรมกลางแจ้งและออกกำลังกาย';
    }
    if (aqi <= 100) {
      return 'ประชาชนทั่วไปสามารถทำกิจกรรมกลางแจ้งได้ตามปกติ ผู้ป่วยกลุ่มเสี่ยงควรสังเกตอาการตนเอง';
    }
    if (aqi <= 200) {
      return 'ควรสวมหน้ากากอนามัยป้องกันฝุ่น PM 2.5 ลดกิจกรรมกลางแจ้ง และหลีกเลี่ยงบริเวณที่มีฝุ่นหนาแน่น';
    }
    return 'งดกิจกรรมกลางแจ้งทุกชนิด สวมหน้ากาก N95 เมื่อจำเป็นต้องออกนอกอาคาร และเฝ้าระวังสุขภาพอย่างใกล้ชิด';
  }
}

class KoratAirQualityPage extends StatefulWidget {
  const KoratAirQualityPage({super.key});

  @override
  State<KoratAirQualityPage> createState() => _KoratAirQualityPageState();
}

class _KoratAirQualityPageState extends State<KoratAirQualityPage> {
  int _selectedStationIndex = 0;

  final List<KoratAirQualityData> _stations = const [
    KoratAirQualityData(
      district: 'อ.เมืองนครราชสีมา',
      stationName: 'สถานีตรวจวัดศาลากลางจังหวัดนครราชสีมา',
      aqi: 42,
      pm25: 18.5,
      pm10: 36.0,
      temperature: 31.0,
      humidity: 58,
      windSpeed: 8.5,
      updateTime: 'วันนี้ 16:00 น.',
    ),
    KoratAirQualityData(
      district: 'อ.ปากช่อง (เขาใหญ่)',
      stationName: 'สถานีอุทยานแห่งชาติเขาใหญ่',
      aqi: 22,
      pm25: 7.2,
      pm10: 16.0,
      temperature: 26.5,
      humidity: 74,
      windSpeed: 6.2,
      updateTime: 'วันนี้ 16:00 น.',
    ),
    KoratAirQualityData(
      district: 'อ.พิมาย',
      stationName: 'สถานีอุทยานประวัติศาสตร์พิมาย',
      aqi: 65,
      pm25: 34.0,
      pm10: 55.0,
      temperature: 32.5,
      humidity: 52,
      windSpeed: 10.0,
      updateTime: 'วันนี้ 16:00 น.',
    ),
    KoratAirQualityData(
      district: 'อ.สีคิ้ว (ลำตะคอง)',
      stationName: 'สถานีอ่างเก็บน้ำลำตะคอง',
      aqi: 36,
      pm25: 14.8,
      pm10: 29.0,
      temperature: 29.0,
      humidity: 65,
      windSpeed: 12.0,
      updateTime: 'วันนี้ 16:00 น.',
    ),
    KoratAirQualityData(
      district: 'อ.ด่านขุนทด',
      stationName: 'สถานีทุ่งกังหันลมห้วยบง',
      aqi: 48,
      pm25: 21.0,
      pm10: 42.0,
      temperature: 30.5,
      humidity: 60,
      windSpeed: 15.2,
      updateTime: 'วันนี้ 16:00 น.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final current = _stations[_selectedStationIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: KoratAppBar(
        title: 'คุณภาพอากาศ & PM 2.5',
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // Station Selector Chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _stations.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final station = _stations[index];
                final isSelected = index == _selectedStationIndex;
                return ChoiceChip(
                  label: Text(
                    station.district,
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedStationIndex = index);
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 18),

          // Main Hero Air Gauge Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  current.statusColor.withValues(alpha: 0.15),
                  AppColors.surface,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: current.statusColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            current.district,
                            style: const TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            current.stationName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time_rounded,
                              size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            current.updateTime,
                            style: const TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Center Gauge Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // AQI Circular Badge
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: current.statusColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: current.statusColor.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'AQI',
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 12,
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${current.aqi}',
                            style: const TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Level Status & PM 2.5
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: current.statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(current.statusIcon,
                                    size: 18, color: current.statusColor),
                                const SizedBox(width: 6),
                                Text(
                                  current.statusText,
                                  style: TextStyle(
                                    fontFamily: 'Kanit',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: current.statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: 'Kanit',
                                color: AppColors.textPrimary,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'PM 2.5: ',
                                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                                ),
                                TextSpan(
                                  text: '${current.pm25} ',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const TextSpan(
                                  text: 'µg/m³',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'PM 10: ${current.pm10} µg/m³',
                            style: const TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 16),

                // Weather Mini-Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: _buildWeatherItem(
                        icon: Icons.thermostat_rounded,
                        label: 'อุณหภูมิ',
                        value: '${current.temperature.toStringAsFixed(1)} °C',
                      ),
                    ),
                    Expanded(
                      child: _buildWeatherItem(
                        icon: Icons.water_drop_outlined,
                        label: 'ความชื้น',
                        value: '${current.humidity} %',
                      ),
                    ),
                    Expanded(
                      child: _buildWeatherItem(
                        icon: Icons.air_rounded,
                        label: 'ความเร็วลม',
                        value: '${current.windSpeed} กม./ชม.',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Health Recommendations Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: AppColors.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.health_and_safety_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'คำแนะนำการปฏิบัติตน',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  current.healthAdvice,
                  style: const TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildAdvicePill(
                      icon: Icons.masks_outlined,
                      text: current.aqi > 100 ? 'ควรสวมหน้ากาก' : 'สวมหน้ากากเมื่อจำเป็น',
                      highlight: current.aqi > 100,
                    ),
                    const SizedBox(width: 8),
                    _buildAdvicePill(
                      icon: Icons.directions_run_rounded,
                      text: current.aqi > 100 ? 'เลี่ยงกิจกรรมกลางแจ้ง' : 'ออกกำลังกายได้',
                      highlight: current.aqi > 100,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 24-Hour Forecast / Trend
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'แนวโน้มค่าฝุ่น PM 2.5 (24 ชั่วโมงที่ผ่านมา)',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildHourlyBar('00:00', 12, 0.3),
                      _buildHourlyBar('04:00', 15, 0.35),
                      _buildHourlyBar('08:00', 28, 0.65),
                      _buildHourlyBar('12:00', 22, 0.52),
                      _buildHourlyBar('16:00', current.pm25.toInt(), (current.pm25 / 50).clamp(0.2, 1.0)),
                      _buildHourlyBar('20:00', 18, 0.42),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Kanit',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Kanit',
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAdvicePill({
    required IconData icon,
    required String text,
    required bool highlight,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: highlight ? AppColors.error.withValues(alpha: 0.1) : AppColors.surfaceWarm,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color: highlight ? AppColors.error : AppColors.primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: highlight ? AppColors.error : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyBar(String time, int val, double ratio) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$val',
          style: const TextStyle(
            fontFamily: 'Kanit',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 24,
          height: 60 * ratio,
          decoration: BoxDecoration(
            color: val > 35 ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          time,
          style: const TextStyle(
            fontFamily: 'Kanit',
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

