import 'package:flutter/material.dart';
import 'package:ratchasima/component/header.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../component/key_search.dart';
import '../../shared/api_provider.dart';
import '../../shared/mock_repository.dart';
import 'training_course_list_vertical.dart';

class TrainingCourseList extends StatefulWidget {
  TrainingCourseList({
    super.key,
    this.title,
    this.code,
  });

  final String? title;
  final String? code;

  @override
  _TrainingCourseList createState() => _TrainingCourseList();
}

class _TrainingCourseList extends State<TrainingCourseList> {
  TrainingCourseListVertical? contact;
  bool hideSearch = true;
  final txtDescription = TextEditingController();
  String? keySearch;
  String? category;
  int _limit = 10;
  dynamic _model = [];
  dynamic _tempModel = KoratMockRepository.getTrainingCourses();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Future<dynamic>? _futureContact;

  // final ScrollController _controller = ScrollController();
  @override
  void dispose() {
    txtDescription.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _model = (widget.code != null && widget.code!.isNotEmpty)
        ? _tempModel.where((i) => i['category'] == widget.code).toList()
        : _tempModel;

    super.initState();
  }

  void _onLoading() async {
    setState(() {
      _limit = _limit + 10;
      _model = _tempModel
          .where((i) =>
              i['category'] == widget.code &&
              (i['title']?.toString().toLowerCase() ?? "")
                  .contains(keySearch!.toLowerCase()))
          .toList();
      contact = new TrainingCourseListVertical(
        site: "DDPM",
        model: Future.value(_model),
        title: "",
        url: '${contactApi}read',
      );
    });

    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  void goBack() async {
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: header(context, goBack, title: 'หลักสูตรอบรม'),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overScroll) {
          overScroll.disallowIndicator();
          return false;
        },
        child: SmartRefresher(
          enablePullDown: false,
          enablePullUp: true,
          footer: ClassicFooter(
            loadingText: ' ',
            canLoadingText: ' ',
            idleText: ' ',
            idleIcon: Icon(
              Icons.arrow_upward,
              color: Colors.transparent,
            ),
          ),
          controller: _refreshController,
          onLoading: _onLoading,
          child: ListView(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            // controller: _controller,
            children: [
              // SubHeader(th: widget.title, en: ""),
              SizedBox(height: 10),
              KeySearch(
                show: hideSearch,
                hintext: 'ค้นหาหลักสูตรอบรม',
                onKeySearchChange: (String val) {
                  setState(
                    () {
                      keySearch = val;
                      _model = _tempModel
                          .where((i) =>
                              i['category'] == widget.code &&
                              (i['title']?.toString().toLowerCase() ?? "")
                                  .contains(keySearch!.toLowerCase()))
                          .toList();
                    },
                  );
                },
              ),
              SizedBox(height: 10),
              // CategorySelector(
              //   model: service.post(
              //     '${service.contactCategoryApi}read',
              //     {'skip': 0, 'limit': 100},
              //   ),
              //   onChange: (String val) {
              //     setState(() => {
              //           contact = new TrainingCourseListCategoryVertical(
              //             site: 'DDPM',
              //             model: service.post(
              //                 '${service.contactCategoryApi}read',
              //                 {'skip': 0, 'limit': 10, "category": val}),
              //             title: '',
              //             url: '${service.contactCategoryApi}read',
              //             // urlGallery: '${service.contactGalleryApi}',
              //           ),
              //         });
              //   },
              // ),
              TrainingCourseListVertical(
                site: "DDPM",
                model: Future.value(_model),
                title: "",
                url: '${contactApi}read',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
