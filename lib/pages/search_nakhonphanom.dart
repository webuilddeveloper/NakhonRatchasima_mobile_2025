import 'package:flutter/material.dart';

import '../apptheme.dart';
import '../component/korat_ui.dart';
import 'about_us/about_us_form.dart';
import 'complain/complain.dart';
import 'contact/contact_list.dart';
import 'event_calendar/event_calendar_list.dart';
import 'knowledge/knowledge_list.dart';
import 'news/news_list.dart';
import 'notification/notification_list.dart';
import 'otop_product_list.dart';
import 'poi/poi_list.dart';
import 'poll/poll_list.dart';
import 'privilege/privilege_main.dart';
import 'question/question_list.dart';
import 'reporter/reporter_history_list.dart';
import 'training_course/training_course_list.dart';
import 'welfare_list.dart';

class SearchNakhonPhanomPage extends StatefulWidget {
  const SearchNakhonPhanomPage({super.key});

  @override
  State<SearchNakhonPhanomPage> createState() => _SearchNakhonPhanomPageState();
}

class _SearchNakhonPhanomPageState extends State<SearchNakhonPhanomPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedGroup = 'ทั้งหมด';

  late final List<_ServiceItem> _services = [
    _ServiceItem(
      title: 'แจ้งปัญหา',
      subtitle: 'แจ้งเหตุหรือปัญหาในพื้นที่ พร้อมแนบรูปประกอบ',
      group: 'บริการประชาชน',
      keywords: 'ร้องเรียน แจ้งเหตุ ถนน ไฟฟ้า ขยะ น้ำ ควันพิษ',
      icon: Icons.report_problem_rounded,
      color: AppColors.error,
      badge: 'ใช้งานบ่อย',
      pageBuilder: (_) =>
          const ComplainListCategory(title: 'แจ้งเหตุ / แจ้งปัญหา'),
    ),
    _ServiceItem(
      title: 'ติดตามปัญหา',
      subtitle: 'ตรวจสอบสถานะและความคืบหน้าของเรื่องที่แจ้งไว้',
      group: 'บริการประชาชน',
      keywords: 'ติดตาม สถานะ ประวัติ เรื่องร้องเรียน รายงาน',
      icon: Icons.track_changes_rounded,
      color: AppColors.primary,
      pageBuilder: (_) => const ReporterHistoryList(title: 'ติดตามปัญหา'),
    ),
    _ServiceItem(
      title: 'สิทธิประโยชน์',
      subtitle: 'ค้นหาสิทธิและบริการจากหน่วยงานที่เหมาะกับคุณ',
      group: 'บริการประชาชน',
      keywords: 'สิทธิ ประโยชน์ หน่วยงาน รัฐ บริการประชาชน',
      icon: Icons.redeem_rounded,
      color: AppColors.primary,
      pageBuilder: (_) => PrivilegeMain(title: 'สิทธิประโยชน์'),
    ),
    _ServiceItem(
      title: 'สวัสดิการชาวโคราช',
      subtitle: 'ข้อมูลความช่วยเหลือ ผู้สูงอายุ ผู้พิการ และสุขภาพ',
      group: 'บริการประชาชน',
      keywords: 'สวัสดิการ ช่วยเหลือ ผู้สูงอายุ ผู้พิการ สุขภาพ เงินอุดหนุน',
      icon: Icons.volunteer_activism_rounded,
      color: AppColors.primaryBright,
      pageBuilder: (_) => const WelfareListPage(),
    ),
    _ServiceItem(
      title: 'แบบสำรวจความคิดเห็น',
      subtitle: 'ร่วมตอบแบบสำรวจและแสดงความคิดเห็นต่อบริการจังหวัด',
      group: 'บริการประชาชน',
      keywords: 'แบบสำรวจ โหวต คะแนน ความคิดเห็น poll vote',
      icon: Icons.how_to_vote_rounded,
      color: AppColors.primary,
      pageBuilder: (_) => PollList(title: 'แบบสำรวจความคิดเห็น'),
    ),
    _ServiceItem(
      title: 'ถาม - ตอบ',
      subtitle: 'ค้นหาคำตอบหรือส่งคำถามเกี่ยวกับบริการต่าง ๆ',
      group: 'บริการประชาชน',
      keywords: 'ถาม ตอบ คำถาม ติดต่อ สอบถาม help faq',
      icon: Icons.forum_rounded,
      color: AppColors.info,
      pageBuilder: (_) => QuestionList(title: 'ถาม - ตอบ'),
    ),
    _ServiceItem(
      title: 'หลักสูตรอบรม',
      subtitle: 'ค้นหาหลักสูตรพัฒนาทักษะและกิจกรรมฝึกอบรม',
      group: 'บริการประชาชน',
      keywords: 'หลักสูตร อบรม เรียน สมัคร ทักษะ training course',
      icon: Icons.school_rounded,
      color: AppColors.primaryBright,
      pageBuilder: (_) => TrainingCourseList(title: 'หลักสูตรอบรม'),
    ),
    _ServiceItem(
      title: 'ข่าวประชาสัมพันธ์',
      subtitle: 'ข่าวสารและประกาศล่าสุดจากจังหวัดนครราชสีมา',
      group: 'ข้อมูลข่าวสาร',
      keywords: 'ข่าว ประชาสัมพันธ์ ประกาศ จังหวัด ล่าสุด',
      icon: Icons.campaign_rounded,
      color: AppColors.primary,
      badge: 'อัปเดต',
      pageBuilder: (_) => NewsList(title: 'ข่าวประชาสัมพันธ์'),
    ),
    _ServiceItem(
      title: 'ปฏิทินกิจกรรม',
      subtitle: 'ดูกิจกรรม งานเทศกาล และกำหนดการที่กำลังจะมาถึง',
      group: 'ข้อมูลข่าวสาร',
      keywords: 'ปฏิทิน กิจกรรม งาน เทศกาล วัน เวลา event calendar',
      icon: Icons.event_rounded,
      color: AppColors.primaryBright,
      pageBuilder: (_) => EventCalendarList(title: 'ปฏิทินกิจกรรม'),
    ),
    _ServiceItem(
      title: 'คลังความรู้',
      subtitle: 'บทความ คู่มือ เอกสาร และข้อมูลที่เป็นประโยชน์',
      group: 'ข้อมูลข่าวสาร',
      keywords: 'ความรู้ คู่มือ เอกสาร บทความ pdf ดาวน์โหลด',
      icon: Icons.menu_book_rounded,
      color: AppColors.info,
      pageBuilder: (_) => const KnowledgeList(title: 'คลังความรู้'),
    ),
    _ServiceItem(
      title: 'การแจ้งเตือน',
      subtitle: 'รวมข่าวสำคัญ สถานะบริการ และรายการที่ยังไม่อ่าน',
      group: 'ข้อมูลข่าวสาร',
      keywords: 'แจ้งเตือน notification ข่าว สถานะ อ่านแล้ว',
      icon: Icons.notifications_active_rounded,
      color: AppColors.error,
      pageBuilder: (_) => const NotificationList(title: 'การแจ้งเตือน'),
    ),
    _ServiceItem(
      title: 'แหล่งท่องเที่ยว',
      subtitle: 'ค้นหาสถานที่ท่องเที่ยวในโคราชทั้งแบบรายการและแผนที่',
      group: 'ท่องเที่ยวและชุมชน',
      keywords: 'เที่ยว สถานที่ แผนที่ โคราช เขาใหญ่ วัด ย่าโม poi map',
      icon: Icons.travel_explore_rounded,
      color: AppColors.primary,
      badge: 'แผนที่',
      pageBuilder: (_) => const PoiList(title: 'แหล่งท่องเที่ยว'),
    ),
    _ServiceItem(
      title: 'สินค้า OTOP',
      subtitle: 'เลือกซื้อสินค้าชุมชน ของดีโคราช และชำระผ่าน QR',
      group: 'ท่องเที่ยวและชุมชน',
      keywords: 'สินค้า ชุมชน otop ซื้อ ตะกร้า qr ของฝาก',
      icon: Icons.storefront_rounded,
      color: AppColors.primaryBright,
      pageBuilder: (_) => const OtopProductListPage(),
    ),
    _ServiceItem(
      title: 'เบอร์ฉุกเฉิน',
      subtitle: 'ค้นหาและโทรติดต่อหน่วยงานช่วยเหลือได้ทันที',
      group: 'ติดต่อและช่วยเหลือ',
      keywords: 'ฉุกเฉิน โทรศัพท์ ติดต่อ 191 199 1669 โรงพยาบาล ตำรวจ',
      icon: Icons.phone_in_talk_rounded,
      color: AppColors.error,
      badge: 'เร่งด่วน',
      pageBuilder: (_) => ContactList(title: 'เบอร์ฉุกเฉิน', code: 'emergency'),
    ),
    _ServiceItem(
      title: 'เกี่ยวกับ Korat Connect',
      subtitle: 'ข้อมูลโครงการ ช่องทางติดต่อ และที่ตั้งหน่วยงาน',
      group: 'ติดต่อและช่วยเหลือ',
      keywords: 'เกี่ยวกับเรา โครงการ ติดต่อ ที่อยู่ หน่วยงาน korat connect',
      icon: Icons.info_rounded,
      color: AppColors.info,
      pageBuilder: (_) => const AboutUsForm(title: 'เกี่ยวกับ Korat Connect'),
    ),
  ];

  List<String> get _groups => const [
        'ทั้งหมด',
        'บริการประชาชน',
        'ข้อมูลข่าวสาร',
        'ท่องเที่ยวและชุมชน',
        'ติดต่อและช่วยเหลือ',
      ];

  List<_ServiceItem> get _filteredServices {
    final query = _searchController.text.trim().toLowerCase();
    return _services.where((item) {
      final matchesGroup =
          _selectedGroup == 'ทั้งหมด' || item.group == _selectedGroup;
      final searchable =
          '${item.title} ${item.subtitle} ${item.group} ${item.keywords}'
              .toLowerCase();
      return matchesGroup && (query.isEmpty || searchable.contains(query));
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openService(_ServiceItem item) {
    FocusScope.of(context).unfocus();
    Navigator.push(context, MaterialPageRoute(builder: item.pageBuilder));
  }

  @override
  Widget build(BuildContext context) {
    final services = _filteredServices;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const KoratAppBar(
        title: 'ค้นหาบริการ',
        subtitle: 'กดเลือกเพื่อเข้าใช้งานได้ทันที',
      ),
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            sliver: SliverToBoxAdapter(
                // child: _DirectoryIntro(serviceCount: _services.length),
                ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: _SearchField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                onClear: () {
                  _searchController.clear();
                  setState(() {});
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: _GroupFilter(
              groups: _groups,
              selectedGroup: _selectedGroup,
              onSelected: (value) => setState(() => _selectedGroup = value),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'บริการในแอป',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${services.length} รายการ',
                      style: const TextStyle(
                        fontFamily: 'Sarabun',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (services.isEmpty)
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 120),
              sliver: SliverToBoxAdapter(
                child: KoratStateView(
                  state: KoratViewState.empty,
                  title: 'ไม่พบบริการ',
                  message: 'ลองค้นหาด้วยคำอื่น หรือเลือกหมวดทั้งหมด',
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                100 + MediaQuery.paddingOf(context).bottom,
              ),
              sliver: SliverList.separated(
                itemCount: services.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = services[index];
                  return _ServiceCard(
                    item: item,
                    onOpen: () => _openService(item),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ServiceItem {
  const _ServiceItem({
    required this.title,
    required this.subtitle,
    required this.group,
    required this.keywords,
    required this.icon,
    required this.color,
    required this.pageBuilder,
    this.badge,
  });

  final String title;
  final String subtitle;
  final String group;
  final String keywords;
  final IconData icon;
  final Color color;
  final WidgetBuilder pageBuilder;
  final String? badge;
}

class _DirectoryIntro extends StatelessWidget {
  const _DirectoryIntro({required this.serviceCount});

  final int serviceCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primarySoft, AppColors.surfaceWarm],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.apps_rounded,
              color: AppColors.primary,
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'รวมบริการ Korat Connect',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$serviceCount บริการ ค้นหาแล้วกดเข้าใช้งานได้เลย',
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

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      cursorColor: AppColors.primary,
      style: const TextStyle(fontFamily: 'Kanit', fontSize: 14),
      decoration: InputDecoration(
        hintText: 'ค้นหา เช่น แจ้งปัญหา, ท่องเที่ยว, OTOP',
        prefixIcon:
            const Icon(Icons.manage_search_rounded, color: AppColors.primary),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'ล้างการค้นหา',
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              ),
      ),
    );
  }
}

class _GroupFilter extends StatelessWidget {
  const _GroupFilter({
    required this.groups,
    required this.selectedGroup,
    required this.onSelected,
  });

  final List<String> groups;
  final String selectedGroup;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: groups.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final group = groups[index];
          final selected = group == selectedGroup;
          return ChoiceChip(
            selected: selected,
            showCheckmark: false,
            label: Text(group),
            onSelected: (_) => onSelected(group),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            side: BorderSide(
              color: selected ? AppColors.primary : AppColors.border,
            ),
            labelStyle: TextStyle(
              fontFamily: 'Sarabun',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.surface : AppColors.textSecondary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          );
        },
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.item, required this.onOpen});

  final _ServiceItem item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(item.icon, color: item.color, size: 27),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (item.badge != null) ...[
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: item.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.badge!,
                              style: TextStyle(
                                fontFamily: 'Sarabun',
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: item.color,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Sarabun',
                        fontSize: 12,
                        height: 1.35,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.group,
                      style: TextStyle(
                        fontFamily: 'Sarabun',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: item.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primary,
                  size: 19,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
