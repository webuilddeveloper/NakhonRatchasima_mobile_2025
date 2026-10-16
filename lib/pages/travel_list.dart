import 'package:flutter/material.dart';
import 'package:ratchasima/apptheme.dart';
import 'package:ratchasima/component/header.dart';
import 'package:ratchasima/component/korat_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../component/blurred_network_image.dart';

class TravelPlacesList extends StatefulWidget {
  final String title;
  final List<Map<String, String>> places;

  const TravelPlacesList({
    super.key,
    required this.title,
    required this.places,
  });

  @override
  State<TravelPlacesList> createState() => _TravelPlacesListState();
}

class _TravelPlacesListState extends State<TravelPlacesList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'ทั้งหมด';

  List<String> get _categories {
    final categories = widget.places
        .map((place) => place['category'] ?? '')
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['ทั้งหมด', ...categories];
  }

  List<Map<String, String>> get _filteredPlaces {
    final query = _searchQuery.trim().toLowerCase();
    return widget.places.where((place) {
      final matchCategory = _selectedCategory == 'ทั้งหมด' ||
          place['category'] == _selectedCategory;
      final searchTarget = [
        place['name'],
        place['location'],
        place['description'],
        place['category'],
      ].whereType<String>().join(' ').toLowerCase();
      final matchSearch = query.isEmpty || searchTarget.contains(query);
      return matchCategory && matchSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchMap(Map<String, String> place) async {
    final url = _normalizeUrl(place['url'] ?? '');
    if (url.isEmpty) {
      _showSnackBar('ยังไม่มีตำแหน่งแผนที่ของสถานที่นี้');
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('ไม่สามารถเปิด Google Maps ได้');
      }
    } catch (_) {
      _showSnackBar('ลิงก์แผนที่ไม่ถูกต้อง');
    }
  }

  String _normalizeUrl(String url) {
    var value = url.trim();
    if (value.isEmpty) return '';

    // รองรับข้อมูลที่เคยวางเป็น Markdown link เช่น [url](url)
    final markdownMatch = RegExp(r'\]\((https?:\/\/[^)]+)\)').firstMatch(value);
    if (markdownMatch != null) {
      value = markdownMatch.group(1) ?? value;
    }

    value = value.replaceAll('\\', '');
    return Uri.encodeFull(value);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Sarabun'),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  void goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final places = _filteredPlaces;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: header(
        context,
        goBack,
        title: widget.title,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildSearchAndCategory(),
            Expanded(
              child: places.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        KoratSpacing.md,
                        KoratSpacing.sm,
                        KoratSpacing.md,
                        KoratSpacing.xl,
                      ),
                      itemCount: places.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: KoratSpacing.md),
                      itemBuilder: (context, index) {
                        return _TravelPlaceCard(
                          place: places[index],
                          onOpenMap: () => _launchMap(places[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndCategory() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        KoratSpacing.md,
        KoratSpacing.md,
        KoratSpacing.md,
        KoratSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            style: const TextStyle(fontFamily: 'Sarabun'),
            decoration: InputDecoration(
              hintText: 'ค้นหาชื่อสถานที่ พื้นที่ หรือประเภท',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          const SizedBox(height: KoratSpacing.sm),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final selected = category == _selectedCategory;
                return ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  labelStyle: TextStyle(
                    fontFamily: 'Sarabun',
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.surface : AppColors.textPrimary,
                  ),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.primarySoft,
                  side: BorderSide(
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: KoratSpacing.xs),
          Text(
            'พบ ${_filteredPlaces.length} สถานที่',
            style: const TextStyle(
              fontFamily: 'Sarabun',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KoratSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.travel_explore_rounded,
                color: AppColors.primary,
                size: 42,
              ),
            ),
            const SizedBox(height: KoratSpacing.md),
            const Text(
              'ไม่พบสถานที่ที่ตรงกับการค้นหา',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: KoratSpacing.xs),
            const Text(
              'ลองเปลี่ยนคำค้นหา หรือเลือกหมวดหมู่อื่น',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Sarabun',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: KoratSpacing.lg),
            OutlinedButton.icon(
              onPressed: () {
                _clearSearch();
                setState(() {
                  _selectedCategory = 'ทั้งหมด';
                });
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('แสดงทั้งหมด'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TravelPlaceCard extends StatelessWidget {
  const _TravelPlaceCard({
    required this.place,
    required this.onOpenMap,
  });

  final Map<String, String> place;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = place['imageUrl']?.trim() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: SizedBox(
              height: 176,
              width: double.infinity,
              child: BlurredNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: 176,
                placeholder: const _TravelImagePlaceholder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(KoratSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoPill(
                      icon: Icons.auto_awesome_rounded,
                      text: place['category'] ?? 'แนะนำ',
                    ),
                    if ((place['distance'] ?? '').isNotEmpty)
                      _InfoPill(
                        icon: Icons.place_rounded,
                        text: place['distance']!,
                      ),
                  ],
                ),
                const SizedBox(height: KoratSpacing.sm),
                Text(
                  place['name'] ?? '-',
                  style: const TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        place['location'] ?? '',
                        style: const TextStyle(
                          fontFamily: 'Sarabun',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                if ((place['description'] ?? '').isNotEmpty) ...[
                  const SizedBox(height: KoratSpacing.sm),
                  Text(
                    place['description']!,
                    style: const TextStyle(
                      fontFamily: 'Sarabun',
                      fontSize: 14,
                      height: 1.45,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
                const SizedBox(height: KoratSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showPlaceDetail(context),
                        icon: const Icon(Icons.info_outline_rounded, size: 18),
                        label: const Text('รายละเอียด'),
                      ),
                    ),
                    const SizedBox(width: KoratSpacing.sm),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onOpenMap,
                        icon: const Icon(Icons.map_rounded, size: 18),
                        label: const Text('เปิดแผนที่'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPlaceDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.all(KoratSpacing.md),
          padding: const EdgeInsets.all(KoratSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: KoratSpacing.lg),
                Text(
                  place['name'] ?? '-',
                  style: const TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: KoratSpacing.xs),
                Text(
                  place['location'] ?? '',
                  style: const TextStyle(
                    fontFamily: 'Sarabun',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: KoratSpacing.md),
                Text(
                  place['description'] ?? 'ยังไม่มีรายละเอียดเพิ่มเติม',
                  style: const TextStyle(
                    fontFamily: 'Sarabun',
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: KoratSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onOpenMap,
                    icon: const Icon(Icons.map_rounded),
                    label: const Text('เปิดตำแหน่งใน Google Maps'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Sarabun',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TravelImagePlaceholder extends StatelessWidget {
  const _TravelImagePlaceholder();

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
              size: 42,
              color: AppColors.primary,
            ),
            SizedBox(height: KoratSpacing.xs),
            Text(
              'รอเพิ่มรูปสถานที่',
              style: TextStyle(
                fontFamily: 'Sarabun',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
