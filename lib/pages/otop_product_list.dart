import 'package:flutter/material.dart';
import 'package:ratchasima/apptheme.dart';
import 'package:ratchasima/component/korat_ui.dart';

import '../component/blurred_network_image.dart';
import 'otop_cart.dart';
import 'otop_product_detail.dart';

class OtopProductListPage extends StatefulWidget {
  const OtopProductListPage({super.key});

  @override
  State<OtopProductListPage> createState() => _OtopProductListPageState();
}

class _OtopProductListPageState extends State<OtopProductListPage> {
  final List<Map<String, String>> products = [
    {
      'name': 'กระเป๋าสานมือ',
      'image':
          'https://gateway.we-builds.com/wb-py-media/uploads/nakhonphanom\\20250527-111652-2fbb960de6bdcc8577d47800645cc477.jpeg',
      'description': 'กระเป๋าสานจากใบเตยหอม ทำมือ 100%',
      'price': '฿850',
      'category': 'งานฝีมือ',
      'rating': '4.8',
    },
    {
      'name': 'สบู่สมุนไพร',
      'image':
          'https://gateway.we-builds.com/wb-py-media/uploads/nakhonphanom\\20250527-111808-039b2f71f192a0989e12f688a9140df0.png_720x720q80.png',
      'description': 'สบู่สมุนไพรกลิ่นตะไคร้ หอมสดชื่น',
      'price': '฿120',
      'category': 'ผลิตภัณฑ์ธรรมชาติ',
      'rating': '4.9',
    },
  ];

  void goBack() => Navigator.pop(context, false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: KoratAppBar(
        title: 'สินค้า OTOP โคราช',
        showBack: true,
        onBack: goBack,
        actions: const [OtopCartButton()],
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildProductCard(context, products[index]),
                childCount: products.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Map<String, String> product,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OtopProductDetailPage(product: product),
              ),
            );
          },
          child: Container(
            height: 132,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 112,
                    height: double.infinity,
                    child: BlurredNetworkImage(
                      imageUrl: '${product['image'] ?? ''}',
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: const Center(
                        child: Icon(Icons.image_not_supported_outlined,
                            color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['category']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontFamily: 'Kanit',
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product['name']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontFamily: 'Kanit',
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        product['description']!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontFamily: 'Sarabun',
                          fontSize: 11,
                          height: 1.2,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product['price']!,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontFamily: 'Kanit',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: AppColors.warning, size: 16),
                              const SizedBox(width: 2),
                              Text(
                                product['rating']!,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontFamily: 'Kanit',
                                  fontSize: 11,
                                ),
                              ),
                            ],
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
