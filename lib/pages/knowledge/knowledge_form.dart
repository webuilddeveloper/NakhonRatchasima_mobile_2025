import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:flutter/services.dart';

import '../../component/link_url_out.dart';
import '../../component/link_url_in.dart';
import '../../shared/api_provider.dart';
import '../../shared/extension.dart';
import '../../shared/mock_repository.dart';

class KnowledgeForm extends StatefulWidget {
  KnowledgeForm({super.key, required this.code, this.model, this.urlComment});
  final String? code;
  final dynamic model;
  final String? urlComment;

  @override
  _KnowledgeDetailPageState createState() =>
      _KnowledgeDetailPageState(code: code);
}

class _KnowledgeDetailPageState extends State<KnowledgeForm> {
  _KnowledgeDetailPageState({this.code});

  Future<dynamic>? _futureModel;

  String? code;

  @override
  void initState() {
    super.initState();
    _futureModel = post(
      '${knowledgeApi}read',
      {'skip': 0, 'limit': 1, 'code': widget.code},
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () => {
          Navigator.pop(context),
        },
        child: Icon(Icons.close, color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder<dynamic>(
        future: _futureModel,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          dynamic currentModel;
          if (snapshot.hasData && snapshot.data != null) {
            if (snapshot.data is List && (snapshot.data as List).isNotEmpty) {
              currentModel = snapshot.data[0];
            } else if (snapshot.data is Map) {
              currentModel = snapshot.data;
            }
          }
          currentModel ??= widget.model;
          if (currentModel == null &&
              (snapshot.connectionState == ConnectionState.done ||
                  snapshot.hasError)) {
            currentModel = KoratMockRepository.getKnowledgeList().firstWhere(
              (k) => k['code'] == widget.code,
              orElse: () => KoratMockRepository.getKnowledgeList().first,
            );
          }

          if (currentModel != null) {
            return myContent(currentModel);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  myContent(dynamic model) {
    final fileUrl = model['fileUrl']?.toString().trim() ?? '';
    final linkUrl = model['linkUrl']?.toString().trim() ?? '';
    final hasResource = fileUrl.isNotEmpty || linkUrl.isNotEmpty;
    final String imageUrl = (model['imageUrl'] ?? '').toString().trim();
    final bool hasImage = imageUrl.isNotEmpty;
    final bool isAsset = hasImage && imageUrl.startsWith('assets/');

    final author = (model['author'] ?? '').toString().trim();
    final publisher = (model['publisher'] ?? '').toString().trim();
    final bookType = (model['bookType'] ?? '').toString().trim();
    final numberOfPages = (model['numberOfPages'] ?? '').toString().trim();
    final size = (model['size'] ?? '').toString().trim();
    final description = (model['description'] ?? '').toString().trim();

    String categoryTitle = '';
    if (model['categoryList'] != null &&
        model['categoryList'] is List &&
        (model['categoryList'] as List).isNotEmpty &&
        model['categoryList'][0] is Map &&
        model['categoryList'][0]['title'] != null) {
      categoryTitle = model['categoryList'][0]['title'].toString().trim();
    } else if (model['categoryTitle'] != null) {
      categoryTitle = model['categoryTitle'].toString().trim();
    } else if (model['category'] != null) {
      final cat = model['category'].toString().trim();
      if (cat == '1') {
        categoryTitle = 'คู่มือบริการประชาชน';
      } else if (cat == '2') {
        categoryTitle = 'สิทธิและสวัสดิการ';
      } else if (cat == '3') {
        categoryTitle = 'การเกษตรและสิ่งแวดล้อม';
      } else if (cat.isNotEmpty) {
        categoryTitle = cat;
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Stack(
                children: [
                  Container(
                    height: 480,
                    width: double.infinity,
                    color: Colors.grey.shade900,
                    child: hasImage
                        ? (isAsset
                            ? Image.asset(imageUrl, fit: BoxFit.cover)
                            : Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Container(color: Colors.grey.shade900),
                              ))
                        : Container(color: Colors.grey.shade900),
                  ),
                  Container(
                    height: 480,
                    color: Colors.black.withValues(alpha: 0.55),
                  ),
                ],
              ),
              Column(
                children: [
                  const SizedBox(height: 60.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: hasImage
                        ? (isAsset
                            ? Image.asset(imageUrl,
                                height: 260, width: 200, fit: BoxFit.cover)
                            : Image.network(
                                imageUrl,
                                height: 260,
                                width: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 260,
                                  width: 200,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.library_books,
                                      size: 64, color: Colors.grey),
                                ),
                              ))
                        : Container(
                            height: 260,
                            width: 200,
                            color: Colors.white.withValues(alpha: 0.2),
                            child: const Icon(Icons.library_books,
                                size: 64, color: Colors.white),
                          ),
                  ),
                  Container(
                    height: 110,
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, top: 12.0),
                    child: Column(
                      children: [
                        Text(
                          (model['title'] ?? '').toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontFamily: 'Kanit',
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          model['createDate'] != null
                              ? dateStringToDate(model['createDate'])
                              : '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontFamily: 'Kanit',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  if (hasResource) ...[
                    Container(
                      width: 400.0,
                      padding: const EdgeInsets.symmetric(horizontal: 90.0),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white,
                        child: MaterialButton(
                          minWidth: MediaQuery.of(context).size.width,
                          onPressed: () {
                            if (fileUrl.isNotEmpty) {
                              launchURL(fileUrl);
                            } else {
                              launchInWebViewWithJavaScript(linkUrl);
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              SizedBox(
                                width: 35.0,
                                height: 35.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Image.asset(
                                    'assets/logo/icons/Group337.png',
                                    height: 5.0,
                                    width: 5.0,
                                    color: Theme.of(context).primaryColor,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.menu_book,
                                      size: 20,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                fileUrl.isNotEmpty
                                    ? 'เปิดเอกสาร PDF'
                                    : 'เปิดลิงก์',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontFamily: 'Kanit',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          Column(
            children: [
              const TextDetail(
                title: 'ข้อมูล',
                value: '',
                fsTitle: 18.0,
                fsValue: 13.0,
                color: Colors.black,
              ),
              if (author.isNotEmpty)
                TextDetail(
                  title: 'ผู้แต่ง',
                  value: author,
                  fsTitle: 13.0,
                  fsValue: 13.0,
                  color: Colors.grey,
                ),
              if (publisher.isNotEmpty)
                TextDetail(
                  title: 'สำนักพิมพ์',
                  value: publisher,
                  fsTitle: 13.0,
                  fsValue: 13.0,
                  color: Colors.grey,
                ),
              if (categoryTitle.isNotEmpty)
                TextDetail(
                  title: 'หมวดหมู่',
                  value: categoryTitle,
                  fsTitle: 13.0,
                  fsValue: 13.0,
                  color: Colors.grey,
                ),
              if (bookType.isNotEmpty)
                TextDetail(
                  title: 'ประเภทหนังสือ',
                  value: bookType,
                  fsTitle: 13.0,
                  fsValue: 13.0,
                  color: Colors.grey,
                ),
              if (numberOfPages.isNotEmpty)
                TextDetail(
                  title: 'จำนวนหน้า',
                  value: numberOfPages,
                  fsTitle: 13.0,
                  fsValue: 13.0,
                  color: Colors.grey,
                ),
              if (size.isNotEmpty)
                TextDetail(
                  title: 'ขนาด',
                  value: size,
                  fsTitle: 13.0,
                  fsValue: 13.0,
                  color: Colors.grey,
                ),
              const SizedBox(height: 20.0),
              const TextDetail(
                title: 'รายละเอียด',
                value: '',
                fsTitle: 18.0,
                fsValue: 13.0,
                color: Colors.black,
              ),
              const SizedBox(height: 10.0),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
                alignment: Alignment.topLeft,
                child: Html(
                  data: description.isNotEmpty
                      ? description
                      : '<p>ไม่มีรายละเอียดข้อมูลเพิ่มเติม</p>',
                  onLinkTap: (url, context, attributes) {
                    if (url != null && url.isNotEmpty) {
                      final uri = Uri.tryParse(url);
                      if (uri != null) {
                        launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 40.0),
            ],
          ),
        ],
      ),
    );
  }
}

class TextDetail extends StatelessWidget {
  const TextDetail({
    super.key,
    this.title,
    this.value,
    this.fsTitle,
    this.fsValue,
    this.color,
  });

  final String? title;
  final String? value;
  final double? fsTitle;
  final double? fsValue;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title ?? '',
              style: TextStyle(
                fontSize: fsTitle ?? 13.0,
                color: color ?? Colors.grey,
                fontFamily: 'Kanit',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '',
              style: TextStyle(
                fontSize: fsValue ?? 13.0,
                color: Colors.black87,
                fontFamily: 'Kanit',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
