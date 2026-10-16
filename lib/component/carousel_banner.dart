import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'blurred_network_image.dart';

class CarouselBanner extends StatefulWidget {
  CarouselBanner({
    super.key,
    this.model,
    this.nav,
    this.blurOverflow = true,
  });

  final Future<dynamic>? model;
  final Function(String, String, dynamic, String, String)? nav;
  final bool blurOverflow;

  @override
  _CarouselBanner createState() => _CarouselBanner();
}

class _CarouselBanner extends State<CarouselBanner> {
  final txtDescription = TextEditingController();
  int _current = 0;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    txtDescription.dispose();
    super.dispose();
  }

  final List<String> imgList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return FutureBuilder<dynamic>(
      future: widget.model, // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return Column(
              children: [
                InkWell(
                  onTap: () {
                    widget.nav!(
                      snapshot.data[_current]['linkUrl'],
                      snapshot.data[_current]['action'],
                      snapshot.data[_current],
                      snapshot.data[_current]['code'],
                      '',
                    );
                  },
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 141,
                      viewportFraction: 1.0,
                      enlargeCenterPage: false,
                      autoPlay: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      },
                    ),
                    items: snapshot.data.map<Widget>(
                      (document) {
                        return Container(
                          child: Center(
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15)),
                              child: BlurredNetworkImage(
                                imageUrl: '${document['imageUrl'] ?? ''}',
                                height: 161,
                                width: double.infinity,
                                blurWhenNeeded: widget.blurOverflow,
                              ),
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
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
          } else {
            return Container(
              height: (height * 22.5) / 100,
            );
          }
        } else {
          return Container(
            height: (height * 22.5) / 100,
          );
        }
      },
    );
  }
}
