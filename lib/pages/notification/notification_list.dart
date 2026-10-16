import 'package:flutter/material.dart';
import 'package:ratchasima/apptheme.dart';
import 'package:ratchasima/component/korat_ui.dart';

class NotificationList extends StatefulWidget {
  const NotificationList({super.key, required this.title});

  final String title;

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  String _selectedFilter = 'ทั้งหมด';

  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'เรื่องร้องเรียนของคุณถูกรับเรื่องแล้ว',
      'message': 'เจ้าหน้าที่ได้รับเรื่องถนนชำรุดและกำลังตรวจสอบพื้นที่',
      'time': 'วันนี้ 09:25',
      'type': 'ร้องเรียน',
      'isRead': false,
      'icon': Icons.report_problem_rounded,
      'color': AppColors.error,
    },
    {
      'title': 'แจ้งเตือนชำระเงินสินค้า OTOP',
      'message': 'คำสั่งซื้อกระเป๋าสานมือรอชำระเงินผ่าน QR Code',
      'time': 'เมื่อวาน 18:10',
      'type': 'OTOP',
      'isRead': false,
      'icon': Icons.shopping_bag_rounded,
      'color': AppColors.primary,
    },
    {
      'title': 'ข่าวประชาสัมพันธ์ใหม่',
      'message': 'ติดตามกิจกรรมส่งเสริมการท่องเที่ยวจังหวัดนครราชสีมา',
      'time': '31 ส.ค. 2569',
      'type': 'ข่าว',
      'isRead': true,
      'icon': Icons.campaign_rounded,
      'color': AppColors.info,
    },
    {
      'title': 'สิทธิประโยชน์ที่เหมาะกับคุณ',
      'message': 'มีข้อมูลสวัสดิการและบริการช่วยเหลือประชาชนที่เปิดให้ตรวจสอบ',
      'time': '30 ส.ค. 2569',
      'type': 'สวัสดิการ',
      'isRead': true,
      'icon': Icons.volunteer_activism_rounded,
      'color': AppColors.warning,
    },
  ];

  List<String> get _filters => [
        'ทั้งหมด',
        'ยังไม่อ่าน',
        ..._notifications.map((item) => item['type'] as String).toSet(),
      ];

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedFilter == 'ทั้งหมด') return _notifications;
    if (_selectedFilter == 'ยังไม่อ่าน') {
      return _notifications.where((item) => item['isRead'] == false).toList();
    }
    return _notifications
        .where((item) => item['type'] == _selectedFilter)
        .toList();
  }

  int get _unreadCount =>
      _notifications.where((item) => item['isRead'] == false).length;

  void goBack() => Navigator.maybePop(context);

  @override
  Widget build(BuildContext context) {
    final items = _filteredNotifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: KoratAppBar(
        title: widget.title,
        subtitle: 'ข่าวสารสำคัญและการติดตามบริการของคุณ',
        showBack: true,
        onBack: goBack,
        actions: [
          KoratAppBarAction(
            tooltip: 'อ่านทั้งหมด',
            icon: Icons.done_all_rounded,
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          100 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          // _NotificationHero(unreadCount: _unreadCount),
          const SizedBox(height: 16),
          _NotificationFilter(
            filters: _filters,
            selectedFilter: _selectedFilter,
            onSelected: (value) => setState(() => _selectedFilter = value),
          ),
          const SizedBox(height: 18),
          if (items.isEmpty)
            const KoratStateView(
              state: KoratViewState.empty,
              title: 'ไม่มีการแจ้งเตือน',
              message: 'รายการแจ้งเตือนจะแสดงที่นี่เมื่อมีข้อมูลใหม่',
            )
          else
            ...items.map(
              (item) => _NotificationCard(
                item: item,
                onTap: () => _openNotification(item),
              ),
            ),
        ],
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (final item in _notifications) {
        item['isRead'] = true;
      }
    });
  }

  void _openNotification(Map<String, dynamic> item) {
    setState(() => item['isRead'] = true);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _NotificationSheet(item: item),
    );
  }
}

class _NotificationHero extends StatelessWidget {
  const _NotificationHero({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ศูนย์แจ้งเตือน',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unreadCount > 0
                      ? 'มี $unreadCount รายการที่ยังไม่ได้อ่าน'
                      : 'คุณอ่านการแจ้งเตือนครบแล้ว',
                  style: const TextStyle(
                    fontFamily: 'Sarabun',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationFilter extends StatelessWidget {
  const _NotificationFilter({
    required this.filters,
    required this.selectedFilter,
    required this.onSelected,
  });

  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = filter == selectedFilter;
          return ChoiceChip(
            selected: selected,
            showCheckmark: false,
            label: Text(filter),
            onSelected: (_) => onSelected(filter),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            side: BorderSide(
              color: selected ? AppColors.primary : AppColors.border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            labelStyle: TextStyle(
              fontFamily: 'Sarabun',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: selected ? AppColors.surface : AppColors.textSecondary,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onTap});

  final Map<String, dynamic> item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = item['color'] as Color;
    final unread = item['isRead'] == false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color:
                    unread ? color.withValues(alpha: 0.35) : AppColors.border,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(item['icon'] as IconData, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item['type'] as String,
                            style: TextStyle(
                              fontFamily: 'Sarabun',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: color,
                            ),
                          ),
                          const Spacer(),
                          if (unread)
                            Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['title'] as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 16,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item['message'] as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Sarabun',
                          fontSize: 13,
                          height: 1.35,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.schedule_rounded,
                              size: 15, color: AppColors.textSecondary),
                          const SizedBox(width: 5),
                          Text(
                            item['time'] as String,
                            style: const TextStyle(
                              fontFamily: 'Sarabun',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
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

class _NotificationSheet extends StatelessWidget {
  const _NotificationSheet({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final color = item['color'] as Color;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(item['icon'] as IconData, color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item['title'] as String,
                  style: const TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            item['message'] as String,
            style: const TextStyle(
              fontFamily: 'Sarabun',
              fontSize: 15,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('รับทราบ'),
            ),
          ),
        ],
      ),
    );
  }
}
