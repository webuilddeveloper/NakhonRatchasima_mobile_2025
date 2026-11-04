import 'package:flutter/material.dart';
import '../../apptheme.dart';
import '../../component/korat_ui.dart';

class PollDialog extends StatelessWidget {
  final dynamic userData;
  final String? titleHome;

  const PollDialog({
    super.key,
    this.titleHome,
    this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: KoratAppBar(
        title: 'ผลการส่งแบบสำรวจ',
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 54,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'ส่งแบบสำรวจเรียบร้อยแล้ว',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'ขอบคุณที่ร่วมเป็นพลังขับเคลื่อนเมืองโคราช เสียงและความคิดเห็นของท่านจะถูกนำไปส่งต่อให้หน่วยงานที่เกี่ยวข้องเพื่อพัฒนาเมืองต่อไป',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.how_to_vote_rounded,
                        size: 16, color: Color(0xFF10B981)),
                    SizedBox(width: 6),
                    Text(
                      'Citizen Voice: บันทึกคะแนนโหวตแล้ว',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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
            ],
          ),
        ),
      ),
    );
  }
}
