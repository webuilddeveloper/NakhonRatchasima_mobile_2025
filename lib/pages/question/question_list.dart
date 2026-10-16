import 'package:flutter/material.dart';
import 'package:ratchasima/component/header.dart';
import 'package:ratchasima/pages/question/question_list_form.dart';

import '../../shared/api_provider.dart';
import 'question_list_vertical.dart';

class QuestionList extends StatefulWidget {
  QuestionList({super.key, this.title});
  final String? title;
  @override
  _QuestionList createState() => _QuestionList();
}

class _QuestionList extends State<QuestionList> {
  QuestionListVertical? contact;
  bool hideSearch = true;
  final txtDescription = TextEditingController();
  String? keySearch;
  String? category;

  dynamic _model = [
    {
      'code': '1',
      'title': 'สอบถามหน่อยครับ',
      'description': 'สอบถามหน่อยครับ',
      'date': '3 วัน ที่ผ่านมา',
      'createDate': '20/06/2025 5:32 pm',
      'view': '535',
      'userName': 'Xxxx1'
    },
  ];

  // final ScrollController _controller = ScrollController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtDescription.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void goBack() async {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, goBack, title: 'ถาม - ตอบ'),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overScroll) {
          overScroll.disallowIndicator();
          return false;
        },
        child: ListView(
          physics: ScrollPhysics(),
          shrinkWrap: true,
          children: [
            SizedBox(height: 30),
            Center(
              child: Container(
                // height: 200,
                width: double.infinity,
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border(
                    left: BorderSide(color: Colors.purple, width: 3),
                  ),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'ถาม - ตอบ',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Kanit'),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Material(
                        elevation: 2.0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          side: BorderSide(
                            color: Color(0xFFC9166D),
                            width: 2.0,
                          ),
                        ),
                        child: MaterialButton(
                          height: 30,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuestionListForm(),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: Color(0xFFC9166D),
                              ),
                              SizedBox(width: 5),
                              new Text(
                                'เพิ่มคำถามใหม่',
                                style: new TextStyle(
                                  fontSize: 16.0,
                                  color: Color(0xFFC9166D),
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'Kanit',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(5),
              child: Text(
                'รายการคำถาม',
                style: new TextStyle(
                  fontSize: 18.0,
                  color: Color(0xFF000000),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Kanit',
                ),
                textAlign: TextAlign.left,
              ),
            ),
            QuestionListVertical(
              site: "DDPM",
              model: Future.value(_model),
              title: "",
              url: '${contactCategoryApi}read',
            ),
          ],
        ),
      ),
    );
  }
}
