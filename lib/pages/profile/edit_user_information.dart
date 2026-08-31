import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as datatTimePicker;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ratchasima/component/header.dart';
import 'package:ratchasima/home.dart';
import 'package:ratchasima/pages/profile/user_information.dart';

import '../../home_v2.dart';
import '../../shared/api_provider.dart';
import '../../widget/text_form_field.dart';
import '../blank_page/dialog_fail.dart';

class EditUserInformationPage extends StatefulWidget {
  @override
  _EditUserInformationPageState createState() =>
      _EditUserInformationPageState();
}

class _EditUserInformationPageState extends State<EditUserInformationPage> {
  final storage = new FlutterSecureStorage();

  String? _imageUrl;

  final _formKey = GlobalKey<FormState>();

  String? _selectedSex;
  List<dynamic> _itemSex = [
    {'title': 'ชาย', 'code': 'ชาย'},
    {'title': 'หญิง', 'code': 'หญิง'},
    {'title': 'ไม่ระบุเพศ', 'code': 'ไม่ระบุเพศ'}
  ];
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedSubDistrict;
  String? _selectedPostalCode;

  final txtEmail = TextEditingController();
  final txtPassword = TextEditingController();
  final txtConPassword = TextEditingController();
  final txtPrefixName = TextEditingController();
  final txtFirstName = TextEditingController();
  final txtLastName = TextEditingController();
  final txtPhone = TextEditingController();
  final txtUsername = TextEditingController();
  final txtIdCard = TextEditingController();
  final txtLineID = TextEditingController();
  final txtOfficerCode = TextEditingController();
  final txtAddress = TextEditingController();
  final txtMoo = TextEditingController();
  final txtSoi = TextEditingController();
  final txtRoad = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TextEditingController txtDate = TextEditingController();

  Future<dynamic>? futureModel;

  ScrollController scrollController = new ScrollController();

  XFile? _image;

  int _selectedDay = 0;
  int _selectedMonth = 0;
  int _selectedYear = 0;
  int year = 0;
  int month = 0;
  int day = 0;

  @override
  void dispose() {
    txtEmail.dispose();
    txtPassword.dispose();
    txtConPassword.dispose();
    txtFirstName.dispose();
    txtLastName.dispose();
    txtPhone.dispose();
    txtDate.dispose();
    super.dispose();
  }

  @override
  void initState() {
    futureModel = getUser();

    scrollController = ScrollController();
    var now = new DateTime.now();
    setState(() {
      year = now.year;
      month = now.month;
      day = now.day;
      _selectedYear = now.year;
      _selectedMonth = now.month;
      _selectedDay = now.day;
    });
    super.initState();
  }

  Future<dynamic> getProvince() async {
    final result = await postObjectData("/route/province/read", {});
    if (result['status'] == 'S') {
      setState(() {});
    }
  }

  Future<dynamic> getDistrict() async {
    final result = await postObjectData("/route/district/read", {
      'province': _selectedProvince,
    });
    if (result['status'] == 'S') {
      setState(() {});
    }
  }

  Future<dynamic> getSubDistrict() async {
    final result = await postObjectData("/route/tambon/read", {
      'province': _selectedProvince,
      'district': _selectedDistrict,
    });
    if (result['status'] == 'S') {
      setState(() {});
    }
  }

  Future<dynamic> getPostalCode() async {
    final result = await postObjectData("/route/postCode/read", {
      'tambon': _selectedSubDistrict,
    });
    if (result['status'] == 'S') {
      setState(() {});
    }
  }

  bool isValidDate(String input) {
    try {
      final date = DateTime.parse(input);
      final originalFormatString = toOriginalFormatString(date);
      return input == originalFormatString;
    } catch (e) {
      return false;
    }
  }

