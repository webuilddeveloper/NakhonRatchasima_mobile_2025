import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:ratchasima/apptheme.dart';
import 'package:ratchasima/component/korat_ui.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../component/header.dart';
import '../../component/key_search.dart';
import '../../shared/api_provider.dart';

import '../main_popup/dialog_main_popup.dart';
import 'privilege_list_vertical.dart';

class PrivilegeMain extends StatefulWidget {
  PrivilegeMain({super.key, this.title, this.fromPolicy});
  final String? title;
  final bool? fromPolicy;

  @override
  _PrivilegeMain createState() => _PrivilegeMain();
}

class _PrivilegeMain extends State<PrivilegeMain> {
  final storage = new FlutterSecureStorage();

  PrivilegeListVertical? gridView;
  bool hideSearch = true;
  Future<dynamic>? _futureForceAds;
  Future<dynamic>? _futureCategory;

  String categorySelected = '';
  String keySearch = '';
  bool isHighlight = false;
  int _limit = 10;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    _futureForceAds = post('${forceAdsApi}read', {'skip': 0, 'limit': 10});
    _futureCategory = postCategory(
      '${privilegeCategoryApi}read',
      {'skip': 0, 'limit': 100},
    );
    getForceAds();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: header(context, goBack, title: widget.title ?? 'สิทธิประโยชน์'),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overScroll) {
          overScroll.disallowIndicator();
          return false;
        },
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: SmartRefresher(
            enablePullDown: false,
            enablePullUp: true,
            footer: ClassicFooter(
              loadingText: ' ',
              canLoadingText: ' ',
              idleText: ' ',
              idleIcon: Icon(Icons.arrow_upward, color: Colors.transparent),
            ),
            controller: _refreshController,
            onLoading: _onLoading,
            child: ListView(
              padding: const EdgeInsets.only(bottom: KoratSpacing.xxl),
              children: [
                const SizedBox(height: KoratSpacing.md),
                KeySearch(
                  show: hideSearch,
                  hintext: 'ค้นหาสิทธิประโยชน์',
                  onKeySearchChange: (String val) {
                    setState(() {
                      keySearch = val;
                    });
                  },
                ),
                const SizedBox(height: KoratSpacing.sm),
                tabCategory(),
                const SizedBox(height: KoratSpacing.sm),
                reloadList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> showForceAds() async {
    var value = await storage.read(key: 'dataUserLoginDDPM');
    var user = json.decode(value!);

    var valueStorage = await storage.read(key: 'privilegeDDPM');
    var dataValue;
    if (valueStorage != null) {
      dataValue = json.decode(valueStorage);
    } else {
      dataValue = null;
    }

    var now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);

    if (dataValue != null) {
      var index = dataValue.indexWhere(
        (c) =>
            c['username'] == user['username'] &&
            c['date'] == DateFormat("ddMMyyyy").format(date).toString() &&
            c['boolean'] == "true",
      );

      if (index == -1) {
        return showDialog(
          barrierDismissible: false, // close outside
          context: context,
          builder: (_) {
            return MainPopupDialog(
              model: _futureForceAds,
              type: 'privilege',
              username: user['username'],
            );
          },
        );
      }
    } else {
      return showDialog(
        barrierDismissible: false, // close outside
        context: context,
        builder: (_) {
          return MainPopupDialog(
            model: _futureForceAds,
            type: 'privilege',
            username: user['username'],
          );
        },
      );
    }
  }

  getForceAds() async {
    var result = await post('${forceAdsApi}read', {'skip': 0, 'limit': 100});
    if (result.length > 0) {
      showForceAds();
    }
  }

  void _onLoading() async {
    setState(() {
      _limit = _limit + 10;

      gridView = new PrivilegeListVertical(
        site: 'CIO',
        model: post('${privilegeApi}read', {
          'skip': 0,
          'limit': _limit,
        }),
      );
    });

    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  reloadList() {
    return gridView = new PrivilegeListVertical(
      site: 'DDPM',
      model: post('${privilegeApi}read', {
        'skip': 0,
        'limit': _limit,
        'keySearch': keySearch != null ? keySearch : '',
        'isHighlight': isHighlight != null ? isHighlight : false,
        'category': categorySelected != null ? categorySelected : ''
      }),
    );
  }

  void goBack() async {
    Navigator.pop(context, false);
  }

  tabCategory() {
    return FutureBuilder<dynamic>(
      future: _futureCategory,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return Container(
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: KoratSpacing.md),
            padding: const EdgeInsets.symmetric(horizontal: KoratSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: KoratRadius.md,
              border: Border.all(color: AppColors.border),
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
                        keySearch = '';
                        isHighlight = false;
                        categorySelected = snapshot.data[index]['code'];
                      });
                    } else {
                      setState(() {
                        isHighlight = true;
                        categorySelected = '';
                      });
                    }
                  },
                  child: SizedBox(
                    width: tabWidth,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: KoratSpacing.xs,
                        vertical: KoratSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: categorySelected == snapshot.data[index]['code']
                            ? AppColors.primarySoft
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          snapshot.data[index]['title'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: categorySelected ==
                                    snapshot.data[index]['code']
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: categorySelected ==
                                    snapshot.data[index]['code']
                                ? FontWeight.w600
                                : FontWeight.w400,
                            fontFamily: 'Kanit',
                          ),
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
            height: 45.0,
            padding: EdgeInsets.only(left: 5.0, right: 5.0),
            margin: EdgeInsets.symmetric(horizontal: 30.0),
            decoration: new BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 0,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
              borderRadius: new BorderRadius.circular(6.0),
              color: Colors.white,
            ),
          );
        }
      },
    );
  }
}
