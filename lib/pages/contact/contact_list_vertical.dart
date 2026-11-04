import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../component/blurred_network_image.dart';
import '../../shared/mock_repository.dart';

class ContactListVertical extends StatefulWidget {
  ContactListVertical({
    super.key,
    this.site,
    this.model,
    this.title,
    this.url,
  });

  final String? site;
  final Future<dynamic>? model;
  final String? title;
  final String? url;

  @override
  _ContactListVertical createState() => _ContactListVertical();
}

class _ContactListVertical extends State<ContactListVertical> {
  @override
  void initState() {
    super.initState();
  }

  final List<String> items =
      List<String>.generate(10, (index) => "Item: ${++index}");

  _makePhoneCall(String url) async {
    final cleanUrl = url.trim();
    final telUri = Uri.parse('tel:$cleanUrl');
    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'อุปกรณ์นี้ไม่สามารถโทรออกโดยตรงได้ กรุณากดโทร: $cleanUrl',
              style: const TextStyle(fontFamily: 'Sarabun'),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ไม่สามารถโทรออกได้ กรุณาโทรหมายเลข $cleanUrl',
            style: const TextStyle(fontFamily: 'Sarabun'),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: widget.model,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        final List<dynamic> contactList = (snapshot.hasData &&
                snapshot.data is List &&
                (snapshot.data as List).isNotEmpty)
            ? snapshot.data as List
            : KoratMockRepository.getContacts();

        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: ListView.builder(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: contactList.length,
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    margin: EdgeInsets.only(bottom: 5.0),
                    child: Column(
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            minHeight: 80,
                            minWidth: double.infinity,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: new BorderRadius.circular(15.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 0,
                                blurRadius: 7,
                                offset: Offset(4, 4),
                              ),
                            ],
                            color: Color(0xFFFFFFFF),
                          ),
                          padding: EdgeInsets.all(10.0),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: BlurredNetworkImage(
                                      imageUrl:
                                          '${contactList[index]['imageUrl'] ?? ''}',
                                      width: 55.0,
                                      height: 55.0,
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.55,
                                        padding: EdgeInsets.only(left: 10.0),
                                        child: Text(
                                          '${contactList[index]['phone']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            fontFamily: 'Sarabun',
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.55,
                                        padding: EdgeInsets.only(left: 10.0),
                                        child: Text(
                                          '${contactList[index]['title']}',
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            fontFamily: 'Sarabun',
                                            color: Color.fromRGBO(0, 0, 0, 0.6),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  _makePhoneCall(contactList[index]['phone']);
                                },
                                child: Container(
                                  width: 50.00,
                                  height: 50.00,
                                  padding: const EdgeInsets.all(10.00),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  child: Image.asset('assets/images/phone.png'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
