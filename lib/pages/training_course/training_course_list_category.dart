import 'package:flutter/material.dart';
import 'package:ratchasima/component/header.dart';

import '../../shared/api_provider.dart';
import 'training_course_list_category_vertical.dart';

class TrainingCourseListCategory extends StatefulWidget {
  TrainingCourseListCategory({super.key, this.title});
  final String? title;
  @override
  _TrainingCourseListCategory createState() => _TrainingCourseListCategory();
}

class _TrainingCourseListCategory extends State<TrainingCourseListCategory> {
  TrainingCourseListCategoryVertical? contact;
  bool hideSearch = true;
  final txtDescription = TextEditingController();
  String? keySearch;
  String? category;

  dynamic _model = [
    {'code': '1', 'title': 'กลุ่มหลักสูตรพื้นฐานคนประจำเรือ'},
    {
      // 'code': '2',
      'title': 'กลุ่มหลักสูตรด้านการเดินเรือและการเรือและภาวะความเป็นผู้นำ'
    },
    {'code': '3', 'title': 'กลุ่มหลักสูตรด้านช่างกล'},
  ];

  Future<dynamic>? _futureBanner;
  Future<dynamic>? _futureCategoryContact;
  // final ScrollController _controller = ScrollController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtDescription.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _futureCategoryContact =
        post('${contactCategoryApi}read', {'skip': 0, 'limit': 999});

    _futureBanner = post('${contactBannerApi}read', {'skip': 0, 'limit': 50});

    // _controller.addListener(_scrollListener);
    super.initState();
    // contact = new TrainingCourseListCategoryVertical(
    //   site: "DDPM",
    //   model: service
    //       .post('${service.contactCategoryApi}read', {'skip': 0, 'limit': 100}),
    //   title: "",
    //   url: '${service.contactCategoryApi}read',
    // );
  }

  void goBack() async {
    Navigator.pop(context, true);
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => Menu(),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, goBack, title: 'หลักสูตรอบรม'),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overScroll) {
          overScroll.disallowIndicator();
          return false;
        },
        child: ListView(
          physics: ScrollPhysics(),
          shrinkWrap: true,
          children: [
            SizedBox(height: 50),
            TrainingCourseListCategoryVertical(
              site: "DDPM",
              model: Future.value(_model),
              title: "",
              url: '${contactCategoryApi}read',
            ),
            // Expanded(
            //   child: contact,
            // ),
          ],
        ),
      ),
    );
  }
}
