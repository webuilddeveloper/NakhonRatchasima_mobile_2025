import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../apptheme.dart';
import '../pages/blank_page/toast_fail.dart';
import '../shared/api_provider.dart';
import '../shared/extension.dart';
import 'comment_loading.dart';

// ignore: must_be_immutable
class Comment extends StatefulWidget {
  Comment({super.key, this.code, this.url, this.model, this.limit});

  String? code;
  String? url;
  Future<dynamic>? model;
  int? limit;

  @override
  _Comment createState() => _Comment();
}

class _Comment extends State<Comment> {
  final txtDescription = TextEditingController();
  FlutterSecureStorage? storage;
  String username = 'ประชาชนชาวโคราช';
  String imageUrlCreateBy = '';
  final List<Map<String, dynamic>> _localComments = [];

  @override
  void dispose() {
    txtDescription.dispose();
    super.dispose();
  }

  @override
  void initState() {
    storage = const FlutterSecureStorage();
    getUser();
    super.initState();
  }

  getUser() async {
    try {
      var value = await storage?.read(key: 'dataUserLoginDDPM');
      if (value != null && value.isNotEmpty) {
        var data = json.decode(value);
        if (mounted) {
          setState(() {
            imageUrlCreateBy = data['imageUrl'] ?? '';
            username = data['username'] ??
                (data['firstName'] != null
                    ? '${data['firstName']} ${data['lastName'] ?? ''}'.trim()
                    : 'ประชาชนชาวโคราช');
          });
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.all(18),
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
          Row(
            children: [
              const Icon(Icons.chat_bubble_outline_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'แสดงความคิดเห็น',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: txtDescription,
            keyboardType: TextInputType.multiline,
            maxLines: 3,
            maxLength: 200,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Kanit',
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              fillColor: AppColors.surfaceWarm,
              filled: true,
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              hintText: 'ร่วมแสดงความคิดเห็นหรือข้อเสนอแนะ...',
              hintStyle: const TextStyle(
                fontFamily: 'Kanit',
                fontSize: 13.5,
                color: AppColors.textSecondary,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text(
                'ส่งความคิดเห็น',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: sendComment,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<dynamic>(
            future: widget.model,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              List<dynamic> comments = [];
              if (snapshot.hasData && snapshot.data is List) {
                comments = [...snapshot.data as List];
              }
              // Merge local comments submitted in current session
              comments = [..._localComments, ...comments];

              if (comments.isNotEmpty) {
                return myComment(comments);
              }

              if (snapshot.connectionState == ConnectionState.waiting && _localComments.isEmpty) {
                return CommentLoading();
              }

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                child: const Text(
                  'ยังไม่มีความคิดเห็น เป็นคนแรกที่แสดงความคิดเห็นเลย!',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget myComment(List<dynamic> model) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: model.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = model[index];
        final String commentBy = (item['createBy'] ?? 'ประชาชน').toString();
        final String commentDesc = (item['description'] ?? '').toString();
        final String commentDate = item['createDate'] != null
            ? dateStringToDate(item['createDate'])
            : 'เมื่อสักครู่';

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceWarm,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.primarySoft,
                child: const Icon(Icons.person, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          commentBy,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                            fontFamily: 'Kanit',
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          commentDate,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                            fontFamily: 'Kanit',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      commentDesc,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'Kanit',
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void sendComment() async {
    final text = txtDescription.text.trim();
    if (text.isEmpty) return;

    final newComment = {
      'createBy': username,
      'imageUrlCreateBy': imageUrlCreateBy,
      'reference': widget.code,
      'description': text,
      'createDate': DateTime.now().toIso8601String(),
    };

    txtDescription.clear();
    unfocus(context);

    setState(() {
      _localComments.insert(0, newComment);
    });

    toastFail(
      context,
      title: 'ส่งความคิดเห็นสำเร็จ',
      text: 'ขอบคุณสำหรับการแสดงความคิดเห็นและข้อเสนอแนะ',
      duration: 3,
    );

    try {
      await postAny('${widget.url}create', {
        'createBy': username,
        'imageUrlCreateBy': imageUrlCreateBy,
        'reference': widget.code,
        'description': text,
      });
    } catch (_) {
      // Handled gracefully with local mock display
    }
  }
}
