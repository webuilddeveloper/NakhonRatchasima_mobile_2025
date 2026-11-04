import 'package:flutter/material.dart';

import '../../component/blurred_network_image.dart';
import '../../shared/extension.dart';
import '../../shared/mock_repository.dart';
import '../blank_page/toast_fail.dart';
import 'poll_form.dart';

class PollListVertical extends StatefulWidget {
  PollListVertical(
      {super.key,
      this.site,
      this.model,
      this.title,
      this.url,
      this.urlComment,
      this.urlGallery,
      this.titleHome,
      this.callBack});

  final String? site;
  final Future<dynamic>? model;
  final String? title;
  final String? url;
  final String? urlComment;
  final String? urlGallery;
  final String? titleHome;
  final Function? callBack;

  @override
  _PollListVertical createState() => _PollListVertical();
}

class _PollListVertical extends State<PollListVertical> {
  @override
  void initState() {
    super.initState();
  }

  final List<String> items =
      List<String>.generate(10, (index) => "Item: ${++index}");

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        final List<dynamic> pollList = (snapshot.hasData && snapshot.data is List && (snapshot.data as List).isNotEmpty)
            ? snapshot.data as List
            : KoratMockRepository.getPollList();

        return Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: ListView.builder(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: pollList.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  pollList[index]['status2'] == true
                      ? toastFail(context, text: 'คุณตอบแบบสอบถามนี้แล้ว')
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PollForm(
                              code: pollList[index]['code'],
                              model: pollList[index],
                              titleMenu: widget.title,
                              titleHome: widget.titleHome,
                              url: widget.url,
                            ),
                          ),
                        );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 0,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.only(bottom: 5.0),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: pollList[index]['status2'] == true
                                  ? Colors.grey[300]
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            padding: const EdgeInsets.all(5),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 90,
                                      width: 90,
                                      child: BlurredNetworkImage(
                                        imageUrl: '${pollList[index]['imageUrl'] ?? ''}',
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: width * 60 / 100,
                                      margin: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                      child: Text(
                                        '${pollList[index]['title']}',
                                        style: const TextStyle(
                                          color: Color(0xFF000000),
                                          fontFamily: 'Sarabun',
                                          fontSize: 15,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                      child: Text(
                                        dateStringToDate(pollList[index]['createDate']),
                                        style: const TextStyle(
                                          color: Color(0xFF000000),
                                          fontFamily: 'Sarabun',
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
