import 'package:flutter/material.dart';
import 'package:ratchasima/apptheme.dart';
import 'package:ratchasima/component/header.dart';
import 'package:ratchasima/component/korat_ui.dart';

import '../component/blurred_network_image.dart';

class OtopCartItem {
  OtopCartItem({required this.product, this.quantity = 1});

  final Map<String, String> product;
  int quantity;

  int get unitPrice {
    final value = product['price']?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0';
    return int.tryParse(value) ?? 0;
  }

  int get subtotal => unitPrice * quantity;
}

class OtopCartController extends ChangeNotifier {
  OtopCartController._();

  static final OtopCartController instance = OtopCartController._();
  final List<OtopCartItem> items = [];

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  int get total => items.fold(0, (sum, item) => sum + item.subtotal);

  void add(Map<String, String> product) {
    final index =
        items.indexWhere((item) => item.product['name'] == product['name']);
    if (index == -1) {
      items.add(OtopCartItem(product: product));
    } else {
      items[index].quantity++;
    }
    notifyListeners();
  }

  void increase(OtopCartItem item) {
    item.quantity++;
    notifyListeners();
  }

  void decrease(OtopCartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      items.remove(item);
    }
    notifyListeners();
  }

  void remove(OtopCartItem item) {
    items.remove(item);
    notifyListeners();
  }

  void clear() {
    items.clear();
    notifyListeners();
  }
}

class OtopCartButton extends StatelessWidget {
  const OtopCartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: OtopCartController.instance,
      builder: (context, _) {
        final count = OtopCartController.instance.itemCount;
        return KoratAppBarAction(
          tooltip: 'ตะกร้าสินค้า',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OtopCartPage()),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_bag_outlined,
                  color: AppColors.surface, size: 21),
              if (count > 0)
                Positioned(
                  right: -7,
                  top: -7,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 17),
                    height: 17,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontFamily: 'Kanit',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class OtopCartPage extends StatelessWidget {
  const OtopCartPage({super.key});

  void _checkout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OtopCheckoutPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar:
          header(context, () => Navigator.pop(context), title: 'ตะกร้าสินค้า'),
      body: AnimatedBuilder(
        animation: OtopCartController.instance,
        builder: (context, _) {
          final cart = OtopCartController.instance;
          if (cart.items.isEmpty) return const _EmptyCart();
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _CartItemCard(item: cart.items[index]),
                ),
              ),
              _CartSummary(onCheckout: () => _checkout(context)),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.item});

  final OtopCartItem item;

  @override
  Widget build(BuildContext context) {
    final cart = OtopCartController.instance;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BlurredNetworkImage(
              imageUrl: '${item.product['image'] ?? ''}',
              width: 82,
              height: 82,
              placeholder: const SizedBox(
                width: 82,
                height: 82,
                child: Icon(Icons.image_not_supported_outlined),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product['name']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontFamily: 'Kanit',
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(item.product['price']!,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontFamily: 'Kanit',
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 7),
                Row(
                  children: [
                    _QuantityButton(
                        icon: Icons.remove, onTap: () => cart.decrease(item)),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('${item.quantity}',
                            style: const TextStyle(
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w600))),
                    _QuantityButton(
                        icon: Icons.add, onTap: () => cart.increase(item)),
                    const Spacer(),
                    InkWell(
                        onTap: () => cart.remove(item),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: AppColors.textSecondary, size: 20)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppColors.primary, size: 17),
        ),
      );
}

class _CartSummary extends StatelessWidget {
  const _CartSummary(
      {required this.onCheckout, this.buttonLabel = 'ดำเนินการสั่งซื้อ'});
  final VoidCallback onCheckout;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    final total = OtopCartController.instance.total;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border))),
        child: Row(
          children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('ยอดรวม',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontFamily: 'Sarabun',
                          fontSize: 12)),
                  Text('฿$total',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontFamily: 'Kanit',
                          fontSize: 22,
                          fontWeight: FontWeight.w700))
                ])),
            ElevatedButton(
                onPressed: onCheckout,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13))),
                child: Text(buttonLabel,
                    style: const TextStyle(
                        fontFamily: 'Kanit', fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                    color: AppColors.primarySoft, shape: BoxShape.circle),
                child: const Icon(Icons.shopping_bag_outlined,
                    color: AppColors.primary, size: 38)),
            const SizedBox(height: 16),
            const Text('ยังไม่มีสินค้าในตะกร้า',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'Kanit',
                    fontSize: 19,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text('เลือกสินค้า OTOP ที่สนใจ แล้วเพิ่มลงตะกร้าได้เลย',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'Sarabun',
                    fontSize: 13))
          ])));
}

