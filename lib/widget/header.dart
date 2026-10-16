import 'package:flutter/material.dart';
import 'package:ratchasima/component/korat_ui.dart';

PreferredSizeWidget header(
  BuildContext? context,
  void Function() goBack, {
  String? title,
}) {
  return KoratAppBar(
    title: title?.isNotEmpty == true ? title! : 'Korat Connect',
    showBack: true,
    onBack: goBack,
  );
}
