import 'package:flutter/material.dart';
import 'package:ratchasima/component/korat_ui.dart';

PreferredSizeWidget headerCalendar(
  BuildContext context,
  Function functionGoBack,
  bool showCalendar, {
  String title = '',
  Function? rightButton,
  bool showLeading = true,
}) {
  return KoratAppBar(
    title: title,
    showBack: showLeading,
    onBack: () => functionGoBack(),
    actions: [
      if (rightButton != null)
        KoratAppBarAction(
          tooltip: showCalendar ? 'ปฏิทิน' : 'รายการ',
          onPressed: () => rightButton(),
          icon: showCalendar
              ? Icons.calendar_month_outlined
              : Icons.format_list_bulleted_rounded,
        ),
    ],
  );
}
