import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../apptheme.dart';
import '../../component/blurred_network_image.dart';
import '../../component/korat_ui.dart';
import '../../shared/api_provider.dart';
import '../../widget/text_form_field.dart';
import 'reporter_history_list.dart';
import 'reporter_local_store.dart';

class ReporterFormPage extends StatefulWidget {
  ReporterFormPage({
    super.key,
    this.title,
    this.code,
    this.imageUrl,
  });

  final String? title;
  final String? code;
  final String? imageUrl;

  @override
  _ReporterFormPageState createState() => _ReporterFormPageState();
}

class _ReporterFormPageState extends State<ReporterFormPage> {
  final storage = new FlutterSecureStorage();

  final _formKey = GlobalKey<FormState>();

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

  final txtTitle = TextEditingController();
  final txtDescription = TextEditingController();
  double latitude = 13.743894;
  double longitude = 100.538592;

  String? currentLocation;
  bool isShowMap = true;

  List<dynamic> _itemImage = [];
  List<Marker> markers = [];
  List<Marker> markerSelect = [];

  addMarker(latLng, newSetState) {
    setState(() {
      latitude = latLng.latitude;
      longitude = latLng.longitude;
    });
    newSetState(() {
      markers.clear();

      markers.add(Marker(markerId: const MarkerId('New'), position: latLng));
    });
  }

  selectMarker() async {
    setState(() {
      markerSelect = markers;
      isShowMap = true;
    });
  }

  DateTime selectedDate = DateTime.now();
  TextEditingController txtDate = TextEditingController();

  Future<dynamic>? futureModel;

  ScrollController scrollController = new ScrollController();

  XFile? _image;

  int year = 0;
  int month = 0;
  int day = 0;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtEmail.dispose();
    txtPassword.dispose();
    txtConPassword.dispose();
    txtFirstName.dispose();
    txtLastName.dispose();
    txtPhone.dispose();
    txtDate.dispose();
    txtTitle.dispose();
    txtDate.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _getLocation();
    futureModel = _getCurrentPosition();

    scrollController = ScrollController();

