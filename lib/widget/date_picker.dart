import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as datatTimePicker;
import '../apptheme.dart';

datePicker(
    {TextEditingController? controller,
    String? title,
    double fontSize = 13,
    BuildContext? context}) {
  return InkWell(
    onTap: () {
      dialogOpenPickerDate(context!, controller!);
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          title!,
          style: const TextStyle(
            fontSize: 15.000,
            fontFamily: 'Kanit',
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
        SizedBox(
          height: 45,
          child: TextField(
            controller: controller,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.normal,
              fontFamily: 'Sarabun',
              fontSize: 15.0,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              hintText: "วันเดือนปีเกิด",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              errorStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontFamily: 'Sarabun',
                fontSize: 10.0,
              ),
            ),
            enabled: false,
          ),
        )
      ],
    ),
  );
}

dialogOpenPickerDate(BuildContext context, TextEditingController controller) {
  datatTimePicker.DatePicker.showDatePicker(context,
      theme: const datatTimePicker.DatePickerTheme(
        containerHeight: 210.0,
        itemStyle: TextStyle(
          fontSize: 16.0,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.normal,
          fontFamily: 'Sarabun',
        ),
        doneStyle: TextStyle(
          fontSize: 16.0,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontFamily: 'Kanit',
        ),
        cancelStyle: TextStyle(
          fontSize: 16.0,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.normal,
          fontFamily: 'Kanit',
        ),
      ),
      showTitleActions: true,
      minTime: DateTime(1800, 1, 1),
      maxTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day),
      onConfirm: (date) {
    // print('----- onConfirm -----' +
    //     date.year.toString() +
    //     date.month.toString() +
    //     date.day.toString());
    controller.text = '${date.day}-${date.month}-${date.year}';
    // controller.text = dateFormatGlobal(
    //     date.year.toString() + date.month.toString() + date.day.toString());
  },
      currentTime: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
      locale: datatTimePicker.LocaleType.th);
}
