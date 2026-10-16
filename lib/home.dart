// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ratchasima/apptheme.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ratchasima/component/carousel_rotation.dart';
import 'package:ratchasima/component/blurred_network_image.dart';
import 'package:ratchasima/component/korat_ui.dart';
import 'package:ratchasima/pages/complain/complain_detail.dart';
import 'package:ratchasima/pages/contact/contact_list.dart';
import 'package:ratchasima/pages/event_calendar/event_calendar_list.dart';
import 'package:ratchasima/pages/knowledge/knowledge_list.dart';
import 'package:ratchasima/pages/news/news_form.dart';

import 'package:ratchasima/pages/otop_product_list.dart';
import 'package:ratchasima/pages/poi/poi_list.dart';
import 'package:ratchasima/pages/privilege/privilege_main.dart';
import 'package:ratchasima/pages/travel_list.dart';

import 'package:ratchasima/pages/welfare_list.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import 'component/carousel_banner.dart';
import 'component/carousel_form.dart';
import 'component/link_url_in.dart';
import 'login.dart';

import 'pages/blank_page/toast_fail.dart';
import 'pages/main_popup/dialog_main_popup.dart';

import 'pages/news/news_list.dart';
import 'shared/api_provider.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  HomePage({super.key, this.changePage});

  Function? changePage;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final storage = const FlutterSecureStorage();
  DateTime? currentBackPressTime;

  Future<dynamic>? _futureBanner = Future.value();
  Future<dynamic>? _futureNews = Future.value();
  Future<dynamic>? _futureRotation = Future.value();

  Future<dynamic>? _futureProfile;

  Future<dynamic>? _futureMainPopUp;

  String profileCode = '';
  String currentLocation = '-';
  final seen = <String>{};
  List unique = [];
  List imageLv0 = [];

  bool notShowOnDay = false;
  bool hiddenMainPopUp = false;
  bool checkDirection = false;

  final RefreshController _refreshController = RefreshController(
      initialRefresh: false,
      initialRefreshStatus: RefreshStatus.idle,
      initialLoadStatus: LoadStatus.idle);

  LatLng latLng = const LatLng(13.743989326935178, 100.53754006134743);

  int _currentNewsPage = 0;
  final int _newsLimit = 4;
  List<dynamic> _newsList = [];
  bool _hasMoreNews = true;

  @override
  void initState() {
    _newsList = [];
    _read();
    currentBackPressTime = DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: WillPopScope(
        child: _buildBackground(),
        onWillPop: confirmExit,
      ),
    );
  }

  Future<bool> confirmExit() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      toastFail(
        context,
        text: 'กดอีกครั้งเพื่อออก',
        color: Colors.black,
        fontColor: Colors.white,
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  _buildBackground() {
    return Container(
      child: _buildNotificationListener(),
    );
  }

  _buildNotificationListener() {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (OverscrollIndicatorNotification overScroll) {
        overScroll.disallowIndicator();
        return false;
      },
      child: _buildSmartRefresher(),
    );
  }

  _buildSmartRefresher() {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: const ClassicHeader(),
      footer: const ClassicFooter(),
      physics:
          const ClampingScrollPhysics(), // เปลี่ยนจาก BouncingScrollPhysics
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(),
            _buildQuickAccess(),
            const SizedBox(height: KoratSpacing.sm),
            _buildCurrentEventCard(),
            const SizedBox(height: KoratSpacing.lg),
            _buildRotation(),
            const SizedBox(height: KoratSpacing.xl),
            _buildService(),
            const SizedBox(height: KoratSpacing.xl),
            _buildNews(),
            const SizedBox(height: KoratSpacing.xl),
            _buildTravel(context),
            const SizedBox(height: KoratSpacing.xxl),
          ],
        ),
      ),
    );
  }

  _buildHeader() {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.5,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            height: screenHeight * 0.45,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: _buildBanner(),
            ),
          ),
          Positioned(
            top: screenHeight * 0.45 - 45,
            left: 12,
            right: 12,
            child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PoiList(
                        title: '',
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 75,
                  decoration: BoxDecoration(
                    // gradient: const LinearGradient(
                    //   begin: Alignment.topLeft,
                    //   end: Alignment.bottomRight,
                    //   colors: [
                    //     AppColors.primary,
                    //     AppColors.primaryBright,
                    //     AppColors.primarySoft
                    //   ],
                    //   stops: [0.0, 0.5, 1.0],
                    // ),
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: AppColors.primaryBright,
                    //     blurRadius: 12,
                    //     offset: const Offset(0, 6),
                    //     spreadRadius: 2,
                    //   ),
                    //   BoxShadow(
                    //     color: Colors.black.withOpacity(0.08),
                    //     blurRadius: 8,
                    //     offset: const Offset(0, 2),
                    //   ),
                    // ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_pin,
                        color: Colors.white,
                        size: 35,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'แหล่งท่องเที่ยว',
                        style: const TextStyle(
                          // fontFamily: 'Charmonman',
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }

  _buildQuickAccess() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KoratSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickAccessCard(
              icon: Icons.assignment_outlined,
              title: 'สินค้า OTOP',
              subtitle: 'ของดีเมืองโคราช',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OtopProductListPage(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: KoratSpacing.md),
          Expanded(
            child: _buildQuickAccessCard(
              icon: Icons.wallet_giftcard_sharp,
              title: 'สวัสดิการ',
              subtitle: 'สิทธิและความช่วยเหลือ',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WelfareListPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.primaryBright,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: KoratSpacing.xs),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontFamily: 'Kanit',
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentEventCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KoratSpacing.md),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.22),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(width: 5, height: 72, color: AppColors.error),
                  const SizedBox(width: 10),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset('assets/logo/event.png'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(99)),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _UrgentPulseDot(),
                                      SizedBox(width: 5),
                                      Text(
                                        'ด่วน',
                                        style: TextStyle(
                                          fontFamily: 'Sarabun',
                                          fontSize: 11,
                                          height: 1.1,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 7),
                              const Text(
                                'กิจกรรมช่วงนี้',
                                style: TextStyle(
                                  fontFamily: 'Sarabun',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'ฉีดวัคซีนไข้หวัดใหญ่ฟรี • รพ.สต. ใกล้บ้าน',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Sarabun',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 1),
                          const Text(
                            'เริ่ม 1 ก.ย. 2569 • สิ้นสุด 30 ก.ย. 2569',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Sarabun',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeSectionHeader({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0XFF27544F),
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ดูทั้งหมด', style: TextStyle(fontSize: 12)),
                Icon(Icons.chevron_right, size: 17),
              ],
            ),
          ),
      ],
    );
  }

  _buildBanner() {
    return CarouselRotation(
      model: _futureBanner,
      blurOverflow: false,
      nav: (String path, String action, dynamic model, String code) {
        if (action == 'out') {
          launchUrl(Uri.parse(path));
        } else if (action == 'in') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CarouselForm(
                code: code,
                model: model,
                url: mainBannerApi,
                urlGallery: bannerGalleryApi,
              ),
            ),
          );
        }
      },
    );
  }

  _buildRotation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KoratSpacing.md),
      child: CarouselBanner(
        model: _futureRotation,
        blurOverflow: false,
        nav: (String path, String action, dynamic model, String code,
            String urlGallery) {
          if (action == 'out') {
            launchInWebViewWithJavaScript(path);
          } else if (action == 'in') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CarouselForm(
                  code: code,
                  model: model,
                  url: mainBannerApi,
                  urlGallery: bannerGalleryApi,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  _buildNews() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KoratSpacing.md),
      child: Column(
        children: [
          _buildHomeSectionHeader(
            icon: Icons.newspaper_rounded,
            title: 'ข่าวประกาศ',
            subtitle: 'ติดตามข่าวสารล่าสุดจากจังหวัด',
            onSeeAll: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsList(
                    title: 'ข่าวประชาสัมพันธ์',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: KoratSpacing.sm),
          SizedBox(
            height: 190,
            child: FutureBuilder(
              future: _futureNews,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data.isEmpty) {
                  return const Center(
                    child: Text('ไม่มีข่าวประกาศ'),
                  );
                } else {
                  final newsList = snapshot.data;
                  return ListView.builder(
                    physics: const ClampingScrollPhysics(), // เพิ่ม physics
                    scrollDirection: Axis.horizontal,
                    itemCount: newsList.length,
                    itemBuilder: (context, index) {
                      final newsItem = newsList[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewsForm(
                                url: newsItem['url'] ?? '',
                                code: newsItem['code'] ?? '',
                                model: newsItem,
                                urlComment: newsApi,
                                urlGallery: newsGalleryApi,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.62,
                            margin:
                                const EdgeInsets.only(right: KoratSpacing.md),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.15),
                                  blurRadius: 4,
                                  offset: const Offset(4, 0),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.12,
                                    width: double.infinity,
                                    child: BlurredNetworkImage(
                                      imageUrl: '${newsItem['imageUrl'] ?? ''}',
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      (newsItem['title'] ?? '').toString(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Kanit',
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }

  _buildService() {
    final List<Map<String, dynamic>> serviceItems = [
      {
        'path': 'assets/icons/icon_menu3.png',
        'title': 'สิทธิประโยชน์',
        'callBack': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrivilegeMain(
                title: 'สิทธิประโยชน์',
              ),
            ),
          );
        },
      },
      {
        'path': 'assets/icons/calendar_icon.png',
        'title': 'ปฏิทินกิจกรรม',
        'callBack': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventCalendarList(
                title: 'ปฏิทินกิจกรรม',
              ),
            ),
          );
        },
      },
      {
        'path': 'assets/icons/icon_menu5.png',
        'title': 'คลังความรู้',
        'callBack': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KnowledgeList(
                title: 'คลังความรู้',
              ),
            ),
          );
        },
      },
      {
        'path': 'assets/icons/icon_menu8.png',
        'title': 'เบอร์ฉุกเฉิน',
        'callBack': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContactList(
                title: 'เบอร์ฉุกเฉิน',
                code: 'emergency',
              ),
            ),
          );
        },
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: KoratSpacing.md),
          child: const Text(
            'บริการสมาชิก',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: KoratSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: KoratSpacing.md),
          child: GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: KoratSpacing.sm,
              mainAxisSpacing: KoratSpacing.sm,
              childAspectRatio: 0.88,
            ),
            itemCount: serviceItems.length,
            itemBuilder: (context, index) {
              return _buildServiceIcon(
                path: serviceItems[index]['path'],
                title: serviceItems[index]['title'],
                callBack: serviceItems[index]['callBack'],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceIcon({
    required String path,
    required String title,
    required VoidCallback callBack,
  }) {
    return InkWell(
      onTap: callBack,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(KoratSpacing.sm),
              child: Image.asset(
                path,
                color: AppColors.primary,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: KoratSpacing.xs),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w400,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  _buildEmergencySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Text(
              'เบอร์ฉุกเฉิน',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Kanit',
                fontWeight: FontWeight.w500,
                color: Color(0xFFC9166D),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Material(
                  elevation: 0,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      launchUrl(Uri.parse('tel:191'));
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFf44336), Color(0xFFef5350)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFf44336).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_police,
                              color: Colors.white, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'ตำรวจ 191',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Material(
                  elevation: 0,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      launchUrl(Uri.parse('tel:199'));
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFff5722), Color(0xFFff7043)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFff5722).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_fire_department,
                              color: Colors.white, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'ดับเพลิง 199',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Material(
                  elevation: 0,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      launchUrl(Uri.parse('tel:1669'));
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.medical_services,
                              color: Colors.white, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'แพทย์ฉุกเฉิน 1669',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Material(
                  elevation: 0,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ComplainDetail()),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF607D8B), Color(0xFF78909C)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF607D8B).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.report_problem,
                              color: Colors.white, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'แจ้งปัญหา',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  final List<Map<String, String>> nakhonRatchasimaTravelPlaces = [
    {
      'name': 'อนุสาวรีย์ท้าวสุรนารี (ย่าโม)',
      'location': 'อำเภอเมืองนครราชสีมา จังหวัดนครราชสีมา',
      'review': '⭐ แลนด์มาร์กคู่เมืองโคราช',
      'imageUrl':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQQUT9JighyBOtliJaqTNa_tNPSv0jWYsDtGfCKuMMquOHppchvWrRzldw&s=10',
      'url':
          'https://www.google.com/maps/search/?api=1&query=14.974193,102.097966',
      'description':
          'จุดสักการะท้าวสุรนารี วีรสตรีของชาวโคราช ตั้งอยู่ใจกลางเมือง ใกล้ย่านการค้าและประตูชุมพล',
      'category': 'ประวัติศาสตร์',
      'distance': 'ใจกลางเมือง',
    },
    {
      'name': 'ประตูชุมพล',
      'location': 'อำเภอเมืองนครราชสีมา จังหวัดนครราชสีมา',
      'review': '⭐ จุดถ่ายรูปยอดนิยมใจกลางเมือง',
      'imageUrl':
          'https://cms.dmpcdn.com/travel/2022/06/29/ad3fb0c0-f766-11ec-99fd-db3af2a5f38c_webp_original.jpg',
      'url':
          'https://www.google.com/maps/search/?api=1&query=14.974594,102.097158',
      'description':
          'ประตูเมืองเก่าแก่ที่เป็นสัญลักษณ์ของนครราชสีมา อยู่ติดกับลานย่าโม เหมาะกับการเดินชมเมืองเก่า',
      'category': 'ประวัติศาสตร์',
      'distance': 'ใกล้อนุสาวรีย์ย่าโม',
    },
    {
      'name': 'วัดศาลาลอย',
      'location': 'อำเภอเมืองนครราชสีมา จังหวัดนครราชสีมา',
      'review': '⭐ วัดสำคัญและสถาปัตยกรรมเด่นของโคราช',
      'imageUrl':
          'https://nkr.mcu.ac.th/tour/wp-content/uploads/2015/03/I-San-in-The-Rain_83.jpg',
      'url':
          'https://www.google.com/maps/search/?api=1&query=14.982028,102.116126',
      'description':
          'วัดเก่าแก่ริมลำตะคอง มีอุโบสถรูปเรือสำเภาและบรรยากาศสงบ เหมาะกับการไหว้พระและพักใจ',
      'category': 'วัดและศาสนา',
      'distance': 'ประมาณ 4 กม. จากลานย่าโม',
    },
    {
      'name': 'อุทยานแห่งชาติเขาใหญ่',
      'location': 'อำเภอปากช่อง จังหวัดนครราชสีมา',
      'review': '⭐ แหล่งธรรมชาติยอดนิยมของโคราช',
      'imageUrl':
          'https://my.kapook.com/imagescontent/fb_img/772/s_110442_7165.jpg',
      'url':
          'https://www.google.com/maps/search/?api=1&query=14.439232,101.372508',
      'description':
          'ผืนป่ามรดกโลกที่มีเส้นทางศึกษาธรรมชาติ จุดชมวิว น้ำตก และอากาศเย็นสบายตลอดปี',
      'category': 'ธรรมชาติ',
      'distance': 'อำเภอปากช่อง',
    },
    {
      'name': 'ฟาร์มโชคชัย',
      'location': 'อำเภอปากช่อง จังหวัดนครราชสีมา',
      'review': '⭐ แหล่งท่องเที่ยวสำหรับครอบครัว',
      'imageUrl':
          'https://img.salehere.co.th/p/600x0/2022/07/06/dy4spmdfpmbi.jpg',
      'url':
          'https://www.google.com/maps/search/?api=1&query=14.657847,101.348875',
      'description':
          'ฟาร์มโคนมและแหล่งท่องเที่ยวเชิงเกษตร มีกิจกรรมเรียนรู้ เหมาะกับครอบครัวและเด็ก ๆ',
      'category': 'ครอบครัว',
      'distance': 'อำเภอปากช่อง',
    },
    {
      'name': 'อ่างเก็บน้ำลำตะคอง',
      'location': 'อำเภอสีคิ้ว จังหวัดนครราชสีมา',
      'review': '⭐ จุดชมวิวธรรมชาติและพระอาทิตย์ตก',
      'imageUrl':
          'https://cms.dmpcdn.com/travel/2020/06/10/51ac4e40-ab0e-11ea-b79d-0ddf2d8ccf90_original.jpg',
      'url':
          'https://www.google.com/maps/search/?api=1&query=14.802022,101.585233',
      'description':
          'อ่างเก็บน้ำขนาดใหญ่ท่ามกลางภูเขา เป็นจุดพักผ่อน ชมวิว และแวะถ่ายรูปยอดนิยมบนเส้นทางมิตรภาพ',
      'category': 'ธรรมชาติ',
      'distance': 'อำเภอสีคิ้ว',
    },
    {
      'name': 'วัดบ้านไร่',
      'location': 'อำเภอด่านขุนทด จังหวัดนครราชสีมา',
      'review': '⭐ วัดสวยและงานศิลปะร่วมสมัย',
      'imageUrl': 'https://img.thaicdn.net/u/2019/supattra_wat/watt/wat2.jpg',
      'url':
          'https://www.google.com/maps/search/?api=1&query=15.216413,101.771731',
      'description':
          'วัดชื่อดังของหลวงพ่อคูณ โดดเด่นด้วยหอเทพวิทยาคมและงานศิลปะที่เล่าเรื่องพุทธศาสนาอย่างร่วมสมัย',
      'category': 'วัดและศาสนา',
      'distance': 'อำเภอด่านขุนทด',
    },
    {
      'name': 'สวนสัตว์นครราชสีมา',
      'location': 'อำเภอเมืองนครราชสีมา จังหวัดนครราชสีมา',
      'review': '⭐ เที่ยวสนุกสำหรับครอบครัว',
      'imageUrl':
          'https://img.wongnai.com/p/1600x0/2021/12/12/8c2713da5fea4bccb147c2348a10782f.jpg',
      'url':
          'https://www.google.com/maps/search/?api=1&query=14.853152,102.089157',
      'description':
          'สวนสัตว์ขนาดใหญ่ของโคราช มีสัตว์หลากหลาย โซนเรียนรู้ และพื้นที่กิจกรรมสำหรับเด็กและครอบครัว',
      'category': 'ครอบครัว',
      'distance': 'ประมาณ 20 กม. จากตัวเมือง',
    }
  ];

  Widget _buildTravel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KoratSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHomeSectionHeader(
            icon: Icons.explore_rounded,
            title: 'ท่องเที่ยวยอดนิยม',
            subtitle: 'สถานที่น่าเที่ยวและจุดเช็กอิน',
            onSeeAll: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TravelPlacesList(
                    title: 'สถานที่ท่องเที่ยวยอดนิยม',
                    places: nakhonRatchasimaTravelPlaces,
                  ),
                ),
              );
            },
          ),
          SizedBox(
            height: 270,
            child: Padding(
              padding: const EdgeInsets.only(top: KoratSpacing.xs),
              child: ListView.builder(
                physics: const ClampingScrollPhysics(), // เพิ่ม physics
                scrollDirection: Axis.horizontal,
                itemCount: nakhonRatchasimaTravelPlaces.length,
                itemBuilder: (context, index) {
                  final place = nakhonRatchasimaTravelPlaces[index];
                  return InkWell(
                    onTap: () async {
                      try {
                        final uri = Uri.parse(Uri.encodeFull(place['url']!));
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ไม่สามารถเปิดลิงก์ได้'),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('เกิดข้อผิดพลาดในการเปิดลิงก์'),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 250,
                      width: MediaQuery.of(context).size.width * 0.62,
                      margin: const EdgeInsets.only(right: KoratSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.15),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: SizedBox(
                              height: 126,
                              width: double.infinity,
                              child: BlurredNetworkImage(
                                imageUrl: '${place['imageUrl'] ?? ''}',
                                width: double.infinity,
                                height: 126,
                                placeholder:
                                    const _HomeTravelImagePlaceholder(),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    place['name']!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 12,
                                        color: Color(0xFF666666),
                                      ),
                                      const SizedBox(width: 2),
                                      Expanded(
                                        child: Text(
                                          place['location']!,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontFamily: 'Kanit',
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF666666),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    place['review']!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF27544F),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (place.containsKey('description') &&
                                      place['description']!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        place['description']!,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontFamily: 'Kanit',
                                          fontWeight: FontWeight.w300,
                                          color: Color(0xFF888888),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  _read() async {
    _getLocation();

    _futureBanner = postDio('${mainBannerApi}read', {
      'skip': 0,
      'limit': 10,
    });
    _futureNews = postDio('${newsApi}read', {
      'skip': _currentNewsPage * _newsLimit,
      'limit': _newsLimit,
    });
    _futureRotation = postDio('${rotationApi}read', {
      'skip': 0,
      'limit': 10,
    });

    _futureMainPopUp = postDio('${mainPopupHomeApi}read', {'limit': 10});

    profileCode = await storage.read(key: 'profileCode2') ?? '';
    if (profileCode != '') {
      setState(() {
        _futureProfile = postDio(profileReadApi, {"code": profileCode});
      });
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _onLoading() async {
    if (!_hasMoreNews) {
      _refreshController.loadComplete();
      return;
    }
    _currentNewsPage++;
    final moreNews = await postDio('${newsApi}read', {
      'skip': _currentNewsPage * _newsLimit,
      'limit': _newsLimit,
    });
    if (moreNews != null && moreNews.length < _newsLimit) {
      _hasMoreNews = false;
    }
    if (moreNews == null || moreNews.isEmpty) {
      _hasMoreNews = false;
      _refreshController.loadNoData();
      return;
    }
    setState(() {
      if (_newsList.isEmpty) {
        _newsList = moreNews;
      } else {
        _newsList.addAll(moreNews);
      }
    });
    _refreshController.loadComplete();
  }

  void _onRefresh() async {
    _currentNewsPage = 0;
    _hasMoreNews = true;

    try {
      var newsData = await postDio('${newsApi}read', {
        'skip': 0,
        'limit': _newsLimit,
        'app': 'marine',
      });

      setState(() {
        _newsList = newsData ?? [];
        print("รีเฟรชข้อมูลเสร็จสิ้น: ${_newsList.length} รายการ");
      });

      if (newsData == null || newsData.length < _newsLimit) {
        _hasMoreNews = false;
      }
    } catch (e) {
      print("เกิดข้อผิดพลาดในการรีเฟรช: $e");
    }

    _refreshController.refreshCompleted();
  }

  getMainPopUp() async {
    var result =
        await post('${mainPopupHomeApi}read', {'skip': 0, 'limit': 100});

    if (result.length > 0) {
      var valueStorage = await storage.read(key: 'mainPopupDDPM');
      var dataValue;
      if (valueStorage != null) {
        dataValue = json.decode(valueStorage);
      } else {
        dataValue = null;
      }

      var now = new DateTime.now();
      DateTime date = new DateTime(now.year, now.month, now.day);

      if (dataValue != null) {
        var index = dataValue.indexWhere(
          (c) =>
              c['date'].toString() ==
                  DateFormat("ddMMyyyy").format(date).toString() &&
              c['boolean'] == "true",
        );

        if (index == -1) {
          this.setState(() {
            hiddenMainPopUp = false;
          });
          return showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) {
              return WillPopScope(
                onWillPop: () {
                  return Future.value(false);
                },
                child: MainPopupDialog(
                  model: _futureMainPopUp!,
                  type: 'mainPopup',
                ),
              );
            },
          );
        } else {
          this.setState(() {
            hiddenMainPopUp = true;
          });
        }
      } else {
        this.setState(() {
          hiddenMainPopUp = false;
        });
        return showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) {
            return WillPopScope(
              onWillPop: () {
                return Future.value(false);
              },
              child: MainPopupDialog(
                model: _futureMainPopUp!,
                type: 'mainPopup',
              ),
            );
          },
        );
      }
    }
  }

  _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print(
            'Location permissions are permanently denied, we cannot request permissions.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        latLng = LatLng(position.latitude, position.longitude);
        currentLocation = placemarks.first.administrativeArea ?? 'Unknown';
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }
}

class _UrgentPulseDot extends StatefulWidget {
  const _UrgentPulseDot();

  @override
  State<_UrgentPulseDot> createState() => _UrgentPulseDotState();
}

class _UrgentPulseDotState extends State<_UrgentPulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _opacity = Tween<double>(begin: 0.35, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 14,
      child: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeTravelImagePlaceholder extends StatelessWidget {
  const _HomeTravelImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceWarm,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.landscape_rounded,
              color: AppColors.primary,
              size: 30,
            ),
            SizedBox(height: 4),
            Text(
              'รอเพิ่มรูป',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontFamily: 'Kanit',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
