import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:ratchasima/component/header.dart';
import 'package:ratchasima/widget/extension.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../shared/api_provider.dart';

import '../blank_page/toast_fail.dart';
import '../event_calendar/event_calendar_form.dart';
import '../knowledge/knowledge_form.dart';
import '../news/news_form.dart';
import '../poi/poi_form.dart';
import '../poll/poll_form.dart';
import '../privilege/privilege_form.dart';
import '../warning/warning_form.dart';
import '../welfare/welfare_form.dart';

class NotificationList extends StatefulWidget {
  NotificationList({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _NotificationList createState() => _NotificationList();
}

class _NotificationList extends State<NotificationList>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  Future<dynamic> _futureModel = Future.value(null);
  Future<dynamic> _futureProfile = Future.value(null);
  Future<dynamic> _futureNoti = Future.value(null);
  final storage = FlutterSecureStorage();
  final _controller = ScrollController();

  var loadingAction = false;
  int notiCount = 0;
  dynamic profileCode;
  dynamic _profile;
  List<dynamic> listData = [];
  List<dynamic> listResultData = [];
  int totalSelected = 0;
  bool isNoActive = false;
  int totalStatusActive = 0;
  bool chkListCount = false;
  bool chkListActive = false;

  bool isCheckSelect = false;
  bool isLoading = false;

  List<dynamic> listCategoryDays = [
    {'code': '1', 'title': 'วันนี้'},
    {'code': '2', 'title': 'เมื่อวาน'},
    {'code': '3', 'title': '7 วันก่อน'},
    {'code': '4', 'title': 'เก่ากว่า 7 วัน'},
    {'code': '5', 'title': 'ยังไม่อ่าน'},
  ];

  var selectedCategoryDays = "";
  var selectedCategoryDaysName = "";
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  @override
  void initState() {
    _loading();
    super.initState();
    WidgetsBinding.instance.removeObserver(this);
  }

  _readNoti() async {
    profileCode = await storage.read(key: 'profileCode2');
    if (profileCode != '' && profileCode != null) {
      setState(() {
        _futureProfile = postDio(profileReadApi, {"code": profileCode});
      });
    }
    _profile = await _futureProfile;

    if (_profile != null) {
      _futureNoti = postDio(notificationApi + 'count', {
        "username": _profile[0]["username"],
        "category": _profile[0]["category"],
      });
      var _norti = await _futureNoti;
      setState(() {
        notiCount = _norti['total'];
      });
    }
  }

  _loading() async {
    _readNoti();
    selectedCategoryDays = "";
    setState(() {
      _futureModel = postDio('${notificationApi}read', {
        'skip': 0,
        'limit': 999,
      });
    });

    var listModel = await _futureModel;
    print('Raw API Response: $listModel');
    print('Response Type: ${listModel.runtimeType}');

    List dataList = [];
    if (listModel is List) {
      dataList = listModel;
      // print('Response is List with length: ${dataList.length}');
    } else if (listModel is Map) {
      // print('Response is Map with keys: ${listModel.keys}');

      if (listModel['data'] != null) {
        dataList = listModel['data'];
        // print('Found data field with length: ${dataList.length}');
      } else if (listModel['result'] != null) {
        dataList = listModel['result'];
        // print('Found result field with length: ${dataList.length}');
      } else if (listModel['items'] != null) {
        dataList = listModel['items'];
        // print('Found items field with length: ${dataList.length}');
      }
    }

    setState(() {
      listData = [];
      listResultData = [];

      if (dataList.length > 0) {
        print('Processing ${dataList.length} items');
        for (var i = 0; i < dataList.length; i++) {
          print('Item $i: ${dataList[i]}');

          var totalDays = dataList[i]['totalDays'];
          print('totalDays for item $i: $totalDays');

          var categoryDays = "";
          if (totalDays == null) {
            categoryDays = "1";
          } else if (totalDays == 0) {
            categoryDays = "1";
          } else if (totalDays == 1) {
            categoryDays = "2";
          } else if (totalDays > 1 && totalDays <= 7) {
            categoryDays = "3";
          } else if (totalDays > 7) {
            categoryDays = "4";
          }

          print('Calculated categoryDays for item $i: $categoryDays');

          dataList[i]['categoryDays'] = categoryDays;
          dataList[i]['isSelected'] = false;
          listData.add(dataList[i]);
        }
        print('Final listData length: ${listData.length}');
      } else {
        print('No data to process - dataList is empty');
      }

      listResultData = listData;
      chkListCount = listResultData.length > 0 ? true : false;
      chkListActive =
          listData.where((x) => x['status'] != "A").toList().length > 0
              ? true
              : false;
      totalSelected = 0;
    });

    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
    // print('=== _loading END ===');
  }

  checkNavigationPage(String page, dynamic model) {
    switch (page) {
      case 'newsPage':
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsForm(
                url: '${newsApi}read',
                code: model['reference'],
                model: model,
                urlComment: newsCommentApi,
                urlGallery: newsGalleryApi,
              ),
            ),
          ).then((value) => {_loading()});
        }
        break;

