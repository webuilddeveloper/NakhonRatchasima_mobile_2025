import 'package:flutter/material.dart';
import 'package:ratchasima/apptheme.dart';
import 'package:ratchasima/component/korat_ui.dart';
import 'package:ratchasima/pages/complain/complain_detail.dart';
import 'package:ratchasima/pages/complain/complain_follow.dart';

class ComplainListCategory extends StatefulWidget {
  final Function? changePage;
  final String? title;

  const ComplainListCategory({super.key, this.title, this.changePage});

  @override
  _ComplainListCategoryState createState() => _ComplainListCategoryState();
}

class _ComplainListCategoryState extends State<ComplainListCategory> {
  void goBack() {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: KoratAppBar(
        title: widget.title ?? 'แจ้งเหตุ / แจ้งปัญหา',
        showBack: false,
      ),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          // const KoratPageHeader(
          //   title: 'Korat Connect',
          //   subtitle: 'ศูนย์กลางรับเรื่องและติดตามการให้บริการของจังหวัด',
          // ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KoratSurfaceCard(
                  color: AppColors.primarySoft,
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: KoratRadius.md,
                        ),
                        child: const Icon(
                          Icons.forum_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'เราพร้อมรับฟังทุกเรื่องของคุณ',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: AppColors.primary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'เลือกบริการด้านล่างเพื่อเริ่มแจ้งเรื่องใหม่ หรือตรวจสอบความคืบหน้า',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const KoratSectionTitle(
                  title: 'บริการรับเรื่อง',
                  subtitle:
                      'ข้อมูลและขั้นตอนเดิมครบถ้วนในรูปแบบที่ใช้งานง่ายขึ้น',
                ),
                const SizedBox(height: 14),
                buildCategoryButton(
                  title: 'แจ้งเรื่องใหม่',
                  subtitle:
                      'แจ้งเหตุ ร้องทุกข์ หรือส่งเรื่องให้หน่วยงานที่เกี่ยวข้อง',
                  icon: Icons.add_comment_outlined,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ComplainDetail()),
                  ),
                ),
                const SizedBox(height: 12),
                buildCategoryButton(
                  title: 'ติดตามสถานะ',
                  subtitle: 'ดูขั้นตอนปัจจุบันและความคืบหน้าของเรื่องที่เคยส่ง',
                  icon: Icons.track_changes_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ComplainFollow()),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.privacy_tip_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ข้อมูลของคุณจะถูกส่งผ่านระบบเดิมอย่างปลอดภัย และสามารถติดตามผลได้ภายหลัง',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategoryButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return KoratSurfaceCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: KoratRadius.md,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: KoratRadius.md,
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
