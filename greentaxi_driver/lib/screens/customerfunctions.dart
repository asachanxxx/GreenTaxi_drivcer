import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greentaxi_driver/brand_colors.dart';
import 'package:greentaxi_driver/models/customer.dart';
import 'package:greentaxi_driver/screens/mainpage.dart';
import 'package:greentaxi_driver/styles/styles.dart';
import 'package:greentaxi_driver/widgets/BrandDivider.dart';
import 'package:greentaxi_driver/widgets/TaxiButton.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class CustomerFunctions extends StatefulWidget {
  static const String Id = 'cusfunc';

  final Customer customer;
  CustomerFunctions({this.customer});


  @override
  _CustomerFunctionsState createState() => _CustomerFunctionsState();
}

class _CustomerFunctionsState extends State<CustomerFunctions> with TickerProviderStateMixin {

  final GlobalKey<ScaffoldState> scaffoldKey2 = new GlobalKey<ScaffoldState>();
  List<LatLng> polylineCordinates = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapcontroller;

  double searchSheetHeight = (Platform.isIOS) ? 300 : 300;
  double mapBottomPadding = 0;
  double rideDetailSheetHeight = 0; //(Platform.isIOS) ? 300 : 275;
  double requestingSheetHeight = 0; //(Platform.isIOS) ? 220 : 195;
  double tripSheetHeight = 0; // (Platform.isAndroid) ? 275 : 300

  final fullnamecontoller = TextEditingController();
  final phonecontoller = TextEditingController();
  final emailcontoller = TextEditingController();

  double earnings = 0.0;

  var customerName ="";
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  CameraPosition userHome = CameraPosition(
    target: LatLng(6.885173, 80.015352),
    zoom: 14.4746,
  );

  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldKey2.currentState.showSnackBar(snackbar);
  }

  @override
  void initState(){
    _determinePosition().then((value) {
      userHome = CameraPosition(
        target: LatLng(value.latitude, value.longitude),
        zoom: 14.4746,
      );
      customerName = (widget.customer != null) ? widget.customer.fullName : "";
    });
    //print("customer ${widget.customer.fullName}");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey2,
      body: SafeArea(
          child: Stack(
            children: <Widget>[
              ///Google Maps  *************************************************************************************************************
              GoogleMap(
                //polylines: _polylines,
                padding: EdgeInsets.only(bottom: 350),
                mapType: MapType.normal,
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: true,
                initialCameraPosition: userHome,
                circles: _circles,
                markers: _markers,
                onMapCreated: (GoogleMapController controller) {
                  print("onMapCreated... " + controller.mapId.toString());
                  _controller.complete(controller);
                  mapcontroller = controller;

                  setState(() {
                    mapBottomPadding = (Platform.isAndroid) ? 280 : 270;
                    print('mapBottomPadding :' + mapBottomPadding.toString());
                  });

                  //setupPositionLocation();
                },
              ),

              ///Menu Buttons *************************************************************************************************************
              Positioned(
                top: 44,
                left: 22,
                child: GestureDetector(
                  onTap: () {
                    // if (drawerCanOpen) {
                    //   scaffoldKey2.currentState.openDrawer();
                    // } else {
                    //   resetApp();
                    // }
                    //Navigator.pop(context);
                    Navigator.pushNamedAndRemoveUntil(context, MainPage.Id, (route) => false,);
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

              ///Search Sheet *************************************************************************************************************
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedSize(
                  vsync: this,
                  duration: new Duration(milliseconds: 150),
                  curve: Curves.easeIn,
                  child: Container(
                      margin: const EdgeInsets.only(
                          top: 20, bottom: 20, left: 20, right: 20),
                      height: searchSheetHeight,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFcffffff),
                              Color(0xFFffffff),
                              Color(0xFFffffff),
                              Color(0xFFffffff),
                            ],
                            stops: [0.1, 0.4, 0.7, 0.9],
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: Color(0xFFfbc02d),
                                blurRadius: 4.0,
                                spreadRadius: 0,
                                offset: Offset(0.4, 0.4))
                          ]),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: 5),
                            Text(
                              'Add Trips for $customerName',
                              style: f_font_15_Bold_Black100,
                            ),
                            SizedBox(height: 5),
                            Column(
                              children: [

                                TextField(
                                  controller: fullnamecontoller,
                                  keyboardType: TextInputType.text,
                                  decoration: getInputDecorationRegister('Full Name',Icon(Icons.keyboard)),
                                  style: GoogleFonts.roboto(color: Colors.black87,fontSize: 15,height: 1),
                                ),
                                SizedBox(height: 10,),
                                TextField(
                                  controller: phonecontoller,
                                  keyboardType: TextInputType.phone,
                                  decoration: getInputDecorationRegister('Mobile No',Icon(Icons.phone)),
                                  style: GoogleFonts.roboto(color: Colors.black87,fontSize: 15),
                                ),
                                SizedBox(height: 10,),
                                TaxiButton(
                                  title: "Add",
                                  color:Color(0xFFff6f00),
                                  onPress: () async {
                                    bool emailValid = RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                        .hasMatch(emailcontoller.text);

                                    //Check network aialability
                                    var connectivity = await Connectivity()
                                        .checkConnectivity();
                                    if(connectivity != ConnectivityResult.mobile && connectivity != ConnectivityResult.wifi){
                                      showSnackBar(
                                          'Oops! seems you are offline.');
                                      return;
                                    }
                                    if (fullnamecontoller.text.length < 3) {
                                      showSnackBar(
                                          'Oops! full name must be more than 3 characters.');
                                      return;
                                    }
                                    if (phonecontoller.text.length != 10) {
                                      showSnackBar(
                                          'Oops! Phone number must be 10 characters.');
                                      return;
                                    }
                                    //registerUser();
                                  },
                                )
                              ],
                            ),

                          ],
                        ),
                      )),
                ),
              ),

            ],
          )),
    );
  }



}
