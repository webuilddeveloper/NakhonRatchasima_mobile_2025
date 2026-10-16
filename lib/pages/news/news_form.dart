import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../component/comment.dart';
import '../../component/content.dart';
import '../../component/korat_ui.dart';
import '../../apptheme.dart';
import '../../shared/api_provider.dart';

// ignore: must_be_immutable
class NewsForm extends StatefulWidget {
  NewsForm({
    super.key,
    this.url,
    this.code,
    this.model,
    this.urlComment,
    this.urlGallery,
  });

  final String? url;
  final String? code;
  final dynamic model;
  final String? urlComment;
  final String? urlGallery;

  @override
  _NewsForm createState() => _NewsForm();
}

class _NewsForm extends State<NewsForm> {
  Comment? comment;
  int? _limit;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onLoading() async {
    setState(() {
      _limit = _limit! + 10;

      comment = Comment(
        code: widget.code,
        url: newsCommentApi,
        model: post('${newsCommentApi}read',
            {'skip': 0, 'limit': _limit, 'code': widget.code}),
        limit: _limit,
      );
    });

    await Future.delayed(Duration(milliseconds: 1000));

    _refreshController.loadComplete();
  }

  @override
  void initState() {
    setState(() {
      _limit = 10;
    });

    comment = Comment(
      code: widget.code,
      url: newsCommentApi,
      model: post('${newsCommentApi}read',
          {'skip': 0, 'limit': _limit, 'code': widget.code}),
      limit: _limit,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: KoratAppBar(
        title: 'รายละเอียดข่าว',
        showBack: true,
        onBack: () => Navigator.pop(context),
      ),
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
            idleIcon: Icon(Icons.arrow_upward, color: Colors.transparent),
          ),
          controller: _refreshController,
          onLoading: _onLoading,
          child: ListView(
            shrinkWrap: true,
            children: [
              Content(
                pathShare: 'content/news/',
                code: widget.code,
                url: widget.url ?? newsApi,
                model: widget.model,
                urlGallery: widget.urlGallery ?? newsGalleryApi,
              ),
              if ((widget.urlComment ?? newsCommentApi).isNotEmpty)
                comment!,
            ],
          ),
        ),
      ),
    );
  }
}
