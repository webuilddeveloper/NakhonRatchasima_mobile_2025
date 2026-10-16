import 'package:flutter/material.dart';
import 'package:ratchasima/apptheme.dart';
import 'package:ratchasima/component/korat_ui.dart';

PreferredSizeWidget header(
  BuildContext context,
  Function functionGoBack, {
  String title = '',
  bool isButtonLeft = true,
  bool isButtonRight = false,
  String imageRightButton = 'assets/images/task_list.png',
  Function? rightButton,
  String menu = '',
}) {
  return KoratAppBar(
    title: title,
    showBack: isButtonLeft,
    onBack: () => functionGoBack(),
    actions: [
      if (isButtonRight)
        KoratAppBarAction(
          tooltip: 'เมนูเพิ่มเติม',
          onPressed: () => rightButton?.call(),
          child: Image.asset(
            imageRightButton,
            width: 21,
            height: 21,
            color: AppColors.surface,
          ),
        ),
    ],
  );
}

headerNoti(
  BuildContext context,
  Function functionGoBack, {
  String title = '',
  bool isButtonRight = false,
  required Function rightButton,
  String menu = '',
  required int notiCount,
}) {
  return KoratAppBar(
    title: notiCount > 0 ? '$title ($notiCount)' : title,
    showBack: true,
    onBack: () => functionGoBack(),
    actions: [
      if (isButtonRight)
        KoratAppBarAction(
          tooltip: 'จัดการ',
          onPressed: () => rightButton(),
          icon: menu == 'notification'
              ? Icons.notifications_outlined
              : Icons.more_horiz_rounded,
        ),
    ],
  );
}
