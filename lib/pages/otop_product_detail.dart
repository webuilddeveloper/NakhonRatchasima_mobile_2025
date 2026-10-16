import 'package:flutter/material.dart';
import 'package:ratchasima/apptheme.dart';
import 'package:ratchasima/component/korat_ui.dart';

import '../component/blurred_network_image.dart';
import 'otop_cart.dart';

class OtopProductDetailPage extends StatefulWidget {
  final Map<String, String> product;

  const OtopProductDetailPage({super.key, required this.product});

  @override
  _OtopProductDetailPageState createState() => _OtopProductDetailPageState();
}

class _OtopProductDetailPageState extends State<OtopProductDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 700),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _animationController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFBF7),
      appBar: KoratAppBar(
        title: 'รายละเอียดสินค้า',
        showBack: true,
        onBack: () => Navigator.pop(context),
        actions: const [OtopCartButton()],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Section
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: double.infinity,
                height: 160,
                margin: EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Hero(
                    tag: 'product_image',
                    child: BlurredNetworkImage(
                      imageUrl: '${widget.product['image'] ?? ''}',
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
            ),

            // Product Info Section
            SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.grey[50]!],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Badge
                    if (widget.product['category'] != null)
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFC9166D).withOpacity(0.2),
                              Color(0xFFF670C3).withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Color(0xFFC9166D).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          widget.product['category']!,
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 10,
                            color: Color(0xFFC9166D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                    SizedBox(height: 12),

                    // Product Name
                    Text(
                      widget.product['name']!,
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[800],
                        height: 1.2,
                      ),
                    ),

                    SizedBox(height: 10),

                    // Description
                    Text(
                      widget.product['description']!,
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),

                    SizedBox(height: 16),

                    // Rating and Price Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ...List.generate(5, (index) {
                                  return Icon(
                                    Icons.star_rounded,
                                    color: index < 4
                                        ? Color(0xFFF670C3)
                                        : Colors.grey[300],
                                    size: 20,
                                  );
                                }),
                                SizedBox(width: 6),
                                Text(
                                  widget.product['rating'] ?? '4.8',
                                  style: TextStyle(
                                    fontFamily: 'Kanit',
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Text(
                              widget.product['price']!,
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFC9166D),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    OtopCartController.instance.add(widget.product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('เพิ่มสินค้าลงตะกร้าแล้ว')),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                  label: const Text('เพิ่มลงตะกร้า'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    OtopCartController.instance.add(widget.product);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OtopCartPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('ซื้อเลย'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
