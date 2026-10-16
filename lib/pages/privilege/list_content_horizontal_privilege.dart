import 'package:flutter/material.dart';

import '../../component/blurred_network_image.dart';

import '../../component/sso/list_content_horizontal_loading.dart';
import '../../apptheme.dart';
import '../../shared/api_provider.dart';
import '../../shared/extension.dart';

// ignore: must_be_immutable
class ListContentHorizontalPrivilege extends StatefulWidget {
  ListContentHorizontalPrivilege(
      {super.key,
      this.title,
      this.code,
      this.model,
      this.navigationList,
      this.navigationForm});

  final String? code;
  final String? title;
  final Future<dynamic>? model;
  final Function()? navigationList;
  final Function(String, dynamic)? navigationForm;

  @override
  _ListContentHorizontalPrivilege createState() =>
      _ListContentHorizontalPrivilege();
}

class _ListContentHorizontalPrivilege
    extends State<ListContentHorizontalPrivilege> {
  Future<dynamic>? _futurePrivilege;

  @override
  void initState() {
    _futurePrivilege = post('${privilegeApi}read',
        {'skip': 0, 'limit': 100, 'category': widget.code});
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _futurePrivilege, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 10.0),
                      margin: const EdgeInsets.only(bottom: 8.0, top: 18.0),
                      child: Text(
                        widget.title!,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 17.0,
                          fontFamily: 'Kanit',
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        widget.navigationList!();
                      },
                      child: Container(
                        padding: const EdgeInsets.only(right: 10.0),
                        margin: const EdgeInsets.only(bottom: 8.0, top: 10.0),
                        child: Text(
                          'ดูทั้งหมด',
                          style: TextStyle(
                              fontSize: 12.0,
                              fontFamily: 'Kanit',
                              color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 224,
                  color: Colors.transparent,
                  child: renderCard(
                    widget.title!,
                    widget.model!,
                    widget.navigationForm!,
                  ),
                ),
              ],
            );
          } else {
            return Container();
          }
        } else {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 10.0),
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      widget.title!,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                        fontFamily: 'Kanit',
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      widget.navigationList!();
                    },
                    child: Container(
                        padding: const EdgeInsets.only(right: 10.0),
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: Image.asset(
                          'assets/images/double_arrow_right.png',
                          height: 15.0,
                        )),
                  ),
                ],
              ),
              Container(
                height: 224,
                color: Colors.transparent,
                child: renderCard(
                    widget.title!, widget.model!, widget.navigationForm!),
              ),
            ],
          );
        }
      },
    );
  }
}

renderCard(String title, Future<dynamic> model, Function navigationForm) {
  return FutureBuilder<dynamic>(
    future: model, // function where you call your api
    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      // AsyncSnapshot<Your object type>

      if (snapshot.hasData) {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: snapshot.data.length,
          itemBuilder: (context, index) {
            return myCard(
              index,
              snapshot.data.length,
              snapshot.data[index],
              context,
              navigationForm,
            );
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

renderCardList(String title, Future<dynamic> model, Function navigationForm) {
  return ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: 10,
    itemBuilder: (context, index) {
      return ListContentHorizontalLoading();
    },
  );
}

myCard(int index, int lastIndex, dynamic model, BuildContext context,
    Function navigationForm) {
  return InkWell(
    onTap: () {
      navigationForm(model['code'], model);
    },
    child: Container(
      margin: index == 0
          ? EdgeInsets.only(left: 10.0, right: 5.0)
          : index == lastIndex - 1
              ? EdgeInsets.only(left: 5.0, right: 15.0)
              : EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      width: 184.0,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5.0),
              topRight: Radius.circular(5.0),
            ),
            child: BlurredNetworkImage(
              imageUrl: '${model['imageUrl'] ?? ''}',
              width: double.infinity,
              height: 170.0,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 170.0),
            padding: EdgeInsets.all(5),
            alignment: Alignment.topLeft,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: new BorderRadius.only(
                bottomLeft: const Radius.circular(5.0),
                bottomRight: const Radius.circular(5.0),
              ),
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 10,
                    color: Color(0xFFFFFFFF),
                    fontFamily: 'Sarabun',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  dateStringToDate(model['createDate']),
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 8,
                    fontFamily: 'Sarabun',
                    color: Color(0xFFFFFFFF),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
