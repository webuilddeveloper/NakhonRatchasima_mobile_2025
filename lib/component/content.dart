import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../apptheme.dart';
import '../shared/api_provider.dart';
import '../shared/extension.dart';
import '../shared/mock_repository.dart';
import 'blurred_network_image.dart';
import 'gallery_view.dart';
import 'link_url_out.dart';
import 'link_url_in.dart';

class Content extends StatefulWidget {
  const Content({
    super.key,
    this.code,
    required this.url,
    this.model,
    this.urlGallery,
    this.pathShare,
  });

  final String? code;
  final String url;
  final dynamic model;
  final String? urlGallery;
  final String? pathShare;

  @override
  ContentState createState() => ContentState();
}

class ContentState extends State<Content> {
  Future<dynamic>? _futureModel;
  String _urlShared = '';
  List urlImage = [];
  List<ImageProvider> urlImageProvider = [];

  @override
  void initState() {
    super.initState();
    sharedApi();
    final targetUrl = widget.url.isNotEmpty ? widget.url : newsApi;
    _futureModel = post(targetUrl, {'skip': 0, 'limit': 1, 'code': widget.code});
    readGallery();
  }

  ImageProvider _resolveImageProvider(dynamic path) {
    if (path == null) return const AssetImage('assets/logo/logo.png');
    final str = path.toString().trim();
    if (str.isEmpty) return const AssetImage('assets/logo/logo.png');
    if (str.startsWith('assets/')) return AssetImage(str);
    if (str.startsWith('http://') || str.startsWith('https://')) return NetworkImage(str);
    if (str.startsWith('/') || str.startsWith('file://')) {
      return FileImage(File(str.replaceFirst('file://', '')));
    }
    return const AssetImage('assets/logo/logo.png');
  }

  Future<dynamic> readGallery() async {
    try {
      if (widget.urlGallery == null || widget.urlGallery!.isEmpty) return;
      final result = await postObjectData(widget.urlGallery!, {'code': widget.code});

      if (result != null && result['status'] == 'S' && result['objectData'] != null) {
        List data = [];
        List<ImageProvider> dataPro = [];

        for (var item in result['objectData']) {
          if (item != null && item['imageUrl'] != null && item['imageUrl'].toString().isNotEmpty) {
            data.add(item['imageUrl']);
            dataPro.add(_resolveImageProvider(item['imageUrl']));
          }
        }
        if (mounted && data.isNotEmpty) {
          setState(() {
            urlImage = data;
            urlImageProvider = dataPro;
          });
        }
      }
    } catch (e) {
      // Graceful fallback without crashing
    }
  }

