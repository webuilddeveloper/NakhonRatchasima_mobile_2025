import 'package:flutter/material.dart';
import '../../apptheme.dart';
import '../../component/blurred_network_image.dart';

import 'privilege_form.dart';

class PrivilegeListVertical extends StatefulWidget {
  PrivilegeListVertical({super.key, this.site, this.model});

  final String? site;
  final Future<dynamic>? model;

  @override
  _PrivilegeListVertical createState() => _PrivilegeListVertical();
}

class _PrivilegeListVertical extends State<PrivilegeListVertical> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: widget.model,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            return Container(
              height: 220,
              alignment: Alignment.center,
              child: Text(
                'ไม่พบข้อมูล',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Sarabun',
                  color: AppColors.textSecondary,
                ),
              ),
            );
          } else {
            return Container(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return myCard(index, snapshot.data.length,
                      snapshot.data[index], context);
                },
              ),
            );
          }
        } else {
          return Container();
        }
      },
    );
  }

  demoItem(dynamic model) {
    return Column(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrivilegeForm(
                    code: model['code'],
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(1),
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
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: BlurredNetworkImage(
                  imageUrl: '${model['imageUrl'] ?? ''}',
                  width: double.infinity,
                ),
              ),
            ),
          ),
        ),
        Container(
          child: Center(
            child: Image.asset('assets/images/bar.png'),
          ),
        ),
      ],
    );
  }

  myCard(int index, int lastIndex, dynamic model, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PrivilegeForm(code: model['code'], model: model),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14.0),
                  topRight: Radius.circular(14.0),
                ),
                child: BlurredNetworkImage(
                  imageUrl: '${model['imageUrl'] ?? ''}',
                  width: double.infinity,
                  height: 157.0,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.topLeft,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14.0),
                  bottomRight: Radius.circular(14.0),
                ),
                color: AppColors.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      color: AppColors.surface,
                      fontFamily: 'Kanit',
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
}
