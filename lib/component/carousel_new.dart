import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ratchasima/pages/news/news_form.dart';
import 'package:ratchasima/shared/api_provider.dart';

import 'blurred_network_image.dart';

class CarouselNew extends StatefulWidget {
  CarouselNew({super.key, this.model, this.nav});

  final Future<dynamic>? model;
  final Function(String, String, dynamic, String, String)? nav;

  @override
  _CarouselNew createState() => _CarouselNew();
}

class _CarouselNew extends State<CarouselNew> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return FutureBuilder<dynamic>(
      future: widget.model,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 161,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            height: 161,
            child: Center(
              child: Text(
                'เกิดข้อผิดพลาดในการโหลดข้อมูล',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  color: Colors.red,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data.length > 0) {
          return Column(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: 161,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  autoPlay: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  },
                ),
                items: snapshot.data.map<Widget>((document) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewsForm(
                            url: document['url'] ?? '',
                            code: document['code'] ?? '',
                            model: document,
                            urlComment: newsApi,
                            urlGallery: newsGalleryApi,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 2.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        child: Stack(
                          children: [
                            BlurredNetworkImage(
                              imageUrl: '${document['imageUrl'] ?? ''}',
                              height: 161,
                              width: double.infinity,
                            ),
                            // Optional: เพิ่ม gradient overlay สำหรับ title ถ้ามี
                            if (document['title'] != null)
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.7),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  padding: EdgeInsets.all(12),
                                  child: Text(
                                    document['title'] ?? '',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Dot indicators
              Container(
                color: Color(0xFFFFFBF7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: snapshot.data.map<Widget>((url) {
                    int index = snapshot.data.indexOf(url);
                    return Container(
                      width: _current == index ? 20.0 : 5.0,
                      height: 5.0,
                      margin: _current == index
                          ? EdgeInsets.symmetric(
                              vertical: 5.0,
                              horizontal: 1.0,
                            )
                          : EdgeInsets.symmetric(
                              vertical: 5.0,
                              horizontal: 2.0,
                            ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: _current == index
                            ? Color(0xFFC9166D)
                            : Color(0xFFFFE3F0),
                        // : Color.fromRGBO(0, 0, 0, 0.4),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        }

        // Empty state
        return Container(
          height: (height * 22.5) / 100,
          child: Center(
            child: Text(
              'ไม่มีข่าวประชาสัมพันธ์',
              style: TextStyle(
                fontFamily: 'Kanit',
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}
