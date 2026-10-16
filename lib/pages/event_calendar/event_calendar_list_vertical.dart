import 'package:flutter/material.dart';

import '../../apptheme.dart';
import '../../component/blurred_network_image.dart';
import '../blank_page/blank_data.dart';
import 'event_calendar_form.dart';

class EventCalendarListVertical extends StatefulWidget {
  EventCalendarListVertical({
    super.key,
    this.site,
    this.model,
    this.title,
    this.url,
    this.urlComment,
    this.urlGallery,
  });

  final String? site;
  final Future<dynamic>? model;
  final String? title;
  final String? url;
  final String? urlComment;
  final String? urlGallery;

  @override
  _EventCalendarListVertical createState() => _EventCalendarListVertical();
}

class _EventCalendarListVertical extends State<EventCalendarListVertical> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // AsyncSnapshot<Your object type>

        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            return Container(
              height: 200,
              alignment: Alignment.center,
              child: Text(
                'ไม่พบข้อมูล',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Sarabun',
                  color: Color.fromRGBO(0, 0, 0, 0.6),
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
                  mainAxisExtent: 246,
                ),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  // return Container(height: 300.0,color: Colors.red,margin: EdgeInsets.all(5.0),);
                  return myCard(index, snapshot.data.length,
                      snapshot.data[index], context);
                  // return demoItem(snapshot.data[index]);
                },
              ),
            );
          }
        } else {
          return blankGridData(context);
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
                  builder: (context) => EventCalendarForm(
                    urlGallery: widget.urlGallery,
                    urlComment: widget.urlComment,
                    model: model,
                    url: widget.url,
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
                  color: Colors.grey.withValues(alpha: 0.5),
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
            builder: (context) => EventCalendarForm(
              urlGallery: widget.urlGallery,
              urlComment: widget.urlComment,
              model: model,
              url: widget.url,
              code: model['code'],
            ),
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
          // alignment: Alignment.topCenter,
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
                  height: double.infinity,
                ),
              ),
            ),
            Container(
              constraints: const BoxConstraints(minHeight: 58),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14.0),
                  bottomRight: Radius.circular(14.0),
                ),
                color: AppColors.surface,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
                child: Text(
                  '${model['title'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: AppColors.textPrimary,
                    fontFamily: 'Kanit',
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
