import 'dart:async';
import 'package:flutter/material.dart';
import '../../apptheme.dart';

toastFail(
  BuildContext context, {
  String text = 'การเชื่อมต่อผิดพลาด',
  Color color = Colors.grey,
  Color fontColor = Colors.white,
  int duration = 3,
  String? title,
  IconData? icon,
}) {
  if (!context.mounted) return;

  final bool isSuccess = text.contains('สำเร็จ') ||
      text.contains('ขอบคุณ') ||
      text.contains('เรียบร้อย') ||
      text.contains('แล้ว') ||
      color == Colors.green;

  final IconData effectiveIcon = icon ??
      (isSuccess
          ? Icons.check_circle_rounded
          : Icons.info_outline_rounded);

  final Color iconColor = isSuccess ? AppColors.primary : const Color(0xFFF59E0B);

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, anim1, anim2) {
      Timer(Duration(seconds: duration), () {
        if (ctx.mounted && Navigator.of(ctx).canPop()) {
          Navigator.of(ctx).pop();
        }
      });

      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.78,
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
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
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(effectiveIcon, color: iconColor, size: 34),
                ),
                const SizedBox(height: 16),
                if (title != null && title.isNotEmpty) ...[
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 15,
                    fontWeight: title != null ? FontWeight.w400 : FontWeight.w500,
                    color: title != null ? AppColors.textSecondary : AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'ตกลง',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 14.5,
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
        child: Opacity(
          opacity: anim1.value,
          child: child,
        ),
      );
    },
  );
}

void showKoratSuccessPopup(
  BuildContext context, {
  required String title,
  required String message,
  String buttonText = 'ตกลง',
  VoidCallback? onConfirm,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, anim1, anim2) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.82,
            constraints: const BoxConstraints(maxWidth: 340),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
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
                  decoration: BoxDecoration(
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
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 14.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      if (onConfirm != null) onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 15,
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
