import 'package:flutter/material.dart';
import '../apptheme.dart';

labelTextField(String label, Icon icon) {
  return Row(
    children: <Widget>[
      icon,
      Text(
        ' $label',
        style: const TextStyle(
          fontSize: 15.000,
          fontFamily: 'Kanit',
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    ],
  );
}

textField(
  TextEditingController? model,
  TextEditingController? modelMatch,
  String hintText,
  String validator,
  bool enabled,
  bool isPassword,
) {
  return SizedBox(
    height: 45.0,
    child: TextField(
      // keyboardType: TextInputType.number,
      obscureText: isPassword,
      controller: model,
      enabled: enabled,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.normal,
        fontFamily: 'Sarabun',
        fontSize: 15.00,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    ),
  );
}
