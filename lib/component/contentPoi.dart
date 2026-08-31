import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as GMap;

import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../shared/api_provider.dart';
import '../shared/extension.dart';
import 'gallery_view.dart';

class ContentPoi extends StatefulWidget {
  ContentPoi({
    super.key,
    this.code,
    this.url,
    this.model,
    this.urlGallery,
    this.pathShare,
  });

  final String? code;
  final String? url;
  final dynamic model;
  final String? urlGallery;
  final String? pathShare;

  @override
  _ContentPoi createState() => _ContentPoi();
}

class _ContentPoi extends State<ContentPoi> {
  Future<dynamic>? _futureModel;

  // Loading states
  bool _isLoadingGallery = true;
  bool _isLoadingShare = true;

  String _urlShared = '';
  List urlImage = [];
  List<ImageProvider> urlImageProvider = [];

  Completer<GMap.GoogleMapController> _mapController = Completer();

  @override
  void initState() {
    super.initState();
    _futureModel = post(widget.url!, {
      'skip': 0,
      'limit': 1,
      'code': widget.code,
      'latitude': 0.0,
      'longitude': 0.0
    });

    readGallery();
    sharedApi();
  }

  Future<dynamic> readGallery() async {
    setState(() {
      _isLoadingGallery = true;
    });

    try {
      final result =
          await postObjectData(widget.urlGallery!, {'code': widget.code});

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
          _isLoadingGallery = false;
        });
      } else {
        setState(() {
          _isLoadingGallery = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingGallery = false;
      });
    }
  }

  Future<dynamic> sharedApi() async {
    setState(() {
      _isLoadingShare = true;
    });

    try {
      await postConfigShare().then((result) => {
            if (result['status'] == 'S')
              {
                setState(() {
                  _urlShared = result['objectData']['description'];
                  _isLoadingShare = false;
                }),
              }
            else
              {
                setState(() {
                  _isLoadingShare = false;
                }),
              }
          });
    } catch (e) {
      setState(() {
        _isLoadingShare = false;
      });
    }
  }

  // Loading widget
  Widget _buildLoadingWidget() {
    return Container(
      height: 500,
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 16),
            Text(
              'กำลังโหลดข้อมูล...',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Sarabun',
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Error widget
  Widget _buildErrorWidget() {
    return Container(
      height: 500,
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'เกิดข้อผิดพลาดในการโหลดข้อมูล',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Sarabun',
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _futureModel = post(widget.url!, {
                    'skip': 0,
                    'limit': 1,
                    'code': widget.code,
                    'latitude': 0.0,
                    'longitude': 0.0
                  });
                });
                readGallery();
                sharedApi();
              },
              child: Text('ลองใหม่'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _futureModel,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        } else if (snapshot.hasError) {
          return _buildErrorWidget();
        } else if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data.isNotEmpty) {
          return myContentPoi(snapshot.data[0]);
        } else if (widget.model != null) {
          return myContentPoi(widget.model);
        } else {
          return _buildErrorWidget();
        }
      },
    );
  }

  myContentPoi(dynamic model) {
    List image = ['${model['imageUrl']}'];
    List<ImageProvider> imagePro = [
      model['imageUrl'] != null
          ? NetworkImage(model['imageUrl'])
          : NetworkImage("")
    ];

    return ListView(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      children: [
        // Gallery section with loading state
        Container(
          color: Color(0xFFFFFFF),
          child: _isLoadingGallery
              ? Container(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : GalleryView(
                  imageUrl: [...image, ...urlImage],
                  imageProvider: [...imagePro, ...urlImageProvider],
                ),
        ),
        Container(
          padding: EdgeInsets.only(
            right: 10.0,
            left: 10.0,
          ),
          margin: EdgeInsets.only(right: 50.0, top: 10.0),
          child: Text(
            '${model['title']}',
            style: TextStyle(
              fontSize: 18.0,
              fontFamily: 'Sarabun',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                right: 10,
                left: 10,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: model['imageUrlCreateBy'] != null
                        ? NetworkImage(model['imageUrlCreateBy'])
                        : null,
                    child: model['imageUrlCreateBy'] == null
                        ? Icon(Icons.person)
                        : null,
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model['createBy'] ?? '',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Sarabun',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              dateStringToDate(model['createDate']) + ' | ',
                              style: TextStyle(
                                fontSize: 10,
                                fontFamily: 'Sarabun',
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Text(
                              'เข้าชม ' + '${model['view']}' + ' ครั้ง',
                              style: TextStyle(
                                fontSize: 10,
                                fontFamily: 'Sarabun',
                                fontWeight: FontWeight.w300,
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
            Container(
              width: 74.0,
              height: 31.0,
              alignment: Alignment.centerRight,
              child: _isLoadingShare
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : TextButton(
                      onPressed: () {
                        final RenderBox? box =
                            context.findRenderObject() as RenderBox;
                        Share.share(
                          _urlShared +
                              widget.pathShare! +
                              '${model['code']}' +
                              ' ${model['title']}',
                          subject: '${model['title']}',
                          sharePositionOrigin:
                              box!.localToGlobal(Offset.zero) & box.size,
                        );
                      },
                      child: Image.asset('assets/images/share.png'),
                    ),
            )
          ],
        ),
        Container(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(
            right: 10,
            left: 10,
          ),
          child: new Html(
              data: '${model['description'] ?? ''}',
              onLinkTap: (url, context, attributes) {
                if (url != null) {
                  launch(url);
                }
              }),
        ),
        Padding(
          padding: const EdgeInsets.only(
            right: 10,
            left: 10,
          ),
          child: Text(
            'ที่ตั้ง',
            style: TextStyle(
              fontSize: 15,
              fontFamily: 'Sarabun',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            right: 10,
            left: 10,
          ),
          child: Text(
            model['address'] != null && model['address'].isNotEmpty
                ? model['address']
                : '-',
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'Sarabun',
            ),
          ),
        ),
        Container(
          height: 250,
          width: double.infinity,
          child: googleMap(
              model['latitude'] != null && model['latitude'] != ''
                  ? double.parse(model['latitude'])
                  : 13.8462512,
              model['longitude'] != null && model['longitude'] != ''
                  ? double.parse(model['longitude'])
                  : 100.5234803),
        ),
      ],
    );
  }

  googleMap(double lat, double lng) {
    return GMap.GoogleMap(
      myLocationEnabled: true,
      compassEnabled: true,
      tiltGesturesEnabled: false,
      mapType: GMap.MapType.normal,
      initialCameraPosition: GMap.CameraPosition(
        target: GMap.LatLng(lat, lng),
        zoom: 15,
      ),
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
        new Factory<OneSequenceGestureRecognizer>(
          () => new EagerGestureRecognizer(),
        ),
      ].toSet(),
      onMapCreated: (GMap.GoogleMapController controller) {
        controller.moveCamera(
          GMap.CameraUpdate.newLatLngBounds(
            GMap.LatLngBounds(
                southwest: GMap.LatLng(lat - 0.08, lng - 0.11),
                northeast: GMap.LatLng(lat + 0.08, lng + 0.08)),
            5.0,
          ),
        );
        controller.animateCamera(GMap.CameraUpdate.newCameraPosition(
            GMap.CameraPosition(target: GMap.LatLng(lat, lng), zoom: 16)));
        _mapController.complete(controller);
      },
      markers: <GMap.Marker>[
        GMap.Marker(
          markerId: GMap.MarkerId('1'),
          position: GMap.LatLng(lat, lng),
          icon: GMap.BitmapDescriptor.defaultMarkerWithHue(
              GMap.BitmapDescriptor.hueRed),
        ),
      ].toSet(),
    );
  }
}
