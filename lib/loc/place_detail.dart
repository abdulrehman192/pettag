import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kGoogleApiKey = "AIzaSyDhEKPfktjxZocQFdTCO0DECINwBsk60E0";
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class PlaceDetailWidget extends StatefulWidget {
  String? placeId;

  PlaceDetailWidget(String placeId) {
    this.placeId = placeId;
  }

  @override
  State<StatefulWidget> createState() {
    return PlaceDetailState();
  }
}

class PlaceDetailState extends State<PlaceDetailWidget> {
  GoogleMapController? mapController;
  PlacesDetailsResponse? place;
  bool isLoading = false;
  String? errorLoading;
  final Set<Marker> _markers = <Marker>{};
  Set<Circle>? circles;
  int? radius;
  Uint8List? imageMarker;

  getImageMarker() async {
    imageMarker = await getByteFromAsset('assets/logo.png', 120);
  }

  getRadius() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    radius = prefs.containsKey('radius') ? prefs.getInt('radius') : 1;
  }

  @override
  void initState() {
    getImageMarker();
    getRadius();
    fetchPlaceDetail();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyChild;
    String title;
    if (isLoading) {
      title = "Loading";
      bodyChild = const Center(
        child: CircularProgressIndicator(
          value: null,
        ),
      );
    } else if (errorLoading != null) {
      title = "";
      bodyChild = Center(
        child: Text(errorLoading!),
      );
    } else {
      final placeDetail = place!.result;
      final location = place!.result.geometry!.location;
      final lat = location.lat;
      final lng = location.lng;
      final center = LatLng(lat, lng);

      title = placeDetail.name;
      bodyChild = Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            child: SizedBox(
              height: 400.0,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(target: center, zoom: 18),
                //myLocationEnabled: true,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                  ),
                },
                mapType: MapType.normal,
                markers: _markers,
              ),
            ),
          ),
          Expanded(
            child: buildPlaceDetailList(placeDetail),
          )
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: bodyChild,
    );
  }

  void fetchPlaceDetail() async {
    setState(() {
      isLoading = true;
      errorLoading = null;
    });

    PlacesDetailsResponse place =
        await _places.getDetailsByPlaceId(widget.placeId!);

    if (mounted) {
      setState(() {
        isLoading = false;
        if (place.status == "OK") {
          this.place = place;
        } else {
          errorLoading = place.errorMessage;
        }
      });
    }
  }

  double? getZoomLevel(double radius) {
    double? zoomLevel = 5;
    if (radius > 0) {
      double radiusElevated = radius + radius / 2;
      double scale = radiusElevated / 500;
      zoomLevel = 16 - math.log(scale) / math.log(2);
    }
    zoomLevel = double.parse(zoomLevel.toStringAsFixed(2));
    return zoomLevel;
  }

  static Future<Uint8List> getByteFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    final placeDetail = place!.result;
    final location = place!.result.geometry!.location;
    final lat = location.lat;
    final lng = location.lng;
    final center = LatLng(lat, lng);
    String id = placeDetail.placeId;
    _markers.add(Marker(
      icon: BitmapDescriptor.fromBytes(imageMarker!),
      markerId: MarkerId(widget.placeId!),
      visible: true,
      infoWindow: InfoWindow(
        title: placeDetail.name,
        snippet: "Ratings : ${placeDetail.rating.toString()}",
        onTap: () {},
      ),
      position: LatLng(
          placeDetail.geometry!.location.lat, placeDetail.geometry!.location.lng),
    ));
    //mapController.showMarkerInfoWindow(MarkerId(widget.placeId));
    /*var markerOptions = MarkerOptions(
        position: center,
        infoWindowText: InfoWindowText(
            "${placeDetail.name}", "${placeDetail.formattedAddress}"));*/
    //mapController.addMarker(markerOptions);
    mapController!.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: center, zoom: 18.0)))
        .then((value) {
      setState(() {});
    });
  }

  String buildPhotoURL(String photoReference) {
    return "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$kGoogleApiKey";
  }

  ListView buildPlaceDetailList(PlaceDetails placeDetail) {
    List<Widget> list = [];
    if (placeDetail.photos != null) {
      final photos = placeDetail.photos;
      list.add(
        SizedBox(
          height: 100.0,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return Padding(
                    padding: const EdgeInsets.only(right: 1.0),
                    child: SizedBox(
                      height: 100,
                      child: Image.network(
                          buildPhotoURL(photos[index].photoReference)),
                    ));
              }),
        ),
      );
    }

    list.add(Padding(
      padding: const EdgeInsets.all(2),
      child: Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(
                            top: 4.0, left: 8.0, right: 8.0, bottom: 4.0),
                        child: Text(
                          placeDetail.name,
                          style: Theme.of(context).textTheme.headline5,
                        )),
                    placeDetail.openingHours != null
                        ? Padding(
                            padding: const EdgeInsets.only(
                                top: 0.0, left: 8.0, right: 8.0, bottom: 4.0),
                            child: Text(
                              placeDetail.openingHours!.openNow
                                  ? 'Open Now'
                                  : 'Closed',
                              style: const TextStyle(color: Colors.pink),
                            ))
                        : Container(),
                  ],
                ),
                placeDetail.formattedAddress != null
                    ? Padding(
                        padding: const EdgeInsets.only(
                            top: 4.0, left: 8.0, right: 8.0, bottom: 4.0),
                        child: Text(
                          placeDetail.formattedAddress!,
                          style: Theme.of(context).textTheme.bodyText1,
                        ))
                    : Container(),
                placeDetail.types.first.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(
                            top: 4.0, left: 8.0, right: 8.0, bottom: 0.0),
                        child: Text(
                          placeDetail.types.first.toUpperCase(),
                          style: Theme.of(context).textTheme.caption,
                        ))
                    : Container(),
                placeDetail.formattedPhoneNumber != null
                    ? Padding(
                        padding: const EdgeInsets.only(
                            top: 4.0, left: 8.0, right: 8.0, bottom: 4.0),
                        child: Text(
                          placeDetail.formattedPhoneNumber!,
                          style: Theme.of(context).textTheme.button,
                        ))
                    : Container(),
                placeDetail.website != null
                    ? Padding(
                        padding: const EdgeInsets.only(
                            top: 0.0, left: 8.0, right: 8.0, bottom: 4.0),
                        child: Text(
                          placeDetail.website!,
                          style: Theme.of(context).textTheme.caption,
                        ))
                    : Container(),
                placeDetail.rating != null
                    ? Padding(
                        padding: const EdgeInsets.only(
                            top: 0.0, left: 8.0, right: 8.0, bottom: 4.0),
                        child: Text(
                          "Rating: ${placeDetail.rating}",
                          style: Theme.of(context).textTheme.caption,
                        ))
                    : Container(),
              ],
            ),
          )),
    ));

    /*list.add(
      Padding(
          padding:
              EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 4.0),
          child: Text(
            placeDetail.name,
            style: Theme.of(context).textTheme.subtitle,
          )),
    );*/

    /*if (placeDetail.formattedAddress != null) {
      list.add(
        Padding(
            padding:
                EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 4.0),
            child: Text(
              placeDetail.formattedAddress,
              style: Theme.of(context).textTheme.body1,
            )),
      );
    }

    if (placeDetail.types?.first != null) {
      list.add(
        Padding(
            padding:
                EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 0.0),
            child: Text(
              placeDetail.types.first.toUpperCase(),
              style: Theme.of(context).textTheme.caption,
            )),
      );
    }

    if (placeDetail.formattedPhoneNumber != null) {
      list.add(
        Padding(
            padding:
                EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 4.0),
            child: Text(
              placeDetail.formattedPhoneNumber,
              style: Theme.of(context).textTheme.button,
            )),
      );
    }

    if (placeDetail.openingHours != null) {
      final openingHour = placeDetail.openingHours;
      var text = '';
      if (openingHour.openNow) {
        text = 'Open Now';
      } else {
        text = 'Closed';
      }
      list.add(
        Padding(
            padding:
                EdgeInsets.only(top: 0.0, left: 8.0, right: 8.0, bottom: 4.0),
            child: Text(
              text,
              style: Theme.of(context).textTheme.caption,
            )),
      );
    }

    if (placeDetail.website != null) {
      list.add(
        Padding(
            padding:
                EdgeInsets.only(top: 0.0, left: 8.0, right: 8.0, bottom: 4.0),
            child: Text(
              placeDetail.website,
              style: Theme.of(context).textTheme.caption,
            )),
      );
    }

    if (placeDetail.rating != null) {
      list.add(
        Padding(
            padding:
                EdgeInsets.only(top: 0.0, left: 8.0, right: 8.0, bottom: 4.0),
            child: Text(
              "Rating: ${placeDetail.rating}",
              style: Theme.of(context).textTheme.caption,
            )),
      );
    }*/

    return ListView(
      shrinkWrap: true,
      children: list,
    );
  }
}
