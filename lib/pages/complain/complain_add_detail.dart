import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:ratchasima/shared/api_provider.dart';
import 'package:ratchasima/component/korat_ui.dart';
import 'package:ratchasima/apptheme.dart';
import 'package:ratchasima/pages/reporter/reporter_local_store.dart';
import 'package:ratchasima/pages/reporter/reporter_history_list.dart';

import '../../component/blurred_network_image.dart';

class ComplainAddDetail extends StatefulWidget {
  final String label;
  final String code;

  const ComplainAddDetail({
    super.key,
    required this.label,
    required this.code,
  });

  @override
  State<ComplainAddDetail> createState() => _ComplainAddDetailState();
}

class _ComplainAddDetailState extends State<ComplainAddDetail> {
  static const Color titleColor = AppColors.primary;
  static const Color borderColor = AppColors.border;

  final txtTitle = TextEditingController();
  final txtDescription = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  List<Map<String, String>> _images = [];
  final int _maxImages = 3;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    txtTitle.dispose();
    txtDescription.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    if (_images.length >= _maxImages) {
      _showMaxImagesReachedDialog();
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        String imageUrl = photo.path;
        try {
          imageUrl = await uploadImage(photo);
        } catch (_) {}

        setState(() {
          _images.add({"imageUrl": imageUrl});
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ไม่สามารถเข้าถึงกล้องถ่ายรูปได้ กรุณาตรวจสอบสิทธิ์ในตั้งค่า (Settings)',
            style: TextStyle(fontFamily: 'Sarabun'),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    if (_images.length >= _maxImages) {
      _showMaxImagesReachedDialog();
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        String imageUrl = image.path;
        try {
          imageUrl = await uploadImage(image);
        } catch (_) {}

        setState(() {
          _images.add({"imageUrl": imageUrl});
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ไม่สามารถเข้าถึงคลังรูปภาพได้ กรุณาตรวจสอบสิทธิ์ในตั้งค่า (Settings)',
            style: TextStyle(fontFamily: 'Sarabun'),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showMaxImagesReachedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ขออภัย'),
          content: const Text('คุณสามารถเลือกรูปภาพได้สูงสุด 3 รูปเท่านั้น'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('เข้าใจแล้ว'),
            ),
          ],
        );
      },
    );
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<dynamic> submitReporter() async {
    final firstImage = _images.isNotEmpty ? _images.first['imageUrl'] : '';
    ReporterLocalStore.add(
      title: txtTitle.text.trim(),
      category: widget.label,
      description: txtDescription.text.trim(),
      imageUrl: firstImage,
    );
    final reportCode = ReporterLocalStore.reports.isNotEmpty
        ? ReporterLocalStore.reports.first['code']
        : 'KRT-REPORTER';

    if (!mounted) return;

    return showGeneralDialog(
      barrierDismissible: false,
      context: context,
      barrierLabel: 'success',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (BuildContext ctx, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(ctx).size.width * 0.85,
              constraints: const BoxConstraints(maxWidth: 350),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ส่งเรื่องแจ้งปัญหาเรียบร้อยแล้ว',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWarm,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'รหัสเรื่อง: $reportCode',
                      style: const TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'เรื่องร้องเรียนของคุณถูกบันทึกเข้าระบบแล้ว เจ้าหน้าที่เทศบาลจะดำเนินการตรวจสอบและประสานงานแก้ไขต่อไป',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        goBack();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: const Text(
                        'เสร็จสิ้น',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const ReporterHistoryList(title: 'ติดตามปัญหา'),
                          ),
                        );
                      },
                      child: const Text(
                        'ติดตามสถานะเรื่องนี้',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 13.5,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return Transform.scale(
          scale: 0.85 + (0.15 * anim1.value),
          child: Opacity(opacity: anim1.value, child: child),
        );
      },
    );
  }

  void goBack() async {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: KoratAppBar(
        title: 'แจ้งปัญหา',
        showBack: true,
        onBack: goBack,
      ),
      body: Form(
        // เพิ่ม Form widget และเชื่อมกับ _formKey
        key: _formKey,
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'เพิ่มเรื่องร้องเรียน\nหัวข้อ ${widget.label}',
                      style: const TextStyle(
                        fontFamily: 'Kanit',
                        fontWeight: FontWeight.w600,
                        fontSize: 36,
                        color: titleColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  buildRequiredLabel('เรื่อง'),
                  const SizedBox(height: 8),
                  buildTextFormField(
                      isMultiline: false,
                      controller: txtTitle), // เปลี่ยนเป็น TextFormField
                  const SizedBox(height: 20),

                  buildRequiredLabel('รายละเอียด'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 150,
                    child: buildTextFormField(
                        isMultiline: true, controller: txtDescription),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    'แนบรูป (ไม่เกิน 3 รูป)',
                    style: const TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: buildImageButton(
                          icon: Icons.camera_alt,
                          label: 'ถ่ายรูป',
                          onTap: () {
                            _takePhoto();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: buildImageButton(
                          icon: Icons.photo_camera_back,
                          label: 'แนบรูป',
                          onTap: () {
                            _pickImage();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _images.isEmpty
                      ? SizedBox()
                      : Text(
                          'รูปภาพที่เลือก (${_images.length}/$_maxImages)',
                          style: const TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 120,
                    child: _images.isEmpty
                        ? SizedBox()
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: _images.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: BlurredNetworkImage(
                                      imageUrl:
                                          '${_images[index]["imageUrl"] ?? ''}',
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'ยกเลิก',
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 16,
                        fontFamily: 'Kanit',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: InkWell(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    if (_formKey.currentState!.validate()) {
                      if (txtTitle.text.isEmpty) {
                        _showErrorDialog('กรุณาระบุหัวข้อเรื่อง');
                        return;
                      }
                      if (txtDescription.text.isEmpty) {
                        _showErrorDialog('กรุณาระบุรายละเอียด');
                        return;
                      }

                      submitReporter();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: titleColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'แจ้งเรื่อง',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Kanit',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRequiredLabel(String labelText) {
    return Text.rich(
      TextSpan(
        text: '$labelText ',
        style: const TextStyle(
          fontFamily: 'Kanit',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        children: const [
          TextSpan(
            text: '*',
            style: TextStyle(
              color: Colors.red,
              fontFamily: 'Kanit',
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextFormField({
    required bool isMultiline,
    required TextEditingController controller,
  }) {
    return TextFormField(
      textAlignVertical: TextAlignVertical.top,
      controller: controller,
      expands: isMultiline,
      maxLines: isMultiline ? null : 1,
      minLines: isMultiline ? null : 1,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'กรุณากรอกข้อมูล';
        }
        return null;
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: titleColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(ctx).size.width * 0.82,
              constraints: const BoxConstraints(maxWidth: 340),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.info_outline_rounded,
                        color: AppColors.error, size: 30),
                  ),
                  const SizedBox(height: 14),
                  const Text('ข้อมูลไม่ครบถ้วน',
                      style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text(message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 14,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: const Text('เข้าใจแล้ว',
                          style: TextStyle(
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return Transform.scale(
          scale: 0.85 + (0.15 * anim1.value),
          child: Opacity(opacity: anim1.value, child: child),
        );
      },
    );
  }

  Widget buildImageButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: borderColor,
              size: 35,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Kanit',
                color: borderColor,
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            )
          ],
        ),
      ),
    );
  }
}