  Future<dynamic> sharedApi() async {
    try {
      final result = await postConfigShare();
      if (result != null && result['status'] == 'S' && result['objectData'] != null) {
        if (mounted) {
          setState(() {
            _urlShared = result['objectData']['description'] ?? '';
          });
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _futureModel,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        dynamic model;

        if (snapshot.hasData && snapshot.data != null) {
          if (snapshot.data is List && (snapshot.data as List).isNotEmpty) {
            final list = snapshot.data as List;
            // 1. Look for matching code in API response
            if (widget.code != null && widget.code!.isNotEmpty) {
              model = list.firstWhere(
                (item) => item is Map && item['code'] != null && item['code'].toString() == widget.code,
                orElse: () => null,
              );
            }
            // 2. If not matched in API, but widget.model matches code, prioritize widget.model
            if (model == null && widget.model != null && widget.model is Map) {
              if (widget.code == null || widget.code!.isEmpty || widget.model['code'] == widget.code) {
                model = widget.model;
              }
            }
            model ??= list[0];
          } else if (snapshot.data is Map && (snapshot.data as Map).isNotEmpty) {
            if (widget.code == null || widget.code!.isEmpty || snapshot.data['code'] == widget.code) {
              model = snapshot.data;
            }
          }
        }

        model ??= widget.model;

        // Fallback to mock news item if model is still empty or null
        if (model == null) {
          final allNews = KoratMockRepository.getNewsList();
          model = allNews.firstWhere(
            (item) => item['code'] == widget.code,
            orElse: () => allNews.first,
          );
        }

        return myContent(model);
      },
    );
  }

  Widget myContent(dynamic model) {
    final String imageUrl = (model['imageUrl'] ?? '').toString();
    final List image = imageUrl.isNotEmpty ? [imageUrl] : [];
    final List<ImageProvider> imagePro =
        imageUrl.isNotEmpty ? [_resolveImageProvider(imageUrl)] : [];

    final allImages = [...image, ...urlImage];
    final allImageProviders = [...imagePro, ...urlImageProvider];

    final String title = (model['title'] ?? '').toString();
    final String description = (model['description'] ?? '').toString();
    final String category = (model['category'] ?? 'ข่าวประชาสัมพันธ์').toString();
    final String createBy = (model['createBy'] ?? 'สำนักงานจังหวัดนครราชสีมา').toString();
    final String createDate = model['createDate'] != null
        ? dateStringToDate(model['createDate'])
        : (model['date'] ?? 'ล่าสุด');
    final String views = '${model['view'] ?? 1250}';

    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Featured Image / Gallery View
          if (allImages.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: allImages.length > 1
                    ? GalleryView(
                        imageUrl: allImages,
                        imageProvider: allImageProviders,
                      )
                    : BlurredNetworkImage(
                        imageUrl: allImages.first,
                        width: double.infinity,
                        height: 240,
                      ),
              ),
            ),

          // 2. Main Article Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontFamily: 'Kanit',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Share Button
                    InkWell(
                      onTap: () {
                        final RenderBox? box = context.findRenderObject() as RenderBox?;
                        final shareText = '$_urlShared${widget.pathShare ?? 'content/news/'}${model['code'] ?? ''} $title';
                        Share.share(
                          shareText,
                          subject: title,
                          sharePositionOrigin: box != null
                              ? box.localToGlobal(Offset.zero) & box.size
                              : null,
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWarm,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.share_rounded, size: 16, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text(
                              'แชร์',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontFamily: 'Kanit',
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // Author & Metadata Row
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            createBy,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded,
                                  size: 13, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                createDate,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Kanit',
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.visibility_outlined,
                                  size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                '$views ครั้ง',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Kanit',
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

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: AppColors.border, height: 1, thickness: 1),
                ),

                // Body / Description Content
                _isHtml(description)
                    ? Html(
                        data: description,
                        style: {
                          "body": Style(
                            fontFamily: 'Kanit',
                            fontSize: FontSize(15.5),
                            color: AppColors.textPrimary,
                            lineHeight: const LineHeight(1.65),
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                          ),
                          "p": Style(
                            fontFamily: 'Kanit',
                            fontSize: FontSize(15.5),
                            color: AppColors.textPrimary,
                            lineHeight: const LineHeight(1.65),
                            margin: Margins.only(bottom: 12),
                          ),
                        },
                        onLinkTap: (url, context, attributes) {
                          if (url != null) {
                            launchUrl(Uri.parse(url),
                                mode: LaunchMode.externalApplication);
                          }
                        },
                      )
                    : Text(
                        description,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                          height: 1.7,
                        ),
                      ),

                if (_hasUrl(model['fileUrl']) || _hasUrl(model['linkUrl'])) ...[
                  const SizedBox(height: 20),
                  actionButton(model),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  bool _isHtml(String str) {
    return str.contains('<p>') ||
        str.contains('<br>') ||
        str.contains('<div>') ||
        str.contains('</span>') ||
        str.contains('</a>');
  }

  Widget linkButton(dynamic model) {
    return Container(
      width: double.infinity,
      height: 48,
      margin: const EdgeInsets.only(top: 8),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.open_in_new_rounded, size: 18),
        label: Text(
          '${model['textButton'] ?? 'ดูรายละเอียดเพิ่มเติม'}',
          style: const TextStyle(
            fontFamily: 'Kanit',
            fontWeight: FontWeight.w600,
            fontSize: 14.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          launchInWebViewWithJavaScript('${model['linkUrl']}');
        },
      ),
    );
  }

  Widget fileUrl(dynamic model) {
    return Container(
      width: double.infinity,
      height: 48,
      margin: const EdgeInsets.only(top: 8),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.attach_file_rounded, size: 20),
        label: const Text(
          'เปิดเอกสารแนบ (PDF / ไฟล์แนบ)',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          launchURL('${model['fileUrl']}');
        },
      ),
    );
  }

  bool _hasUrl(dynamic value) =>
      value != null && value.toString().trim().isNotEmpty;

  Widget actionButton(dynamic model) {
    if (_hasUrl(model['fileUrl'])) {
      return fileUrl(model);
    }
    return linkButton(model);
  }
}