class OtopCheckoutPage extends StatefulWidget {
  const OtopCheckoutPage({super.key});
  @override
  State<OtopCheckoutPage> createState() => _OtopCheckoutPageState();
}

class _OtopCheckoutPageState extends State<OtopCheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    OtopCartController.instance.clear();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const OtopOrderSuccessPage()));
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4)));

  Widget _paymentDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                    color: AppColors.primarySoft, shape: BoxShape.circle),
                child: const Icon(Icons.qr_code_2_rounded,
                    color: AppColors.primary)),
            const SizedBox(width: 10),
            const Expanded(
                child: Text('ชำระเงินด้วย QR พร้อมเพย์',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontFamily: 'Kanit',
                        fontSize: 16,
                        fontWeight: FontWeight.w600)))
          ]),
          const SizedBox(height: 14),
          Container(
              height: 130,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: AppColors.surfaceWarm,
                  borderRadius: BorderRadius.circular(14)),
              child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_2_rounded,
                        color: AppColors.primary, size: 82),
                    Text('QR สำหรับชำระเงินจะแสดงเมื่อยืนยันรายการ',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontFamily: 'Sarabun',
                            fontSize: 11))
                  ])),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: header(context, () => Navigator.pop(context),
            title: 'สั่งซื้อสินค้า'),
        body: Form(
          key: _formKey,
          child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
              children: [
                const Text('กรอกข้อมูลสำหรับจัดส่งสินค้า',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontFamily: 'Kanit',
                        fontSize: 20,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                const Text(
                    'ผู้ผลิตจะติดต่อกลับเพื่อยืนยันรายละเอียดการสั่งซื้อ',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'Sarabun',
                        fontSize: 13)),
                const SizedBox(height: 20),
                TextFormField(
                    controller: _nameController,
                    decoration: _decoration('ชื่อผู้รับ', Icons.person_outline),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'กรุณากรอกชื่อผู้รับ'
                        : null),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration:
                        _decoration('เบอร์โทรศัพท์', Icons.phone_outlined),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'กรุณากรอกเบอร์โทรศัพท์'
                        : null),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _addressController,
                    maxLines: 4,
                    decoration: _decoration(
                        'ที่อยู่จัดส่ง', Icons.location_on_outlined),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'กรุณากรอกที่อยู่จัดส่ง'
                        : null),
                const SizedBox(height: 24),
                const Text('วิธีชำระเงิน',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontFamily: 'Kanit',
                        fontSize: 19,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                _paymentDetails(),
                const SizedBox(height: 22),
                _CartSummary(
                    onCheckout: _submit, buttonLabel: 'ยืนยันการสั่งซื้อ'),
              ]),
        ),
      );
}

class OtopOrderSuccessPage extends StatelessWidget {
  const OtopOrderSuccessPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: AppColors.background,
      appBar: header(
          context, () => Navigator.popUntil(context, (route) => route.isFirst),
          title: 'สั่งซื้อสำเร็จ'),
      body: Center(
          child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                        color: AppColors.primarySoft, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded,
                        color: AppColors.primary, size: 52)),
                const SizedBox(height: 20),
                const Text('ขอบคุณสำหรับการสั่งซื้อ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontFamily: 'Kanit',
                        fontSize: 24,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text(
                    'เราได้รับข้อมูลการสั่งซื้อแล้ว ผู้ผลิตจะติดต่อกลับเพื่อยืนยันรายการและการจัดส่ง',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'Sarabun',
                        fontSize: 14,
                        height: 1.4)),
                const SizedBox(height: 24),
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () => Navigator.popUntil(
                            context, (route) => route.isFirst),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.surface,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14))),
                        child: const Text('กลับไปเลือกสินค้า',
                            style: TextStyle(
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w600))))
              ]))));
}