    super.initState();
  }

  Future<dynamic> _getCurrentPosition() async {
    // fixflutter2 var res = await getCurrentPosition();
    // setState(() {
    //   latitude = res.latitude;
    //   longitude = res.longitude;
    //   markers.add(
    //     Marker(
    //       markerId: MarkerId('New'),
    //       position: LatLng(res.latitude, res.longitude),
    //     ),
    //   );
    // });
  }

  void _getLocation() async {
    // fixflutter2 Position position = await getCurrentPosition(
    //   desiredAccuracy: LocationAccuracy.best,
    // );

    // final coordinates = new Coordinates(position.latitude, position.longitude);

    // var address = await Geocoder.google(
    //   'AIzaSyD-pkE26l2sWEU_CrbDz6b2myMe5Ab7jJo',
    //   language: 'th',
    // ).findAddressesFromCoordinates(coordinates);

    // setState(() {
    //   currentLocation = address.first.adminArea;
    // });
  }

  Future<dynamic> submitReporter() async {
    var value = await storage.read(key: 'dataUserLoginDDPM');
    var user = value == null || value.isEmpty
        ? <String, dynamic>{}
        : json.decode(value);

    var data = {
      "title": txtTitle.text,
      "enTitle": txtTitle.text,
      "description": txtDescription.text,
      "enDescription": txtDescription.text,
      "category": widget.code,
      "latitude": latitude.toString(),
      "longitude": longitude.toString(),
      "createBy": user['username'] ?? '',
      "firstName": user['firstName'] ?? '',
      "lastName": user['lastName'] ?? '',
      "imageUrlCreateBy": user['imageUrl'] ?? '',
      "imageUrl": widget.imageUrl,
      "gallery": _itemImage,
      "province": currentLocation ?? '',
      "lv0": user['lv0'] ?? '',
      "lv1": user['lv1'] ?? '',
      "lv2": user['lv2'] ?? '',
      "lv3": user['lv3'] ?? '',
      "lv4": user['lv4'] ?? '',
      "language": 'th',
      "platform": Platform.operatingSystem.toString(),
    };

    try {
      await postObjectData('/m/Reporter/create', data);
    } catch (_) {}

    final firstImage = _itemImage.isNotEmpty
        ? _itemImage.first['imageUrl']?.toString() ?? ''
        : '';
    ReporterLocalStore.add(
      title: txtTitle.text.trim(),
      category: widget.title ?? 'เรื่องร้องทุกข์',
      description: txtDescription.text.trim(),
      imageUrl: firstImage,
    );
    final reportCode = ReporterLocalStore.reports.isNotEmpty
        ? ReporterLocalStore.reports.first['code']
        : 'KRT-REPORTER';

    if (!mounted) return;

    return showGeneralDialog(
      barrierDismissible: false,
      context: context,
      barrierLabel: 'success',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (BuildContext ctx, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(ctx).size.width * 0.85,
              constraints: const BoxConstraints(maxWidth: 350),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
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
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF10B981),
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ส่งข้อมูลร้องทุกข์สำเร็จ',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'เรื่องของคุณถูกบันทึกเข้าระบบแล้ว\nรหัสติดตาม: $reportCode',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Sarabun',
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) =>
                                const ReporterHistoryList(title: 'ติดตามปัญหา'),
                          ),
                        );
                      },
                      child: const Text(
                        'ติดตามสถานะเรื่องนี้',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'กลับหน้าหลัก',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 13.5,
                          color: AppColors.textSecondary,
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
    );
  }

  contentCard() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          controller: scrollController,
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 5.0),
            ),
            const Text(
              '* หัวข้อ',
              style: TextStyle(
                fontSize: 18.00,
                fontFamily: 'Sarabun',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5.0),
            textFormField(
              txtTitle,
              null,
              'หัวข้อ',
              'หัวข้อ',
              true,
              false,
              false,
            ),
            const SizedBox(height: 15.0),
            const Text(
              '* รายละเอียด',
              style: TextStyle(
                fontSize: 18.00,
                fontFamily: 'Sarabun',
                fontWeight: FontWeight.w500,
              ),
            ),
            TextFormField(
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.normal,
                fontFamily: 'Sarabun',
                fontSize: 15.00,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                hintText: 'รายละเอียดปัญหาที่ต้องการแจ้ง',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                errorStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Sarabun',
                  fontSize: 10.0,
                ),
              ),
              validator: (model) {
                if (model!.isEmpty) {
                  return 'กรุณากรอกรายละเอียด.';
                }
                return null;
              },
              controller: txtDescription,
              enabled: true,
              keyboardType: TextInputType.multiline,
              minLines: 1, //Normal textInputField will be displayed
              maxLines: null,
            ),
            const SizedBox(height: 15.0),
            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'เพิ่มรูปภาพ',
                        style: TextStyle(
                          fontSize: 18.00,
                          fontFamily: 'Sarabun',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'สามารถอัพโหลดรูปภาพได้เกิน 10 รูป',
                        style: TextStyle(
                          fontSize: 12.00,
                          fontFamily: 'Sarabun',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 35.0,
                        height: 35.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD84315),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: MaterialButton(
                          onPressed: () {
                            _showPickerImage(context);
                          },
                          padding: const EdgeInsets.all(5.0),
                          child: Image.asset(
                            'assets/logo/icons/picture.png',
                            height: 20.0,
                            width: 20.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_itemImage.length > 0)
              Container(
                padding: const EdgeInsets.only(top: 10.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1 / 1,
                  ),
                  physics: const ClampingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _itemImage.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(top: 5.0),
                      width: 400,
                      child: MaterialButton(
                        onPressed: () {
                          dialogDeleteImage(_itemImage[index]['id'].toString());
                        },
                        child: BlurredNetworkImage(
                          imageUrl: '${_itemImage[index]['imageUrl'] ?? ''}',
                          width: 1000,
                        ),
                        // ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 15.0),
            const Text(
              'ตำแหน่ง',
              style: TextStyle(
                fontSize: 18.00,
                fontFamily: 'Sarabun',
                fontWeight: FontWeight.w500,
              ),
            ),
            if (markerSelect.length > 0 && isShowMap)
              Container(
                height: 250.0,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      latitude,
                      longitude,
                    ),
                    zoom: 14,
                  ),
                  markers: markerSelect.toSet(),
                ),
              ),
            Container(
              margin: const EdgeInsets.only(top: 10.0),
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              // padding: EdgeInsets.symmetric(horizontal: 80.0),
              child: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                      color: const Color(0xFFD84315),
                    ),
                  ),
                  child: MaterialButton(
                    minWidth: MediaQuery.of(context).size.width,
                    onPressed: () {
                      setState(() {
                        isShowMap = false;
                      });

                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: MaterialLocalizations.of(context)
                            .modalBarrierDismissLabel,
                        barrierColor: Colors.black45,
                        transitionDuration: const Duration(milliseconds: 200),
                        pageBuilder: (
                          BuildContext context,
                          Animation animation,
                          Animation secondaryAnimation,
                        ) {
                          return StatefulBuilder(
                            builder: (context, newSetState) {
                              return Center(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  padding: const EdgeInsets.all(0),
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.9,
                                        child: GoogleMap(
                                          initialCameraPosition: CameraPosition(
                                            target: LatLng(
                                              latitude,
                                              longitude,
                                            ),
                                            zoom: 14,
                                          ),
                                          markers: markers.toSet(),
                                          onTap: (newLatLng) {
                                            addMarker(newLatLng, newSetState);
                                          },
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          selectMarker();
                                          Navigator.of(context).pop();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                        ),
                                        child: const Text(
                                          'ตกลง',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontFamily: 'Sarabun',
                                            color: Color(0xFFFFFFFF),
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    child: const Text(
                      'ตำแหน่ง Google Map',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontFamily: 'Sarabun',
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                child: Material(
                  elevation: 2.0,
                  borderRadius: BorderRadius.circular(12.0),
                  color: AppColors.primary,
                  child: MaterialButton(
                    height: 48,
                    onPressed: () {
                      final form = _formKey.currentState;
                      if (form!.validate()) {
                        form.save();
                        submitReporter();
                      }
                    },
                    child: const Text(
                      'บันทึกข้อมูล',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Kanit',
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

  dialogDeleteImage(String code) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
        title: new Text(
          'ต้องการลบรูปภาพ ใช่ไหม',
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Sarabun',
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
        content: new Text(''),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text(
              "ยกเลิก",
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'Sarabun',
                color: Color(0xFFBF360C),
                fontWeight: FontWeight.normal,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text(
              "ลบ",
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'Sarabun',
                color: Color(0xFFD84315),
                fontWeight: FontWeight.normal,
              ),
            ),
            onPressed: () {
              deleteImage(code);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  deleteImage(String code) async {
    setState(() {
      _itemImage.removeWhere((c) => c['id'].toString() == code.toString());
    });
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

    Random random = new Random();
    uploadImage(_image!).then((res) {
      setState(() {
        _itemImage.add({'imageUrl': res, 'id': random.nextInt(100)});
      });
      // setState(() {
      //   _imageUrl = res;
      // });
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
                  title: new Text(
                    'อัลบั้มรูปภาพ',
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'Sarabun',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    _imgFromGallery();
                    Navigator.of(context).pop();
                  },
                ),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text(
                    'กล้องถ่ายรูป',
                    style: const TextStyle(
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
    Navigator.pop(context);
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ReporterListCategory(),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    // return FutureBuilder<dynamic>(
    // future: futureModel,
    // builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    //   if (snapshot.connectionState == ConnectionState.waiting) {
    //     return Center(
    //       child: Image.asset(
    //         "assets/background/login.png",
    //         fit: BoxFit.cover,
    //       ),
    //     );
    //   } else {
    //     if (snapshot.hasError)
    //       return Center(child: Text('Error: ${snapshot.error}'));
    //     else
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: KoratAppBar(
        title: widget.title ?? 'แจ้งปัญหา',
        showBack: true,
        onBack: goBack,
      ),
      body: ListView(
        controller: scrollController,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        children: <Widget>[
          Container(
            color: AppColors.surface,
            child: contentCard(),
          ),
        ],
      ),
    );
    // }
//       },
//     );
  }
}
