import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart' hide Marker;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../apptheme.dart';
import '../../component/blurred_network_image.dart';
import '../../component/korat_ui.dart';

class PoiForm extends StatelessWidget {
  const PoiForm({
    super.key,
    this.url,
    this.code,
    this.model,
    this.urlComment,
    this.urlGallery,
  });

  final String? url;
  final String? code;
  final dynamic model;
  final String? urlComment;
  final String? urlGallery;

  @override
  Widget build(BuildContext context) {
    final place = Map<String, dynamic>.from(model as Map? ?? const {});
    final title = '${place['title'] ?? 'รายละเอียดสถานที่'}';
    final imageUrl = '${place['imageUrl'] ?? ''}';
    final latitude = double.tryParse('${place['latitude'] ?? ''}') ?? 14.9742;
    final longitude =
        double.tryParse('${place['longitude'] ?? ''}') ?? 102.0978;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: KoratAppBar(
        title: 'รายละเอียดสถานที่',
        subtitle: 'เที่ยวโคราช',
        showBack: true,
        onBack: () => Navigator.maybePop(context),
        actions: [
          KoratAppBarAction(
            tooltip: 'แชร์สถานที่',
            onPressed: () => _sharePlace(context, place),
            icon: Icons.ios_share_rounded,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Hero(
              tag: 'poi-${place['code'] ?? code ?? title}',
              child: SizedBox(
                height: 250,
                width: double.infinity,
                child: BlurredNetworkImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  height: 250,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
            sliver: SliverList.list(
              children: [
                Transform.translate(
                  offset: const Offset(0, -18),
                  child: _PlaceHeadline(place: place),
                ),
                _SectionCard(
                  icon: Icons.auto_awesome_rounded,
                  title: 'เกี่ยวกับสถานที่',
                  child: _Description(
                      description: '${place['description'] ?? ''}'),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  icon: Icons.location_on_rounded,
                  title: 'ที่ตั้ง',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${place['address'] ?? '-'}',
                        style: const TextStyle(
                          fontFamily: 'Sarabun',
                          fontSize: 14,
                          height: 1.55,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 218,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(latitude, longitude),
                              zoom: 14.5,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId('poi-detail'),
                                position: LatLng(latitude, longitude),
                                infoWindow: InfoWindow(title: title),
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueRose,
                                ),
                              ),
                            },
                            compassEnabled: false,
                            mapToolbarEnabled: false,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            gestureRecognizers: {
                              Factory<OneSequenceGestureRecognizer>(
                                EagerGestureRecognizer.new,
                              ),
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: FilledButton.icon(
            onPressed: () => _openDirections(context, latitude, longitude),
            icon: const Icon(Icons.directions_rounded),
            label: const Text(
              'เปิดเส้นทาง',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sharePlace(
    BuildContext context,
    Map<String, dynamic> place,
  ) async {
    final latitude = '${place['latitude'] ?? ''}';
    final longitude = '${place['longitude'] ?? ''}';
    final mapUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final box = context.findRenderObject() as RenderBox?;
    await Share.share(
      '${place['title'] ?? 'สถานที่ท่องเที่ยวโคราช'}\n'
      '${place['address'] ?? ''}\n$mapUrl',
      subject: '${place['title'] ?? 'เที่ยวโคราช'}',
      sharePositionOrigin:
          box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    );
  }

  Future<void> _openDirections(
    BuildContext context,
    double latitude,
    double longitude,
  ) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
    );
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่สามารถเปิดแผนที่ได้')),
      );
    }
  }
}

class _PlaceHeadline extends StatelessWidget {
  const _PlaceHeadline({required this.place});

  final Map<String, dynamic> place;

  @override
  Widget build(BuildContext context) {
    final distance = double.tryParse('${place['distance'] ?? ''}');
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A282429),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${place['category'] ?? 'แหล่งท่องเที่ยว'}',
              style: const TextStyle(
                color: AppColors.primary,
                fontFamily: 'Kanit',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${place['title'] ?? ''}',
            style: const TextStyle(
              fontFamily: 'Kanit',
              fontSize: 22,
              height: 1.25,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(
                icon: Icons.visibility_outlined,
                label: '${place['view'] ?? 0} ครั้ง',
              ),
              _InfoPill(
                icon: Icons.near_me_outlined,
                label: distance == null || distance <= 0
                    ? 'ใจกลางเมือง'
                    : '${distance.toStringAsFixed(distance < 10 ? 1 : 0)} กม.',
              ),
              const _InfoPill(
                icon: Icons.verified_rounded,
                label: 'ข้อมูลโดย Korat Connect',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Sarabun',
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    if (description.trim().isEmpty) {
      return const Text(
        'ยังไม่มีรายละเอียดเพิ่มเติม',
        style: TextStyle(
          fontFamily: 'Sarabun',
          color: AppColors.textSecondary,
        ),
      );
    }

    return Html(
      data: description,
      style: {
        'body': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          color: AppColors.textSecondary,
          fontFamily: 'Sarabun',
          fontSize: FontSize(14),
          lineHeight: const LineHeight(1.6),
        ),
      },
      onLinkTap: (url, _, __) {
        if (url != null) launchUrl(Uri.parse(url));
      },
    );
  }
}
