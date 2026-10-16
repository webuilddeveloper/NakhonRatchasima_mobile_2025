import 'package:flutter/material.dart';

import '../../component/sso/list_content_horizontal_loading.dart';
import '../../apptheme.dart';

// ignore: must_be_immutable
class ListContentHorizontalPrivilegeSuggested extends StatefulWidget {
  ListContentHorizontalPrivilegeSuggested(
      {super.key,
      this.title,
      this.url,
      this.model,
      this.urlComment,
      this.navigationList,
      this.navigationForm});

  final String? title;
  final String? url;
  final Future<dynamic>? model;
  final String? urlComment;
  final Function()? navigationList;
  final Function(String, dynamic)? navigationForm;

  @override
  _ListContentHorizontalPrivilegeSuggested createState() =>
      _ListContentHorizontalPrivilegeSuggested();
}

class _ListContentHorizontalPrivilegeSuggested
    extends State<ListContentHorizontalPrivilegeSuggested> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 10.0),
              margin: EdgeInsets.only(bottom: 5.0),
              child: Text(
                widget.title!,
                style: TextStyle(
                  // color: Color(0xFFC9166D),
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'Sarabun',
                ),
              ),
            ),
            InkWell(
              onTap: () {
                widget.navigationList!();
              },
              child: Container(
                  padding: EdgeInsets.only(right: 10.0),
                  margin: EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    'ดูทั้งหมด',
                    style: TextStyle(fontSize: 12.0, fontFamily: 'Sarabun'),
                  )),
            ),
          ],
        ),
        Container(
          height: 232,
          color: Colors.transparent,
          child: renderCard(
            widget.title!,
            widget.url!,
            widget.model!,
            widget.urlComment!,
            widget.navigationForm!,
          ),
        ),
      ],
    );
  }
}

renderCard(String title, String url, Future<dynamic> model, String urlComment,
    Function navigationForm) {
  return FutureBuilder<dynamic>(
    future: model,
    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      if (snapshot.hasData) {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: snapshot.data.length,
          itemBuilder: (context, index) {
            return myCard(index, snapshot.data.length, snapshot.data[index],
                context, navigationForm);
          },
        );
      } else {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 10,
          itemBuilder: (context, index) {
            return ListContentHorizontalLoading();
          },
        );
      }
    },
  );
}

myCard(int index, int lastIndex, dynamic model, BuildContext context,
    Function navigationForm) {
  return InkWell(
    onTap: () {
      navigationForm(model['code'], model);
    },
    child: Column(
      children: [
        Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
              ),
              margin: index == 0
                  ? const EdgeInsets.only(left: 10.0, right: 6.0)
                  : index == lastIndex - 1
                      ? const EdgeInsets.only(left: 6.0, right: 16.0)
                      : const EdgeInsets.symmetric(horizontal: 6.0),
              width: 208.0,
              child: Column(
                children: [
                  Container(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      child: Image.network(
                      '${model['imageUrl']}',
                      height: 158,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Container(
                    height: 52,
                    width: double.infinity,
                    alignment: Alignment.topLeft,
                    decoration: BoxDecoration(
                      borderRadius: new BorderRadius.only(
                        bottomLeft: const Radius.circular(5.0),
                        bottomRight: const Radius.circular(5.0),
                      ),
                      color: AppColors.primary,
                    ),
                    padding: EdgeInsets.all(5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '${model['title']}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Kanit',
                            color: AppColors.surface,
                            fontSize: 13.0,
                          ),
                        ),
                        Text(
                          '${model['title']}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontFamily: 'Sarabun',
                            color: AppColors.surface.withValues(alpha: 0.8),
                            fontSize: 10.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