      case 'eventPage':
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventCalendarForm(
                url: '${eventCalendarApi}read',
                code: model['reference'],
                model: model,
                urlComment: eventCalendarCommentApi,
                urlGallery: eventCalendarGalleryApi,
              ),
            ),
          ).then((value) => {_loading()});
        }
        break;

      case 'privilegePage':
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PrivilegeForm(code: model['reference'], model: model),
            ),
          ).then((value) => {_loading()});
        }
        break;

      case 'knowledgePage':
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  KnowledgeForm(code: model['reference'], model: model),
            ),
          ).then((value) => {_loading()});
        }
        break;

      case 'poiPage':
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PoiForm(
                url: poiApi + 'read',
                code: model['reference'],
                model: model,
                urlComment: poiCommentApi,
                urlGallery: poiGalleryApi,
              ),
            ),
          ).then((value) => {_loading()});
        }
        break;

      case 'pollPage':
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PollForm(
                code: model['reference'],
                model: model,
                url: '',
                titleMenu: '',
                titleHome: '',
              ),
            ),
          ).then((value) => {_loading()});
        }
        break;

      case 'warningPage':
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WarningForm(
                code: model['reference'],
                model: model,
                url: '',
                urlGallery: '',
              ),
            ),
          ).then((value) => {_loading()});
        }
        break;

      case 'welfarePage':
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WelfareForm(
                code: model['reference'],
                model: model,
                url: '',
                urlGallery: '',
              ),
            ),
          ).then((value) => {_loading()});
        }
        break;
      default:
        {
          return toastFail(context, text: 'เกิดข้อผิดพลาด');
        }
    }
  }

  void goBack() async {
    Navigator.pop(context);
    _loading();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 10) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: headerNoti(
          context,
          () => goBack(),
          title: widget.title,
          isButtonRight: true,
          rightButton: () => _handleClickMe(),
          menu: 'notification',
          notiCount: notiCount,
        ),
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
                SizedBox(height: 10),
                Expanded(
                  child: SmartRefresher(
                    enablePullDown: false,
                    enablePullUp: false,
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
                    onLoading: _loading,
                    child: Stack(
                      children: <Widget>[
                        isLoading
                            ? Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 4),
                              )
                            : selectedCategoryDays == ""
                                ? Container(
                                    child: FadingEdgeScrollView.fromScrollView(
                                      child: ListView(
                                        controller: _controller,
                                        physics: ClampingScrollPhysics(),
                                        children: <Widget>[
                                          for (int i = 0;
                                              i < listCategoryDays.length;
                                              i++)
                                            _builCategory(
                                              listCategoryDays[i],
                                            ),
                                        ],
                                      ),
                                    ),
                                  )
                                : listResultData.isNotEmpty
                                    ? Container(
                                        child:
                                            FadingEdgeScrollView.fromScrollView(
                                          child: ListView(
                                            controller: _controller,
                                            physics: ClampingScrollPhysics(),
                                            children: <Widget>[
                                              Container(
                                                margin:
                                                    EdgeInsets.only(left: 30),
                                                child: Text(
                                                  '$selectedCategoryDaysName',
                                                  style: TextStyle(
                                                    color: Color(0XFFfad84c),
                                                    fontFamily: 'IBMPlex',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 24,
                                                  ),
                                                ),
                                              ),
                                              for (int i = 0;
                                                  i < listResultData.length;
                                                  i++)
                                                Container(
                                                  child: cardV2(
                                                    context,
                                                    listResultData[i],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(
                                        height:
                                            MediaQuery.of(context).size.height,
                                        width:
                                            (MediaQuery.of(context).size.width),
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 40),
                                        child: Center(
                                          child: Text(
                                            textNotiEmpty(selectedCategoryDays),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Color(0xFF707070)
                                                  .withOpacity(0.5),
                                              fontFamily: 'IBMPlex',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                        isCheckSelect
                            ? Positioned(
                                top: -10.0,
                                right: 0.0,
                                child: Padding(
                                  padding: EdgeInsets.zero,
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: Color(0XFFfad84c),
                                        size: 40,
                                      ),
                                      onPressed: () {
                                        _clearSelected();
                                      },
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
                Container(
                  color: Colors.white.withOpacity(0.0),
                  height: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: (MediaQuery.of(context).size.width / 100) * 40,
                        margin: EdgeInsets.only(bottom: 22.0),
                        child: chkListActive
                            ? Material(
                                elevation: 5.0,
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0XFFfad84c),
                                child: MaterialButton(
                                  height: 30,
                                  onPressed: () {
                                    _DialogUpdate();
                                  },
                                  child: Text(
                                    totalSelected > 0
                                        ? 'อ่านแล้ว  (${totalSelected.toString()})'
                                        : 'อ่านทั้งหมด',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Color(0xFFFFFFFF),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'IBMPlex',
                                    ),
                                  ),
                                ),
                              )
                            : ElevatedButton(
                                style: ButtonStyle(
                                  padding:
                                      MaterialStateProperty.all<EdgeInsets>(
                                    EdgeInsets.all(10),
                                  ),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Colors.white,
                                  ),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        10.0,
                                      ),
                                      side: BorderSide(
                                        color: Color(0xFFB7B7B7),
                                      ),
                                    ),
                                  ),
                                ),
                                onPressed: () {},
                                child: Text(
                                  'อ่านทั้งหมด',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Color(0xFFB7B7B7),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'IBMPlex',
                                  ),
                                ),
                              ),
                      ),
                      SizedBox(width: 20),
                      Container(
                        width: (MediaQuery.of(context).size.width / 100) * 40,
                        margin: EdgeInsets.only(bottom: 22.0),
                        child: chkListCount
                            ? Material(
                                elevation: 5.0,
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0XFFfad84c),
                                child: MaterialButton(
                                  height: 30,
                                  onPressed: () async {
                                    _DialogDelete();
                                  },
                                  child: Text(
                                    totalSelected > 0
                                        ? 'ลบรายการ  (${totalSelected.toString()})'
                                        : 'ลบทั้งหมด',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Color(0xFFFFFFFF),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'IBMPlex',
                                    ),
                                  ),
                                ),
                              )
                            : ElevatedButton(
                                style: ButtonStyle(
                                  padding:
                                      MaterialStateProperty.all<EdgeInsets>(
                                    EdgeInsets.all(10),
                                  ),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Colors.white,
                                  ),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        10.0,
                                      ),
                                      side: BorderSide(
                                        color: Color(0xFFB7B7B7),
                                      ),
                                    ),
                                  ),
                                ),
                                onPressed: () {},
                                child: Text(
                                  'ลบทั้งหมด',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Color(0xFFB7B7B7),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'IBMPlex',
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _builCategory(dynamic model) {
    if (isNoActive) {
      listResultData = listData
          .where(
            (x) => x['categoryDays'] == model['code'] && x['status'] != "A",
          )
          .toList();
    } else {
      listResultData =
          listData.where((x) => x['categoryDays'] == model['code']).toList();
    }

    return listResultData.isNotEmpty
        ? Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 30),
                  child: Text(
                    '${model['title']}',
                    style: TextStyle(
                      color: Color(0XFFfad84c),
                      fontFamily: 'IBMPlex',
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                for (int i = 0; i < listResultData.length; i++)
                  cardV2(context, listResultData[i]),
                SizedBox(height: 34),
              ],
            ),
          )
        : Container();
  }

  void _holdClick(dynamic model) {
    setState(() {
      // isCheckSelect = !isCheckSelect;
      if (!isCheckSelect) {
        isCheckSelect = true;
        for (int j = 0; j < listData.length; j++) {
          if (listData[j]['code'] == model['code']) {
            listData[j]['isSelected'] = !listData[j]['isSelected'];
          }
        }
      } else {
        for (int j = 0; j < listData.length; j++) {
          if (listData[j]['code'] == model['code']) {
            listData[j]['isSelected'] = !listData[j]['isSelected'];
          }
        }
      }
      totalSelected =
          listData.where((i) => i['isSelected'] == true).toList().length;
    });
  }

  void _clearSelected() {
    setState(() {
      isCheckSelect = false;
      for (int j = 0; j < listData.length; j++) {
        listData[j]['isSelected'] = false;
      }

      totalSelected =
          listData.where((i) => i['isSelected'] == true).toList().length;
    });
  }

  void _singleClick(dynamic model) {
    setState(() {
      for (int j = 0; j < listData.length; j++) {
        if (listData[j]['code'] == model['code']) {
          listData[j]['isSelected'] = !listData[j]['isSelected'];
        }
      }

      totalSelected =
          listData.where((i) => i['isSelected'] == true).toList().length;
    });
  }

  Widget cardV2(BuildContext context, dynamic model) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return InkWell(
      onLongPress: () {
        _holdClick(model);
      },
      onTap: isCheckSelect
          ? () {
              _singleClick(model);
            }
          : () {
              postDio('${notificationApi}update', {
                'category': '${model['category']}',
                "code": '${model['code']}',
              });
              checkNavigationPage(model['category'], model);
            },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: model['status'] == 'A'
              ? Color(0xFFB7B7B7).withOpacity(0.1)
              : Color(0XFFfad84c).withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: model['isSelected']
              ? Border.all(color: Color(0XFFfad84c), width: 2)
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(right: 10, top: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height * 1 / 100),
                color: model['status'] == 'A'
                    ? Color(0xFFB7B7B7).withOpacity(0.1)
                    : Colors.red,
              ),
              height: height * 1.5 / 100,
              width: height * 1.5 / 100,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    checkCategoryName(model['category'], model),
                    style: TextStyle(
                      color: Color(0xFF707070),
                      fontFamily: 'IBMPlex',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  SizedBox(height: 5),
                  Text(
                    '${model['title']}',
                    style: TextStyle(
                      color: Color(0xFF707070),
                      fontFamily: 'Arial',
                      fontWeight: FontWeight.normal,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  SizedBox(height: 5),
                  Text(
                    model['categoryDays'] == "1"
                        ? '${timeString(model['docTime'])} น.'
                        : '${dateStringToDateStringFormatV2(model['createDate'])}',
                    style: TextStyle(
                      color: Color(0xFFB7B7B7),
                      fontFamily: 'Arial',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (model['isSelected'])
              Container(
                margin: EdgeInsets.only(
                  left: 10,
                ),
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Color(0XFFfad84c),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 20,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleClickMe() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          titlePadding: EdgeInsets.all(0),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.close, color: Color(0XFFfad84c), size: 35),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Center(
                child: Text(
                  'เลือกแสดงผล',
                  style: TextStyle(
                    color: Color(0XFFfad84c),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            SizedBox(height: 15),
            Center(
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedCategoryDays = "";
                    isNoActive = false;
                    unSelectall();
                    chkListCount = listData.length > 0 ? true : false;
                    chkListActive = listData
                                .where((x) => x['status'] != "A")
                                .toList()
                                .length >
                            0
                        ? true
                        : false;

                    Navigator.pop(context);

                    // listResultData = listData;
                  });
                },
                child: Container(
                  child: Text(
                    'ทั้งหมด',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'IBMPlex',
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF707070),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1.5,
                    color: Colors.grey[400] ?? Colors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: InkWell(
                onTap: () {
                  setState(() {
                    unSelectall();

                    selectedCategoryDays = "5";
                    selectedCategoryDaysName = "ยังไม่อ่าน";
                    isNoActive = true;
                    listResultData =
                        listData.where((x) => x['status'] != "A").toList();
                    chkListCount = listResultData.length > 0 ? true : false;
                    chkListActive = listResultData.length > 0 ? true : false;
                    Navigator.pop(context);
                  });
                },
                child: Container(
                  child: Text(
                    'ยังไม่อ่าน',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'IBMPlex',
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF707070),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1.5,
                    color: Colors.grey[400] ?? Colors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: InkWell(
                onTap: () {
                  setState(() {
                    unSelectall();

                    selectedCategoryDays = "1";
                    selectedCategoryDaysName = "วันนี้";
                    listResultData = listData
                        .where(
                          (i) => i['categoryDays'] == selectedCategoryDays,
                        )
                        .toList();
                    chkListCount = listResultData.length > 0 ? true : false;
                    chkListActive = listResultData
                                .where((x) => x['status'] != "A")
                                .toList()
                                .length >
                            0
                        ? true
                        : false;

                    Navigator.pop(context);
                  });
                },
                child: Container(
                  child: Text(
                    'วันนี้',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'IBMPlex',
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF707070),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1.5,
                    color: Colors.grey[400] ?? Colors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: InkWell(
                onTap: () {
                  setState(() {
                    unSelectall();
                    selectedCategoryDays = "2";
                    selectedCategoryDaysName = "เมื่อวาน";
                    listResultData = listData
                        .where(
                          (i) => i['categoryDays'] == selectedCategoryDays,
                        )
                        .toList();
                    chkListCount = listResultData.length > 0 ? true : false;
                    chkListActive = listResultData
                                .where((x) => x['status'] != "A")
                                .toList()
                                .length >
                            0
                        ? true
                        : false;

                    Navigator.pop(context);
                  });
                },
                child: Container(
                  child: Text(
                    'เมื่อวาน',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'IBMPlex',
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF707070),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1.5,
                    color: Colors.grey[400] ?? Colors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: InkWell(
                onTap: () {
                  setState(() {
                    unSelectall();

                    selectedCategoryDays = "3";
                    selectedCategoryDaysName = "7 วันก่อน";
                    listResultData = listData
                        .where(
                          (i) => i['categoryDays'] == selectedCategoryDays,
                        )
                        .toList();
                    chkListCount = listResultData.length > 0 ? true : false;
                    chkListActive = listResultData
                                .where((x) => x['status'] != "A")
                                .toList()
                                .length >
                            0
                        ? true
                        : false;
                    Navigator.pop(context);
                  });
                },
                child: Container(
                  child: Text(
                    '7 วันก่อน',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'IBMPlex',
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF707070),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1.5,
                    color: Colors.grey[400] ?? Colors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: InkWell(
                onTap: () {
                  setState(() {
                    unSelectall();

                    selectedCategoryDays = "4";
                    selectedCategoryDaysName = "เก่ากว่า 7 วัน";
                    listResultData = listData
                        .where(
                          (i) => i['categoryDays'] == selectedCategoryDays,
                        )
                        .toList();
                    chkListCount = listResultData.length > 0 ? true : false;
                    chkListActive = listResultData
                                .where((x) => x['status'] != "A")
                                .toList()
                                .length >
                            0
                        ? true
                        : false;
                    Navigator.pop(context);
                  });
                },
                child: Container(
                  child: Text(
                    'เก่ากว่า 7 วัน',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'IBMPlex',
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF707070),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        );
      },
    );
  }

  Widget animationsList() {
    return Expanded(
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Colors.transparent, Colors.red],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstATop,

        child: Container(height: 200.0, width: 200.0, color: Colors.blue),
        // blendMode: BlendMode.dstATop,
      ),
    );
  }

  _DialogUpdate() {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        ),
        backgroundColor: Colors.white,
        titlePadding: EdgeInsets.all(0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.close, color: Color(0XFFfad84c), size: 35),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    totalSelected > 0
                        ? 'เปลี่ยน ' +
                            totalSelected.toString() +
                            ' รายการที่เลือก เป็นอ่านแล้วใช่หรือไม่'
                        : textDialogUpdate(selectedCategoryDays),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0XFFfad84c),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: (MediaQuery.of(context).size.width / 100) * 30,
                margin: EdgeInsets.symmetric(vertical: 20.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      EdgeInsets.all(10),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.white,
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: Color(0xFFB7B7B7)),
                      ),
                    ),
                  ),
                  child: Text(
                    "ยกเลิก",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'IBMPlex',
                      color: Color(0xFFB7B7B7),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(width: 20),
              Container(
                width: (MediaQuery.of(context).size.width / 100) * 30,
                margin: EdgeInsets.symmetric(vertical: 20.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0XFFfad84c),
                  child: MaterialButton(
                    height: 30,
                    onPressed: () async {
                      Navigator.pop(context);

                      setState(() {
                        isLoading = true;
                      });

                      try {
                        if (totalSelected > 0) {
                          var listSelected = listData
                              .where((i) => i['isSelected'] == true)
                              .toList();

                          var listCode =
                              listSelected.map((e) => e['code']).join(',');

                          await postDio('${notificationApi}update', {
                            "code": listCode,
                          });

                          isCheckSelect = false;
                        } else if (selectedCategoryDays != "") {
                          var listCode =
                              listResultData.map((e) => e['code']).join(',');

                          await postDio('${notificationApi}update', {
                            "code": listCode,
                          });

                          isCheckSelect = false;
                        } else {
                          await postDio('${notificationApi}update', {});
                          isCheckSelect = false;
                        }

                        setState(() {
                          isLoading = false;
                        });
                      } catch (e) {
                        print('เกิดข้อผิดพลาด: $e');
                        // หากคุณมี showDialog หรือ snackbar ก็ใส่ตรงนี้ได้
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    child: Text(
                      'ใช่',
                      style: TextStyle(
                        fontSize: 17.0,
                        color: Color(0xFFFFFFFF),
                        fontWeight: FontWeight.w500,
                        fontFamily: 'IBMPlex',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      // );
    ).then((value) => _loading());
  }

  _DialogDelete() {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        ),
        backgroundColor: Colors.white,
        titlePadding: EdgeInsets.all(0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.close, color: Color(0XFFfad84c), size: 35),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    totalSelected > 0
                        ? 'ลบ $totalSelected รายการที่เลือก ออกจากแจ้งเตือนใช่หรือไม่'
                        : textDialogDelete(selectedCategoryDays),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0XFFfad84c),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: (MediaQuery.of(context).size.width / 100) * 30,
                margin: EdgeInsets.symmetric(vertical: 20.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all<EdgeInsets>(
                      EdgeInsets.all(10),
                    ),
                    backgroundColor: WidgetStateProperty.all<Color>(
                      Colors.white,
                    ),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: Color(0xFFB7B7B7)),
                      ),
                    ),
                  ),
                  child: Text(
                    "ยกเลิก",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'IBMPlex',
                      color: Color(0xFFB7B7B7),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(width: 20),
              Container(
                width: (MediaQuery.of(context).size.width / 100) * 30,
                margin: EdgeInsets.symmetric(vertical: 20.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0XFFfad84c),
                  child: MaterialButton(
                    height: 30,
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                        Navigator.pop(context);
                      });
                      if (totalSelected > 0) {
                        var listSelected = listData
                            .where((i) => i['isSelected'] == true)
                            .toList();
                        var listCode = "";
                        for (var i = 0; i < totalSelected; i++) {
                          if (listCode == '') {
                            listCode = listSelected[i]['code'];
                          } else {
                            listCode = listCode + ',' + listSelected[i]['code'];
                          }
                        }
                        await postDio('${notificationApi}delete', {
                          "code": listCode,
                          "username": _profile[0]["username"],
                        });
                        setState(() {
                          isCheckSelect = false;
                        });
                      } else if (selectedCategoryDays != "") {
                        var listCode = "";
                        for (var i = 0; i < listResultData.length; i++) {
                          if (listCode == '') {
                            listCode = listResultData[i]['code'];
                          } else {
                            listCode =
                                listCode + ',' + listResultData[i]['code'];
                          }
                        }
                        await postDio('${notificationApi}delete', {
                          "code": listCode,
                          "username": _profile[0]["username"],
                        });
                        setState(() {
                          isCheckSelect = false;
                        });
                      } else {
                        await postDio('${notificationApi}delete', {});
                        // setState(() {
                        //   _loading();
                        //   Navigator.pop(context);
                        // });
                      }
                      setState(() {
                        _loading();
                        isLoading = false;
                        _loading();
                      });
                    },
                    child: Text(
                      'ใช่',
                      style: TextStyle(
                        fontSize: 17.0,
                        color: Color(0xFFFFFFFF),
                        fontWeight: FontWeight.w500,
                        fontFamily: 'IBMPlex',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).then((value) => _loading());
  }

  unSelectall() {
    setState(() {
      for (var i = 0; i < listData.length; i++) {
        listData[i]['isSelected'] = false;
      }
      totalSelected = 0;
      isCheckSelect = false;
    });
  }

  checkCategoryName(String page, dynamic model) {
    switch (page) {
      case 'newsPage':
        {
          return "ข่าวประชาสัมพันธ์";
        }
      case 'eventPage':
        {
          return "ปฏิทินกิจกรรม";
        }
      // case 'contactPage':
      //   {
      //     return "เบอร์ติดต่อเร่งด่วน";
      //   }
      case 'privilegePage':
        {
          return "สิทธิประโยชน์";
        }
      case 'knowledgePage':
        {
          return "คลังความรู้";
        }
      case 'poiPage':
        {
          return "ท่องเที่ยวยอดนิยม";
        }
      // case 'pollPage':
      //   {
      //     return "แบบประเมิน (Poll)";
      //   }
      // case 'mainPage':
      //   {
      //     return "กำหนดเอง";
      //   }
      default:
        {
          return "";
        }
    }
  }

  textNotiEmpty(String categoryDay) {
    switch (categoryDay) {
      case '1':
        {
          return "ท่านไม่มีข้อมูลการแจ้งเตือนสำหรับวันนี้";
        }
      case '2':
        {
          return "ท่านไม่มีข้อมูลการแจ้งเตือนสำหรับเมื่อวาน";
        }
      case '3':
        {
          return "ท่านไม่มีข้อมูลการแจ้งเตือนเมื่อ 7 วันก่อน";
        }
      case '4':
        {
          return "ท่านไม่มีข้อมูลการแจ้งเตือนที่เก่ากว่า 7 วัน";
        }
      case '5':
        {
          return "ท่านไม่มีข้อมูลการแจ้งเตือนที่ยังไม่อ่าน";
        }
      default:
        {
          return "";
        }
    }
  }
}

textDialogDelete(String categoryDay) {
  switch (categoryDay) {
    case '1':
      {
        return "ลบรายการทั้งหมดของวันนี้ออกจากการแจ้งเตือนใช่หรือไม่";
      }
    case '2':
      {
        return "ลบรายการทั้งหมดของเมื่อวานออกจากการแจ้งเตือนใช่หรือไม่";
      }
    case '3':
      {
        return "ลบรายการทั้งหมดของเมื่อ 7 วันก่อนออกจากการแจ้งเตือนใช่หรือไม่";
      }
    case '4':
      {
        return "ลบรายการทั้งหมดที่เก่ากว่า 7 วันก่อนออกจากการแจ้งเตือนใช่หรือไม่";
      }
    default:
      {
        return "ลบรายการทั้งหมด ออกจากแจ้งเตือนใช่หรือไม่";
      }
  }
}

textDialogUpdate(String categoryDay) {
  switch (categoryDay) {
    case '1':
      {
        return "เปลี่ยนรายการทั้งหมดของวันนี้เป็นอ่านแล้วใช่หรือไม่";
      }
    case '2':
      {
        return "เปลี่ยนรายการทั้งหมดของเมื่อวานเป็นอ่านแล้วใช่หรือไม่";
      }
    case '3':
      {
        return "เปลี่ยนรายการทั้งหมดของเมื่อ 7 วันก่อนเป็นอ่านแล้วใช่หรือไม่";
      }
    case '4':
      {
        return "เปลี่ยนรายการทั้งหมดที่เก่ากว่า 7 วันก่อนเป็นอ่านแล้วใช่หรือไม่";
      }
    default:
      {
        return "เปลี่ยนรายการทั้งหมด เป็นอ่านแล้วใช่หรือไม่";
      }
  }
}
