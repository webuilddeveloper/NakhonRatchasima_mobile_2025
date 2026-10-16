import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ratchasima/component/key_search.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../component/header.dart';
import '../../apptheme.dart';
import '../../shared/api_provider.dart';
import 'event_calendar_list_vertical.dart';

class EventCalendarList extends StatefulWidget {
  EventCalendarList({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _EventCalendarList createState() => _EventCalendarList();
}

class _EventCalendarList extends State<EventCalendarList> {
  final storage = FlutterSecureStorage();

  late EventCalendarList eventCalendarList;
  late EventCalendarListVertical gridView;

  bool hideSearch = true;
  List<dynamic> listData = [];
  List<dynamic> category = [];
  bool isMain = true;
  String categorySelected = '';
  String keySearch = '';
  bool isHighlight = false;
  int _limit = 10;

  RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    // _futureEventCalendarCategory =
    //     post('${eventCalendarCategoryApi}read', {'skip': 0, 'limit': 100});
    _read();
    super.initState();
  }

  void goBack() async {
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: header(context, goBack, title: widget.title),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overScroll) {
          return false;
        },
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(
            children: [
              const SizedBox(height: 12.0),
              KeySearch(
                show: hideSearch,
                hintext: 'ค้นหากิจกรรม',
                onKeySearchChange: (String val) {
                  setState(() {
                    keySearch = val;
                  });
                },
              ),
              const SizedBox(height: 12.0),
              _buildCategory(),
              const SizedBox(height: 12.0),
              Expanded(
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
                  child: ListView(children: [_buildList()]),
                ),
              ),
              SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }

  _buildCategory() {
    return FutureBuilder<dynamic>(
      future: postCategory('${eventCalendarCategoryApi}read', {
        'skip': 0,
        'limit': 100,
      }), // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          return Container(
            height: 48.0,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                final tabWidth = (MediaQuery.of(context).size.width - 48) /
                    snapshot.data.length;
                return GestureDetector(
                  onTap: () {
                    if (snapshot.data[index]['code'] != '') {
                      setState(() {
                        // keySearch = '';
                        // isMain = false;
                        categorySelected = snapshot.data[index]['code'];
                      });
                    } else {
                      setState(() {
                        // isHighlight = true;
                        categorySelected = '';
                        isMain = true;
                      });
                    }
                    setState(() {
                      categorySelected = snapshot.data[index]['code'];
                      // selectedIndex = index;
                    });
                  },
                  child: SizedBox(
                    width: tabWidth,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: categorySelected == snapshot.data[index]['code']
                            ? AppColors.primarySoft
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        snapshot.data[index]['title'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: categorySelected == snapshot.data[index]['code']
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontSize: 14.0,
                          fontWeight: categorySelected == snapshot.data[index]['code']
                              ? FontWeight.w600
                              : FontWeight.w400,
                          fontFamily: 'Kanit',
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return Container(
            height: 48.0,
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(14.0),
            ),
          );
        }
      },
    );
  }

  _buildList() {
    return gridView = EventCalendarListVertical(
      model: post('${eventCalendarApi}read', {
        'skip': 0,
        'limit': _limit,
        'keySearch': keySearch,
        'isHighlight': isHighlight,
        'category': categorySelected,
      }),
      urlGallery: eventCalendarGalleryApi,
      urlComment: eventCalendarCommentApi,
      url: '${eventCalendarApi}read',
    );
  }

  _onLoading() async {
    setState(() {
      _limit = _limit + 10;

      gridView = EventCalendarListVertical(
        model: post('${eventCalendarApi}read', {
          'skip': 0,
          'limit': _limit,
          'keySearch': keySearch,
          'isHighlight': isHighlight,
          'category': categorySelected,
        }),
        urlGallery: eventCalendarGalleryApi,
        urlComment: eventCalendarCommentApi,
        url: '${eventCalendarApi}read',
      );
    });

    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  _read() async {
    // var profileCode = await storage.read(key: 'profileCode9');
    // if (profileCode != '' && profileCode != null) {
    var body = json.encode({
      "permission": "all",
      "skip": 0,
      "limit": 999, // integer value type
    });
    var response = await http.post(
      Uri.parse('${eventCalendarCategoryApi}read'),
      body: body,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
    );

    var data = json.decode(response.body);
    setState(() {
      category = data['objectData'];
    });

    if (category.length > 0) {
      for (int i = 0; i <= category.length - 1; i++) {
        var res = post('${eventCalendarApi}read', {
          'skip': 0,
          'limit': 100,
          'category': category[i]['code'],
          'keySearch': keySearch,
          // 'profileCode': profileCode
        });
        listData.add(res);
      }
    }
    // }
  }
}