  String toOriginalFormatString(DateTime dateTime) {
    final y = dateTime.year.toString().padLeft(4, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    return "$y$m$d";
  }

  Future<void> getUser() async {
    try {
      var profileCode = await storage.read(key: 'profileCode2');

      if (profileCode == null || profileCode.isEmpty) return;

      // final result = await postDio('$serverNpm/m/register/read', {
      //   "code": profileCode,
      // });
      final result = await postDio(profileReadApi, {"code": profileCode});

      print('========getUser====result====>>>>> $result');

      if (result is List && result.isNotEmpty) {
        final userData = result[0];

        await storage.write(
          key: 'dataUserLoginOPEC',
          value: jsonEncode(userData),
        );

        if (userData['birthDay'] != null &&
            userData['birthDay'].toString().isNotEmpty) {
          if (isValidDate(userData['birthDay'])) {
            final dateStr = userData['birthDay'];
            final year = dateStr.substring(0, 4);
            final month = dateStr.substring(4, 6);
            final day = dateStr.substring(6, 8);
            final birthDate = DateTime.parse('$year-$month-$day');

            txtDate.text = DateFormat("dd-MM-yyyy").format(birthDate);
            setState(() {
              _selectedYear = birthDate.year;
              _selectedMonth = birthDate.month;
              _selectedDay = birthDate.day;
            });
          }
        }

        setState(() {
          _imageUrl = userData['imageUrl'] ?? '';
          txtFirstName.text = userData['firstName'] ?? '';
          txtLastName.text = userData['lastName'] ?? '';
          txtEmail.text = userData['email'] ?? '';
          txtPhone.text = userData['phone'] ?? '';
          txtUsername.text = userData['username'] ?? '';
          txtIdCard.text = userData['idcard'] ?? '';
          txtLineID.text = userData['lineID'] ?? '';
          txtOfficerCode.text = userData['officerCode'] ?? '';
          txtAddress.text = userData['address'] ?? '';
          txtMoo.text = userData['moo'] ?? '';
          txtSoi.text = userData['soi'] ?? '';
          txtRoad.text = userData['road'] ?? '';
          txtPrefixName.text = userData['prefixName'] ?? '';

          _selectedProvince = userData['provinceCode'] ?? '';
          _selectedDistrict = userData['amphoeCode'] ?? '';
          _selectedSubDistrict = userData['tambonCode'] ?? '';
          _selectedPostalCode = userData['postnoCode'] ?? '';
          _selectedSex = userData['sex'] ?? '';
        });

        // โหลดข้อมูลพื้นที่
        await getProvince();
        if (_selectedProvince!.isNotEmpty) {
          await getDistrict();
          await getSubDistrict();
          await getPostalCode();
        }
      } else {
        print("Result is not a valid list or is empty");
      }
    } catch (e) {
      print('Error in getUser: $e');
    }
  }

  Future<dynamic> submitUpdateUser() async {
    print(
      '---------------------------$_selectedProvince----------------------------',
    );

    // var value = await storage.read(key: 'dataUserLoginKSP') ?? "";
    // var user = json.decode(value);
    var value = await storage.read(key: 'dataUserLoginDDPM');
    var user = json.decode(value!);
    user['imageUrl'] = _imageUrl;
    // user['prefixName'] = _selectedPrefixName ?? '';
    user['prefixName'] = txtPrefixName.text;
    user['firstName'] = txtFirstName.text;
    user['lastName'] = txtLastName.text;
    user['email'] = txtEmail.text;
    user['phone'] = txtPhone.text;

    user['birthDay'] = DateFormat(
      "yyyyMMdd",
    ).format(DateTime(_selectedYear, _selectedMonth, _selectedDay));
    user['sex'] = _selectedSex;
    user['address'] = txtAddress.text;
    user['soi'] = txtSoi.text;
    user['moo'] = txtMoo.text;
    user['road'] = txtRoad.text;
    user['tambon'] = '';
    user['amphoe'] = '';
    user['province'] = '';
    user['postno'] = '';
    user['tambonCode'] = _selectedSubDistrict;
    user['amphoeCode'] = _selectedDistrict;
    user['provinceCode'] = _selectedProvince;
    user['postnoCode'] = _selectedPostalCode;
    user['idcard'] = txtIdCard.text;
    user['officerCode'] = txtOfficerCode.text;
    user['linkAccount'] = user['linkAccount'] ?? '';
    user['appleID'] = user['appleID'] ?? "";

    final result = await postObjectData('/m/register/update', user);

    if (result['status'] == 'S') {
      await storage.write(
        key: 'dataUserLoginKSP',
        value: jsonEncode(result['objectData']),
      );
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => UserInformationPage(),
      //   ),
      // );

      return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: CupertinoAlertDialog(
              title: Text(
                'อัพเดตข้อมูลเรียบร้อยแล้ว',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              content: Text(" "),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text(
                    "ตกลง",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      color: Color(0xFF9A1120),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => HomePage()),
                      (Route<dynamic> route) => false,
                    );
                    // goBack();
                    // Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      );
    } else {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: CupertinoAlertDialog(
              title: Text(
                'อัพเดตข้อมูลไม่สำเร็จ',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              content: Text(
                result['message'],
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Kanit',
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text(
                    "ตกลง",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Kanit',
                      color: Color(0xFF9A1120),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  // Future<dynamic> submitUpdateUser() async {
  //   var value = await storage.read(key: 'dataUserLoginDDPM');
  //   var user = json.decode(value!);
  //   print('-------user-------->> ${user}');
  //   user['imageUrl'] = _imageUrl;
  //   user['prefixName'] = txtPrefixName.text;
  //   user['firstName'] = txtFirstName.text;
  //   user['lastName'] = txtLastName.text;
  //   user['email'] = txtEmail.text;
  //   user['phone'] = txtPhone.text;

  //   user['birthDay'] = DateFormat("yyyyMMdd").format(
  //     DateTime(
  //       _selectedYear,
  //       _selectedMonth,
  //       _selectedDay,
  //     ),
  //   );
  //   user['sex'] = _selectedSex;
  //   // user['address'] = txtAddress.text;
  //   // user['soi'] = txtSoi.text;
  //   // user['moo'] = txtMoo.text;
  //   // user['road'] = txtRoad.text;
  //   // user['tambon'] = '';
  //   // user['amphoe'] = '';
  //   // user['province'] = '';
  //   // user['postno'] = '';
  //   // user['tambonCode'] = _selectedSubDistrict;
  //   // user['amphoeCode'] = _selectedDistrict;
  //   // user['provinceCode'] = _selectedProvince;
  //   // user['postnoCode'] = _selectedPostalCode;
  //   user['idcard'] = txtIdCard.text;
  //   // user['officerCode'] = txtOfficerCode.text;
  //   // user['linkAccount'] =
  //   //     user['linkAccount'] != null ? user['linkAccount'] : '';
  //   // user['appleID'] = user['appleID'] != null ? user['appleID'] : "";

  //   final result = await postObjectData('/m/register/update', user);

  //   if (result['status'] == 'S') {
  //     await storage.write(
  //       key: 'dataUserLoginDDPM',
  //       value: jsonEncode(result['objectData']),
  //     );
  //     // Navigator.pushReplacement(
  //     //   context,
  //     //   MaterialPageRoute(
  //     //     builder: (context) => UserInformationPage(),
  //     //   ),
  //     // );

  //     return showDialog(
  //       barrierDismissible: false,
  //       context: context,
  //       builder: (BuildContext context) {
  //         return WillPopScope(
  //           onWillPop: () {
  //             return Future.value(false);
  //           },
  //           child: CupertinoAlertDialog(
  //             title: new Text(
  //               'อัพเดตข้อมูลเรียบร้อยแล้ว',
  //               style: const TextStyle(
  //                 fontSize: 16,
  //                 fontFamily: 'Sarabun',
  //                 color: Colors.black,
  //                 fontWeight: FontWeight.normal,
  //               ),
  //             ),
  //             content: const Text(" "),
  //             actions: [
  //               CupertinoDialogAction(
  //                 isDefaultAction: true,
  //                 child: new Text(
  //                   "ตกลง",
  //                   style: const TextStyle(
  //                     fontSize: 13,
  //                     fontFamily: 'Sarabun',
  //                     color: Color(0xFF000070),
  //                     fontWeight: FontWeight.normal,
  //                   ),
  //                 ),
  //                 onPressed: () {
  //                   // Navigator.of(context).pushAndRemoveUntil(
  //                   //   MaterialPageRoute(
  //                   //     builder: (context) => Menu(),
  //                   //   ),
  //                   //   (Route<dynamic> route) => false,
  //                   // );
  //                   goBack();
  //                 },
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //     );
  //   } else {
  //     return showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return WillPopScope(
  //           onWillPop: () {
  //             return Future.value(false);
  //           },
  //           child: CupertinoAlertDialog(
  //             title: new Text(
  //               'อัพเดตข้อมูลไม่สำเร็จ',
  //               style: const TextStyle(
  //                 fontSize: 16,
  //                 fontFamily: 'Sarabun',
  //                 color: Colors.black,
  //                 fontWeight: FontWeight.normal,
  //               ),
  //             ),
  //             content: new Text(
  //               result['message'],
  //               style: const TextStyle(
  //                 fontSize: 13,
  //                 fontFamily: 'Sarabun',
  //                 color: Colors.black,
  //                 fontWeight: FontWeight.normal,
  //               ),
  //             ),
  //             actions: [
  //               CupertinoDialogAction(
  //                 isDefaultAction: true,
  //                 child: new Text(
  //                   "ตกลง",
  //                   style: const TextStyle(
  //                     fontSize: 13,
  //                     fontFamily: 'Sarabun',
  //                     color: Color(0xFF000070),
  //                     fontWeight: FontWeight.normal,
  //                   ),
  //                 ),
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //     );
  //   }
  // }

  readStorage() async {
    var value = await storage.read(key: 'dataUserLoginOPEC');
    var user = json.decode(value!);

    if (user['code'] != '') {
      setState(() {
        _imageUrl = user['imageUrl'];
        txtFirstName.text = user['firstName'];
        txtLastName.text = user['lastName'];
        txtEmail.text = user['email'];
        txtPhone.text = user['phone'];
        txtPrefixName.text = user['prefixName'];
        _selectedProvince = user['provinceCode'];
        _selectedDistrict = user['amphoeCode'];
        _selectedSubDistrict = user['tambonCode'];
        _selectedPostalCode = user['postnoCode'];
      });

      if (user['birthDay'] != '') {
        var date = user['birthDay'];
        var year = date.substring(0, 4);
        var month = date.substring(4, 6);
        var day = date.substring(6, 8);
        DateTime todayDate = DateTime.parse(year + '-' + month + '-' + day);

        setState(() {
          _selectedYear = todayDate.year;
          _selectedMonth = todayDate.month;
          _selectedDay = todayDate.day;
          txtDate.text = DateFormat("dd-MM-yyyy").format(todayDate);
        });
      }

      if (_selectedProvince != '') {
        getProvince();
        getDistrict();
        getSubDistrict();
        getPostalCode();
        // setState(() {
        //   futureModel = getUser();
        // });
      } else {
        getProvince();
        // setState(() {
        //   futureModel = getUser();
        // });
      }
    }
  }

  card() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Padding(padding: EdgeInsets.all(15), child: contentCard()),
    );
  }

  dialogOpenPickerDate() {
    datatTimePicker.DatePicker.showDatePicker(context,
        theme: datatTimePicker.DatePickerTheme(
          containerHeight: 210.0,
          itemStyle: TextStyle(
            fontSize: 16.0,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.normal,
            fontFamily: 'Sarabun',
          ),
          doneStyle: TextStyle(
            fontSize: 16.0,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.normal,
            fontFamily: 'Sarabun',
          ),
          cancelStyle: TextStyle(
            fontSize: 16.0,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.normal,
            fontFamily: 'Sarabun',
          ),
        ),
        showTitleActions: true,
        minTime: DateTime(1800, 1, 1),
        maxTime: DateTime(year, month, day), onConfirm: (date) {
      setState(
        () {
          _selectedYear = date.year;
          _selectedMonth = date.month;
          _selectedDay = date.day;
          txtDate.value = TextEditingValue(
            text: DateFormat("dd-MM-yyyy").format(date),
          );
        },
      );
    },
        currentTime: DateTime(
          _selectedYear,
          _selectedMonth,
          _selectedDay,
        ),
        locale: datatTimePicker.LocaleType.th);
  }

  contentCard() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          controller: scrollController,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 5.0),
            ),
            Text(
              'ข้อมูลผู้ใช้งาน',
              style: TextStyle(
                fontSize: 18.00,
                fontFamily: 'Sarabun',
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 5.0),
            labelTextFormField('* ชื่อผู้ใช้งาน'),
            textFormField(
              txtUsername,
              null,
              'ชื่อผู้ใช้งาน',
              'ชื่อผู้ใช้งาน',
              false,
              false,
              false,
            ),
            SizedBox(height: 15.0),
            Text(
              'ข้อมูลส่วนตัว',
              style: TextStyle(
                fontSize: 18.00,
                fontFamily: 'Sarabun',
                fontWeight: FontWeight.w500,
              ),
            ),
            labelTextFormField('* คำนำหน้า'),
            textFormField(
              txtPrefixName,
              null,
              'คำนำหน้า',
              'คำนำหน้า',
              true,
              false,
              false,
            ),
            labelTextFormField('* ชื่อ'),
            textFormField(
              txtFirstName,
              null,
              'ชื่อ',
              'ชื่อ',
              true,
              false,
              false,
            ),
            labelTextFormField('* นามสกุล'),
            textFormField(
              txtLastName,
              null,
              'นามสกุล',
              'นามสกุล',
              true,
              false,
              false,
            ),
            labelTextFormField('* วันเดือนปีเกิด'),
            GestureDetector(
              onTap: () => dialogOpenPickerDate(),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: txtDate,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Sarabun',
                    fontSize: 15.0,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFfffadd),
                    contentPadding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                    hintText: "วันเดือนปีเกิด",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    errorStyle: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Sarabun',
                      fontSize: 10.0,
                    ),
                  ),
                ),
              ),
            ),
            labelTextFormField('* รหัสประจำตัวประชาชน'),
            textFormIdCardField(
              txtIdCard,
              'รหัสประจำตัวประชาชน',
              'รหัสประจำตัวประชาชน',
              true,
            ),
            labelTextFormField('* เบอร์โทรศัพท์ (10 หลัก)'),
            textFormPhoneField(
              txtPhone,
              'เบอร์โทรศัพท์ (10 หลัก)',
              'เบอร์โทรศัพท์ (10 หลัก)',
              true,
              false,
            ),
            labelTextFormField('* อีเมล์'),
            textFormFieldNoValidator(
              txtEmail,
              'อีเมล์',
              false,
              false,
            ),
            labelTextFormField('* เพศ'),
            new Container(
              width: 5000.0,
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFfffadd),
                borderRadius: BorderRadius.circular(
                  10,
                ),
              ),
              child: _selectedSex != ''
                  ? DropdownButtonFormField(
                      decoration: const InputDecoration(
                        errorStyle: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Sarabun',
                          fontSize: 10.0,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      validator: (value) =>
                          value == '' || value == null ? 'กรุณาเลือกเพศ' : null,
                      hint: const Text(
                        'เพศ',
                        style: TextStyle(
                          fontSize: 15.00,
                          fontFamily: 'Sarabun',
                        ),
                      ),
                      value: _selectedSex,
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        new TextEditingController().clear();
                      },
                      onChanged: (newValue) {
                        setState(() {
                          _selectedSex = newValue.toString();
                        });
                      },
                      items: _itemSex.map((item) {
                        return DropdownMenuItem(
                          child: new Text(
                            item['title'],
                            style: const TextStyle(
                              fontSize: 15.00,
                              fontFamily: 'Sarabun',
                              color: Color(
                                0xFF9A1120,
                              ),
                            ),
                          ),
                          value: item['code'],
                        );
                      }).toList(),
                    )
                  : DropdownButtonFormField(
                      decoration: const InputDecoration(
                        errorStyle: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Sarabun',
                          fontSize: 10.0,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      validator: (value) =>
                          value == '' || value == null ? 'กรุณาเลือกเพศ' : null,
                      hint: const Text(
                        'เพศ',
                        style: TextStyle(
                          fontSize: 15.00,
                          fontFamily: 'Sarabun',
                        ),
                      ),
                      // value: _selectedSex,
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        new TextEditingController().clear();
                      },
                      onChanged: (newValue) {
                        setState(() {
                          _selectedSex = newValue.toString();
                        });
                      },
                      items: _itemSex.map((item) {
                        return DropdownMenuItem(
                          child: new Text(
                            item['title'],
                            style: const TextStyle(
                              fontSize: 15.00,
                              fontFamily: 'Sarabun',
                              color: Color(
                                0xFF9A1120,
                              ),
                            ),
                          ),
                          value: item['code'],
                        );
                      }).toList(),
                    ),
            ),
            Center(
              child: Container(
                width: 200,
                margin: EdgeInsets.symmetric(vertical: 40.0),
                child: Material(
                  elevation: 2.0,
                  borderRadius: BorderRadius.circular(5.0),
                  color: Theme.of(context).primaryColor,
                  child: MaterialButton(
                    height: 40,
                    onPressed: () {
                      final form = _formKey.currentState;
                      if (form!.validate()) {
                        form.save();
                        submitUpdateUser();
                      }
                    },
                    child: new Text(
                      'บันทึกข้อมูล',
                      style: new TextStyle(
                        fontSize: 13.0,
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Sarabun',
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

  rowContentButton(String urlImage, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Container(
            child: new Padding(
              padding: EdgeInsets.all(5.0),
              child: Image.asset(
                urlImage,
                height: 5.0,
                width: 5.0,
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Color(0xFF0B5C9E),
            ),
            width: 30.0,
            height: 30.0,
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.63,
            margin: EdgeInsets.only(left: 10.0, right: 10.0),
            child: Text(
              title,
              style: new TextStyle(
                fontSize: 12.0,
                color: Color(0xFF9A1120),
                fontWeight: FontWeight.normal,
                fontFamily: 'Sarabun',
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            child: Image.asset(
              "assets/icons/Group6232.png",
              height: 20.0,
              width: 20.0,
            ),
          ),
        ],
      ),
    );
  }

  _imgFromCamera() async {
    final ImagePicker _picker = ImagePicker();
    // Pick an image
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
    _upload();
  }

  _imgFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    // Pick an image
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
    _upload();
  }

  void _upload() async {
    if (_image == null) return;

    uploadImage(_image!).then((res) {
      setState(() {
        _imageUrl = res;
      });
    }).catchError((err) {
      print(err);
    });
  }

  void _showPickerImage(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: Text(
                      'อัลบั้มรูปภาพ',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Sarabun',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text(
                    'กล้องถ่ายรูป',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Sarabun',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void goBack() async {
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, goBack, title: 'แก้ไขข้อมูล'),
      backgroundColor: Color(0xFFF5F8FB),
      body: FutureBuilder<dynamic>(
        future: futureModel,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Container(
              color: Colors.white,
              child: dialogFail(context),
            ));
          } else {
            return Container(
              child: ListView(
                controller: scrollController,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      // Container(
                      //   decoration: BoxDecoration(
                      //     image: DecorationImage(
                      //       fit: BoxFit.fill,
                      //       image: AssetImage(
                      //         'assets/background/backgroundUserInfo.png',
                      //       ),
                      //     ),
                      //   ),
                      //   height: 150.0,
                      // ),
                      // Container(
                      //   height: 150.0,
                      //   decoration: BoxDecoration(
                      //     image: DecorationImage(
                      //       fit: BoxFit.fill,
                      //       image: AssetImage(
                      //         'assets/background/backgroundUserInfoColor.png',
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Center(
                        child: Container(
                          width: 96.0,
                          height: 96.0,
                          margin: EdgeInsets.only(top: 30.0),
                          padding: EdgeInsets.all(
                              _imageUrl != null && _imageUrl != '' ? 0.0 : 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(48),
                          ),
                          child: _imageUrl != null && _imageUrl != ''
                              ? CircleAvatar(
                                  backgroundColor: Colors.black,
                                  backgroundImage:
                                      _imageUrl != null && _imageUrl != ''
                                          ? NetworkImage(_imageUrl!)
                                          : null,
                                )
                              : Container(
                                  padding: EdgeInsets.all(10.0),
                                  child: Image.asset(
                                    'assets/images/user_not_found.png',
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                        ),
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            _showPickerImage(context);
                          },
                          child: Container(
                            width: 31.0,
                            height: 31.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Theme.of(context).primaryColor,
                            ),
                            margin: EdgeInsets.only(top: 90.0, left: 70.0),
                            child: Container(
                              padding: EdgeInsets.all(5.0),
                              child:
                                  Image.asset('assets/logo/icons/Group37.png'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    child: contentCard(),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
