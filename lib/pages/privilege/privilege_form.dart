import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import '../../component/gallery_view.dart';
import '../../component/link_url_out.dart';
import '../../component/header.dart';
import '../../apptheme.dart';
import '../../shared/api_provider.dart';
import '../../shared/extension.dart';
import '../blank_page/blank_loading.dart';

class PrivilegeForm extends StatefulWidget {
  PrivilegeForm({super.key, @required this.code, this.model});
  final String? code;
  final dynamic model;

  @override
  _PrivilegeDetailPageState createState() => _PrivilegeDetailPageState();
}

class _PrivilegeDetailPageState extends State<PrivilegeForm> {
  // _PrivilegeDetailPageState({});

  Future<dynamic>? _futureModel;
  // String _urlShared = '';
  String? code;
  List urlImage = [];
  List<ImageProvider> urlImageProvider = [];

  @override
  void initState() {
    super.initState();
    code = widget.code;
    _futureModel = post(
        '${privilegeApi}read', {'skip': 0, 'limit': 1, 'code': widget.code});
  }

  Future<dynamic> readGallery() async {
    final result =
        await postObjectData('m/news/gallery/read', {'code': widget.code});

    if (result['status'] == 'S') {
      List data = [];
      List<ImageProvider> dataPro = [];

      for (var item in result['objectData']) {
        data.add(item['imageUrl']);

        dataPro.add(item['imageUrl'] != null
            ? NetworkImage(item['imageUrl'])
            : NetworkImage(""));
      }
      setState(() {
        urlImage = data;
        urlImageProvider = dataPro;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent,
    // ));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: header(context, () => Navigator.pop(context),
          title: 'รายละเอียดสิทธิประโยชน์'),
      body: FutureBuilder<dynamic>(
        future: _futureModel, // function where you call your api
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          // AsyncSnapshot<Your object type>

          if (snapshot.hasData) {
            return myContent(snapshot.data[0]);
          } else {
            if (widget.model != null) {
              return myContent(widget.model);
            } else {
              return BlankLoading();
            }
          }
        },
      ),
    );
  }

  myContent(dynamic model) {
    List image = ['${model['imageUrl']}'];
    final description = '${model['description'] ?? ''}'.trim();
    List<ImageProvider> imagePro = [
      model['imageUrl'] != null
          ? NetworkImage(model['imageUrl'])
          : NetworkImage("")
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: GalleryView(
            imageUrl: [...image, ...urlImage],
            imageProvider: [...imagePro, ...urlImageProvider],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${model['title']}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontFamily: 'Kanit',
                  fontSize: 22,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  CircleAvatar(
                    radius: 21,
                    backgroundColor: AppColors.primarySoft,
                    backgroundImage: model['imageUrlCreateBy'] != null
                        ? NetworkImage(model['imageUrlCreateBy'])
                        : null,
                    child: model['imageUrlCreateBy'] == null
                        ? const Icon(Icons.person_outline,
                            color: AppColors.primary)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${model['createBy']}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontFamily: 'Kanit',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${dateStringToDate(model['createDate'])}  •  เข้าชม ${model['view']} ครั้ง',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontFamily: 'Sarabun',
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (description.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1, color: AppColors.border),
                ),
                Html(
                  data: description,
                  style: {
                    'body': Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      color: AppColors.textSecondary,
                      fontFamily: 'Sarabun',
                      fontSize: FontSize(15),
                      lineHeight: const LineHeight(1.55),
                    ),
                  },
                  onLinkTap: (url, context, attributes) {
                    if (url != null) launch(url);
                  },
                ),
                const SizedBox(height: 18),
              ],
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => launchURL(model['linkUrl']),
                  icon: const Icon(Icons.open_in_new_rounded, size: 19),
                  label: const Text('ดูรายละเอียดเพิ่มเติม'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
