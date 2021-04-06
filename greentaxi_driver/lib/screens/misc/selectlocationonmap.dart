import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greentaxi_driver/dataprovider/appdata.dart';
import 'package:greentaxi_driver/helpers/requestHelper.dart';
import 'package:greentaxi_driver/models/address.dart';
import 'package:greentaxi_driver/models/searchmodels.dart';
import 'package:greentaxi_driver/shared/repository/firebase_service.dart';
import 'package:greentaxi_driver/widgets/TaxiButton.dart';
import 'package:provider/provider.dart';

import '../../globalvariables.dart';

class SelectLocationOnMap extends StatefulWidget {
  static const String Id = 'SelectOnMap';
  final bool isPickUpSearch;
  SelectLocationOnMap({this.isPickUpSearch});
  @override
  _SelectLocationOnMapState createState() => _SelectLocationOnMapState();
}

class _SelectLocationOnMapState extends State<SelectLocationOnMap> {
  Set<Marker> _markers = {};
  BitmapDescriptor nearbyIcon;
  final GlobalKey<ScaffoldState> scaffoldKey2 = new GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapcontroller;
  var geolocator = Geolocator();
  var locationOptions =
  LocationOptions(accuracy: LocationAccuracy.bestForNavigation);
  Position myPosition;
  BitmapDescriptor movingMarkerIcon;
  LatLng currentLoca;

  final CameraPosition googlePlex = CameraPosition(
    target: LatLng(6.885173, 80.015352),
    zoom: 14.4746,
  );

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    var imageData = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
        imageData.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getBytesFromAsset('images/icons/pinx.png', 150).then((value) {
      print("getBytesFromAsset value $value");
      movingMarkerIcon = BitmapDescriptor.fromBytes(value);
    });

    _markers.add(Marker(
      markerId: MarkerId('marker_2'),
      position: LatLng(6.885173, 80.015352),
      draggable: true,
      icon: movingMarkerIcon,
    ));
  }

  void _updatePosition(CameraPosition _position) {
    print(
        'inside updatePosition ${_position.target.latitude} ${_position.target.longitude}');
    currentLoca = _position.target;
    Marker marker = _markers.firstWhere(
            (p) => p.markerId == MarkerId('marker_2'),
        orElse: () => null);

    _markers.remove(marker);
    _markers.add(
      Marker(
        markerId: MarkerId('marker_2'),
        position: LatLng(_position.target.latitude, _position.target.longitude),
        draggable: true,
        icon: movingMarkerIcon,
      ),
    );
    setState(() {});
  }

  void getPlaceDetails(LatLng loca, context, isPickUpSearch) async {
    print('PredictionTile->getPlaceDetails-> placeId : ${loca}');
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      return;
    }

    ///GeoCOde Url to get the location details for provided locations
    String url =
        '$geoCodeUrl?latlng=${loca.latitude},${loca.longitude}&key=$ApiKey';

    print("url of the geoCoder $url");

    ///Return Location information of the given coordinates
    var response = await RequestHelper.getRequest(url);
    if (response != 'failed') {
      Address thisplace = Address();
      //placeAddress = response['results'][0]['formatted_address'];

      thisplace.placeId = response['results'][0]['place_id'];
      thisplace.placeName =
      response['results'][0]["formatted_address"];
      thisplace.placeFormatAddress =
      response['results'][0]["formatted_address"];
      thisplace.latitude = loca.latitude;
      thisplace.logitude = loca.longitude;

      print("isPickUpSearch   ${isPickUpSearch}");
      if (isPickUpSearch) {
        Provider.of<AppData>(context, listen: false)
            .updatePickupAddress(thisplace);
      } else {
        Provider.of<AppData>(context, listen: false)
            .updateDestinationAdrress(thisplace);
      }

      SearchHistory obj = SearchHistory(thisplace.placeId, thisplace.placeName,
          thisplace.placeFormatAddress, thisplace.latitude, thisplace.logitude);
      await FirebaseService().addSearchHistory(obj, currentFirebaseUser.uid);

      //Navigator.pop(context);
      if (isPickUpSearch) {
        print("isPickUpSearch True ${isPickUpSearch}");
        Navigator.pop(context, thisplace);
      } else {
        print("isPickUpSearch False ${isPickUpSearch}");
        Navigator.pop(context, 'getDirection');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey2,
        body: SafeArea(
            child: Stack(children: <Widget>[
              ///Google Maps  *************************************************************************************************************
              GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: googlePlex,
                markers: _markers,
                padding: EdgeInsets.only(bottom: 80),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onCameraMove: ((_position) => _updatePosition(_position)),
                onMapCreated: (GoogleMapController controller) {
                  print("onMapCreated... " + controller.mapId.toString());
                  currentLoca = googlePlex.target;
                },
              ),

              ///Menu Buttons *************************************************************************************************************
              Positioned(
                top: 44,
                left: 22,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5.0,
                              spreadRadius: 0.5,
                              offset: Offset(0.7, 0.7))
                        ]),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 20,
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: TaxiButton(
                          title: 'Add to PickUp',
                          color: Color(0xfff57c00),
                          onPress: () {
                            getPlaceDetails(currentLoca, context,true);
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: TaxiButton(
                          title: 'Add to Drop',
                          color: Color(0xfff57c00),
                          onPress: () {
                            getPlaceDetails(currentLoca, context,false);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ])));
  }
}
