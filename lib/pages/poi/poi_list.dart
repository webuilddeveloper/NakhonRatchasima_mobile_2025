import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../apptheme.dart';
import '../../component/blurred_network_image.dart';
import '../../component/korat_ui.dart';
import 'poi_form.dart';

class PoiList extends StatefulWidget {
  const PoiList({super.key, this.title, this.latLng});

  final String? title;
  final LatLng? latLng;

  @override
  State<PoiList> createState() => _PoiListState();
}

class _PoiListState extends State<PoiList> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  String _selectedCategory = '';
  String _searchQuery = '';
  bool _showMap = true;

  List<Map<String, dynamic>> get _filteredPoi {
    final query = _searchQuery.trim().toLowerCase();
    return _localKoratPoi.where((item) {
      final itemCategory = '${item['category'] ?? ''}';
      final matchesCategory =
          _selectedCategory.isEmpty || itemCategory == _selectedCategory;
      final searchable = [
        item['title'],
        item['address'],
        item['description'],
        itemCategory,
      ].whereType<String>().join(' ').toLowerCase();
      return matchesCategory && (query.isEmpty || searchable.contains(query));
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final places = _filteredPoi;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: KoratAppBar(
        title: widget.title?.trim().isNotEmpty == true
            ? widget.title!.trim()
            : 'แหล่งท่องเที่ยว',
        subtitle: '${places.length} สถานที่ในโคราช',
        showBack: true,
        onBack: () => Navigator.maybePop(context),
        actions: [
          KoratAppBarAction(
            tooltip: _showMap ? 'ดูแบบรายการ' : 'ดูบนแผนที่',
            onPressed: () => setState(() => _showMap = !_showMap),
            icon: _showMap ? Icons.view_agenda_rounded : Icons.map_outlined,
          ),
        ],
      ),
      body: _showMap ? _buildMapView(places) : _buildListView(places),
    );
  }

  Widget _buildMapView(List<Map<String, dynamic>> places) {
    return Stack(
      children: [
        Positioned.fill(child: _buildGoogleMap(places)),
        Positioned(
          top: 12,
          left: 0,
          right: 0,
          child: _FilterPanel(
            controller: _searchController,
            selectedCategory: _selectedCategory,
            onSearchChanged: _setSearch,
            onCategoryChanged: _setCategory,
          ),
        ),
        if (places.isEmpty)
          const Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: _PoiEmptyState(compact: true),
          )
        else
          Positioned(
            left: 0,
            right: 0,
            bottom: 18,
            height: 150,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: places.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final place = places[index];
                return _MapPlaceCard(
                  place: place,
                  onTap: () => _openDetail(place),
                  onFocus: () => _focusPlace(place),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildGoogleMap(List<Map<String, dynamic>> places) {
    final markers = places.map((place) {
      final position = _latLngOf(place);
      return Marker(
        markerId: MarkerId('${place['code']}'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        infoWindow: InfoWindow(
          title: '${place['title'] ?? ''}',
          snippet: '${place['category'] ?? ''}',
          onTap: () => _openDetail(place),
        ),
        onTap: () => _focusPlace(place),
      );
    }).toSet();

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.latLng ?? const LatLng(14.9742, 102.0978),
        zoom: widget.latLng == null ? 9.2 : 14,
      ),
      mapType: MapType.normal,
      markers: markers,
      compassEnabled: false,
      mapToolbarEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: (controller) {
        _mapController = controller;
        unawaited(_fitMapToResults());
      },
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> places) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: _FilterPanel(
            controller: _searchController,
            selectedCategory: _selectedCategory,
            onSearchChanged: _setSearch,
            onCategoryChanged: _setCategory,
            elevated: false,
          ),
        ),
        Expanded(
          child: places.isEmpty
              ? const Center(child: _PoiEmptyState())
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
                  itemCount: places.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _PoiListCard(
                    place: places[index],
                    onTap: () => _openDetail(places[index]),
                  ),
                ),
        ),
      ],
    );
  }

  void _setSearch(String value) {
    setState(() => _searchQuery = value);
    unawaited(_fitMapToResults());
  }

  void _setCategory(String value) {
    setState(() => _selectedCategory = value);
    unawaited(_fitMapToResults());
  }

  Future<void> _focusPlace(Map<String, dynamic> place) async {
    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _latLngOf(place), zoom: 14.5),
      ),
    );
  }

  Future<void> _fitMapToResults() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final controller = _mapController;
    final places = _filteredPoi;
    if (!mounted || controller == null || !_showMap || places.isEmpty) return;

    if (places.length == 1) {
      await _focusPlace(places.first);
      return;
    }

    var minLat = 90.0;
    var maxLat = -90.0;
    var minLng = 180.0;
    var maxLng = -180.0;
    for (final place in places) {
      final point = _latLngOf(place);
      minLat = point.latitude < minLat ? point.latitude : minLat;
      maxLat = point.latitude > maxLat ? point.latitude : maxLat;
      minLng = point.longitude < minLng ? point.longitude : minLng;
      maxLng = point.longitude > maxLng ? point.longitude : maxLng;
    }

    try {
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          76,
        ),
      );
    } catch (_) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(const LatLng(14.9742, 102.0978), 9.2),
      );
    }
  }

  void _openDetail(Map<String, dynamic> place) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PoiForm(code: '${place['code']}', model: place),
      ),
    );
  }

  LatLng _latLngOf(Map<String, dynamic> place) {
    return LatLng(
      double.tryParse('${place['latitude']}') ?? 14.9742,
      double.tryParse('${place['longitude']}') ?? 102.0978,
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.controller,
    required this.selectedCategory,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    this.elevated = true,
  });

  final TextEditingController controller;
  final String selectedCategory;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategoryChanged;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: elevated ? 0.96 : 1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: elevated
            ? const [
                BoxShadow(
                  color: Color(0x1F282429),
                  blurRadius: 18,
                  offset: Offset(0, 7),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          TextField(
            controller: controller,
            onChanged: onSearchChanged,
            textInputAction: TextInputAction.search,
            style: const TextStyle(
              fontFamily: 'Kanit',
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'ค้นหาสถานที่ในโคราช',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'ล้างการค้นหา',
                      onPressed: () {
                        controller.clear();
                        onSearchChanged('');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              filled: true,
              fillColor: AppColors.background,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _localPoiCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = _localPoiCategories[index];
                final code = item['code']!;
                final selected = code == selectedCategory;
                return ChoiceChip(
                  selected: selected,
                  showCheckmark: false,
                  onSelected: (_) => onCategoryChanged(code),
                  label: Text(item['title']!),
                  labelStyle: TextStyle(
                    color:
                        selected ? AppColors.surface : AppColors.textSecondary,
                    fontFamily: 'Kanit',
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  backgroundColor: AppColors.background,
                  selectedColor: AppColors.primary,
                  side: BorderSide(
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PoiListCard extends StatelessWidget {
  const _PoiListCard({required this.place, required this.onTap});

  final Map<String, dynamic> place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 154,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Hero(
                tag: 'poi-${place['code']}',
                child: SizedBox(
                  width: 130,
                  height: double.infinity,
                  child: BlurredNetworkImage(
                    imageUrl: '${place['imageUrl'] ?? ''}',
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CategoryBadge(label: '${place['category'] ?? ''}'),
                      const SizedBox(height: 7),
                      Text(
                        '${place['title'] ?? ''}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 15,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      _LocationLine(address: '${place['address'] ?? ''}'),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.near_me_outlined,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _distanceLabel(place),
                              style: const TextStyle(
                                fontFamily: 'Sarabun',
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapPlaceCard extends StatelessWidget {
  const _MapPlaceCard({
    required this.place,
    required this.onTap,
    required this.onFocus,
  });

  final Map<String, dynamic> place;
  final VoidCallback onTap;
  final VoidCallback onFocus;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      elevation: 6,
      shadowColor: AppColors.textPrimary.withValues(alpha: 0.18),
      child: SizedBox(
        width: 300,
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              SizedBox(
                width: 112,
                height: double.infinity,
                child: BlurredNetworkImage(
                  imageUrl: '${place['imageUrl'] ?? ''}',
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CategoryBadge(label: '${place['category'] ?? ''}'),
                      const SizedBox(height: 7),
                      Text(
                        '${place['title'] ?? ''}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 14,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _distanceLabel(place),
                              style: const TextStyle(
                                fontFamily: 'Sarabun',
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'แสดงบนแผนที่',
                            onPressed: onFocus,
                            visualDensity: VisualDensity.compact,
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.primarySoft,
                              foregroundColor: AppColors.primary,
                            ),
                            icon:
                                const Icon(Icons.my_location_rounded, size: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.primary,
          fontFamily: 'Kanit',
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _LocationLine extends StatelessWidget {
  const _LocationLine({required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 14,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Sarabun',
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _PoiEmptyState extends StatelessWidget {
  const _PoiEmptyState({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 18 : 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: compact
            ? const [
                BoxShadow(
                  color: Color(0x1A282429),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.travel_explore_rounded,
            size: 40,
            color: AppColors.primary,
          ),
          const SizedBox(height: 10),
          const Text(
            'ไม่พบสถานที่ที่ค้นหา',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: 4),
            const Text(
              'ลองเปลี่ยนคำค้นหาหรือเลือกหมวดหมู่อื่น',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Sarabun',
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _distanceLabel(Map<String, dynamic> place) {
  final distance = double.tryParse('${place['distance'] ?? ''}');
  if (distance == null || distance <= 0) return 'ใจกลางเมืองโคราช';
  return 'ห่างประมาณ ${distance.toStringAsFixed(distance < 10 ? 1 : 0)} กม.';
}

const List<Map<String, String>> _localPoiCategories = [
  {'code': '', 'title': 'ทั้งหมด'},
  {'code': 'ประวัติศาสตร์', 'title': 'ประวัติศาสตร์'},
  {'code': 'วัดและศาสนา', 'title': 'วัดและศาสนา'},
  {'code': 'ธรรมชาติ', 'title': 'ธรรมชาติ'},
  {'code': 'ครอบครัว', 'title': 'ครอบครัว'},
];

final List<Map<String, dynamic>> _localKoratPoi = [
  {
    'code': 'korat-poi-001',
    'title': 'อนุสาวรีย์ท้าวสุรนารี (ย่าโม)',
    'category': 'ประวัติศาสตร์',
    'address': 'ถนนราชดำเนิน อำเภอเมืองนครราชสีมา จังหวัดนครราชสีมา',
    'description':
        'แลนด์มาร์กใจกลางเมืองและสถานที่สักการะท้าวสุรนารี วีรสตรีของชาวโคราช ใกล้ประตูชุมพลและย่านเมืองเก่า',
    'imageUrl':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQQUT9JighyBOtliJaqTNa_tNPSv0jWYsDtGfCKuMMquOHppchvWrRzldw&s=10',
    'latitude': '14.974193',
    'longitude': '102.097966',
    'distance': 0.0,
    'createBy': 'Korat Connect',
    'view': 245,
  },
  {
    'code': 'korat-poi-002',
    'title': 'ประตูชุมพล',
    'category': 'ประวัติศาสตร์',
    'address': 'อำเภอเมืองนครราชสีมา จังหวัดนครราชสีมา',
    'description':
        'ประตูเมืองเก่าแก่ที่เป็นสัญลักษณ์ของโคราช อยู่ติดกับลานย่าโม เหมาะกับการเดินชมเมืองและถ่ายรูป',
    'imageUrl':
        'https://cms.dmpcdn.com/travel/2022/06/29/ad3fb0c0-f766-11ec-99fd-db3af2a5f38c_webp_original.jpg',
    'latitude': '14.974594',
    'longitude': '102.097158',
    'distance': 0.1,
    'createBy': 'Korat Connect',
    'view': 198,
  },
  {
    'code': 'korat-poi-003',
    'title': 'วัดศาลาลอย',
    'category': 'วัดและศาสนา',
    'address': 'อำเภอเมืองนครราชสีมา จังหวัดนครราชสีมา',
    'description':
        'วัดเก่าแก่ริมลำตะคอง มีอุโบสถรูปเรือสำเภาและบรรยากาศสงบ เหมาะกับการไหว้พระและพักผ่อน',
    'imageUrl':
        'https://nkr.mcu.ac.th/tour/wp-content/uploads/2015/03/I-San-in-The-Rain_83.jpg',
    'latitude': '14.982028',
    'longitude': '102.116126',
    'distance': 4.0,
    'createBy': 'Korat Connect',
    'view': 172,
  },
  {
    'code': 'korat-poi-004',
    'title': 'อุทยานแห่งชาติเขาใหญ่',
    'category': 'ธรรมชาติ',
    'address': 'อำเภอปากช่อง จังหวัดนครราชสีมา',
    'description':
        'ผืนป่ามรดกโลก มีเส้นทางศึกษาธรรมชาติ จุดชมวิว น้ำตก และอากาศเย็นสบาย เหมาะกับทริปธรรมชาติ',
    'imageUrl':
        'https://my.kapook.com/imagescontent/fb_img/772/s_110442_7165.jpg',
    'latitude': '14.439232',
    'longitude': '101.372508',
    'distance': 95.0,
    'createBy': 'Korat Connect',
    'view': 351,
  },
  {
    'code': 'korat-poi-005',
    'title': 'ฟาร์มโชคชัย',
    'category': 'ครอบครัว',
    'address': 'อำเภอปากช่อง จังหวัดนครราชสีมา',
    'description':
        'ฟาร์มโคนมและแหล่งท่องเที่ยวเชิงเกษตร มีกิจกรรมเรียนรู้สำหรับเด็กและครอบครัว',
    'imageUrl':
        'https://img.salehere.co.th/p/600x0/2022/07/06/dy4spmdfpmbi.jpg',
    'latitude': '14.657847',
    'longitude': '101.348875',
    'distance': 88.0,
    'createBy': 'Korat Connect',
    'view': 210,
  },
  {
    'code': 'korat-poi-006',
    'title': 'อ่างเก็บน้ำลำตะคอง',
    'category': 'ธรรมชาติ',
    'address': 'อำเภอสีคิ้ว จังหวัดนครราชสีมา',
    'description':
        'อ่างเก็บน้ำขนาดใหญ่ท่ามกลางภูเขา เป็นจุดพักผ่อน ชมวิว และถ่ายรูปบนเส้นทางมิตรภาพ',
    'imageUrl':
        'https://cms.dmpcdn.com/travel/2020/06/10/51ac4e40-ab0e-11ea-b79d-0ddf2d8ccf90_original.jpg',
    'latitude': '14.802022',
    'longitude': '101.585233',
    'distance': 55.0,
    'createBy': 'Korat Connect',
    'view': 166,
  },
];
