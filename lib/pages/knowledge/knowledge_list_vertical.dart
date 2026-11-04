import 'package:flutter/material.dart';
import '../../apptheme.dart';
import '../../component/blurred_network_image.dart';
import '../../shared/mock_repository.dart';
import 'knowledge_form.dart';

class KnowledgeListVertical extends StatefulWidget {
  const KnowledgeListVertical({
    super.key,
    this.site,
    this.model,
  });

  final String? site;
  final Future<dynamic>? model;

  @override
  State<KnowledgeListVertical> createState() => _KnowledgeListVerticalState();
}

class _KnowledgeListVerticalState extends State<KnowledgeListVertical> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: widget.model,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,
              itemCount: 6,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 0,
                  color: AppColors.surface,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }

        final List<dynamic> data = (snapshot.hasData &&
                snapshot.data is List &&
                (snapshot.data as List).isNotEmpty)
            ? snapshot.data as List
            : KoratMockRepository.getKnowledgeList();

        // Data state
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
            ),
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Card(
                elevation: 0,
                color: AppColors.surface,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: InkWell(
                  onTap: () {
                    if (item['code'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              KnowledgeForm(code: item['code'], model: item),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: BlurredNetworkImage(
                              imageUrl: '${item['imageUrl'] ?? ''}',
                              width: double.infinity,
                              placeholder: Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey[400],
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          flex: 1,
                          child: Text(
                            item['title'] ?? 'ไม่มีชื่อ',
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Sarabun',
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(0.3),
                                Theme.of(context).primaryColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
