import 'package:flutter/material.dart';
import 'package:ratchasima/apptheme.dart';

import '../../component/blurred_network_image.dart';
import '../../shared/extension.dart';
import '../blank_page/blank_loading.dart';
import 'news_form.dart';

class NewsListVertical extends StatelessWidget {
  const NewsListVertical(
      {super.key,
      this.site,
      this.model,
      this.title,
      this.url,
      this.urlComment,
      this.urlGallery});

  final String? site;
  final Future<dynamic>? model;
  final String? title;
  final String? url;
  final String? urlComment;
  final String? urlGallery;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: model,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data.isEmpty) {
          return const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(
                  child: Text('ไม่พบข่าวสาร',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontFamily: 'Sarabun',
                          fontSize: 15))));
        }

        final news = snapshot.data as List;
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: news.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final item = news[index];
            return _NewsCard(
              item: item,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => NewsForm(
                          url: url,
                          code: item['code'],
                          model: item,
                          urlComment: urlComment,
                          urlGallery: urlGallery))),
            );
          },
        );
      },
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.item, required this.onTap});

  final dynamic item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = item['imageUrl']?.toString() ?? '';
    final date = item['createDate']?.toString();
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 178,
            width: double.infinity,
            child: BlurredNetworkImage(
              imageUrl: imageUrl,
              height: 178,
              width: double.infinity,
              placeholder: BlankLoading(height: 178),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item['title']?.toString() ?? 'ข่าวประชาสัมพันธ์',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontFamily: 'Kanit',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.25)),
              const SizedBox(height: 9),
              Row(children: [
                const Icon(Icons.calendar_today_outlined,
                    color: AppColors.primary, size: 14),
                const SizedBox(width: 5),
                Expanded(
                    child: Text(
                        date == null || date.isEmpty
                            ? 'ข่าวประชาสัมพันธ์จากจังหวัดนครราชสีมา'
                            : dateStringToDate(date),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontFamily: 'Sarabun',
                            fontSize: 11))),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.primary, size: 22),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
