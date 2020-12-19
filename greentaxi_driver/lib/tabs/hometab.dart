import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greentaxi_driver/brand_colors.dart';
import 'package:greentaxi_driver/dataprovider/appdata.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/helpers/pushnotificationservice.dart';
import 'package:greentaxi_driver/models/address.dart';
import 'package:greentaxi_driver/models/drivers.dart';
import 'package:greentaxi_driver/screens/login.dart';
import 'package:greentaxi_driver/shared/auth/userrepo.dart';
import 'package:greentaxi_driver/styles/styles.dart';
import 'package:greentaxi_driver/widgets/AvailabilityButton.dart';
import 'package:greentaxi_driver/widgets/ConfirmSheet.dart';
import 'package:greentaxi_driver/widgets/TaxiButton.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with WidgetsBindingObserver{

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch(state){
      case AppLifecycleState.paused:
        print('paused state');
        break;
      case AppLifecycleState.resumed:
        print('resumed state');
        break;
      case AppLifecycleState.inactive:
        print('inactive state');
        break;
    }
  }


  GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();

  DatabaseReference tripRequestRef;

  var geoLocator = Geolocator();
  var locationOptions = LocationOptions(
      accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 4);

  bool isAvailable = false;

  void getCurrentPosition() async {
    Position position = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;
    LatLng pos = LatLng(position.latitude, position.longitude);



    driverInitialPos = pos;

  }

  void getCurrentDriverInfo() async {
    currentFirebaseUser = FirebaseAuth.instance.currentUser;
    DatabaseReference driverRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebaseUser.uid}');

    driverRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        currentDriverInfo = Driver.fromSnapshot(snapshot);
        print("Came");
        print(currentDriverInfo.fullName);
      }
    });

    PushNotificationService pushNotificationService = PushNotificationService();
    pushNotificationService.initialize(context,driverInitialPos);
    pushNotificationService.getToken();

    //HelperMethods.getHistoryInfo(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
          padding: EdgeInsets.only(top: 135),
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          initialCameraPosition: googlePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            mapController = controller;

            getCurrentPosition();
          },
        ),
        Container(
          height: 135,
          width: double.infinity,
          decoration: boxDecoDefualt,
        ),
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AvailabilityButton(
                title: availabilityTitle,
                color: availabilityColor,
                onPressed: () {
                  showModalBottomSheet(
                    isDismissible: false,
                    context: context,
                    builder: (BuildContext context) => ConfirmSheet(
                      title: (!isAvailable) ? 'GO ONLINE' : 'GO OFFLINE',
                      subtitle: (!isAvailable)
                          ? 'You are about to become available to receive trip requests'
                          : 'you will stop receiving new trip requests',
                      onPressed: () {
                        GoOnline();
                        getLocationUpdates();
                        if (!isAvailable) {
                          GoOnline();
                          getLocationUpdates();
                          Navigator.pop(context);
                          setState(() {
                            availabilityColor = Colors.greenAccent;
                            availabilityTitle = 'GO OFFLINE';
                            isAvailable = true;
                          });
                        } else {
                          GoOffline();
                          Navigator.pop(context);
                          setState(() {
                            availabilityColor = Colors.redAccent;
                            availabilityTitle = 'GO ONLINE';
                            isAvailable = false;
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        )
      ],
    );
  }

  void _launchMapsUrl(LatLng _originLatLng, LatLng _destinationLatLng) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&origin=${_originLatLng.latitude},${_originLatLng.longitude}&destination=${_destinationLatLng.latitude},${_destinationLatLng.longitude}&travelmode=driving';
    if (await canLaunch(url)) {
      print("Launching map.... $url");
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void GoOnline() {
    Geofire.initialize('driversAvailable');
    print("Geofire Started");
    Geofire.setLocation(currentFirebaseUser.uid, currentPosition.latitude,
        currentPosition.longitude);
    print("Location set");
    print('GoOnline : currentFirebaseUser.uid-> ' +
        currentFirebaseUser.uid +
        ' currentPosition.latitude-> ' +
        currentPosition.latitude.toString() +
        ' currentPosition.longitude-> ' +
        currentPosition.longitude.toString());

    tripRequestRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebaseUser.uid}/newtrip');
    tripRequestRef.set('waiting');

    tripRequestRef.onValue.listen((event) {
      print('tripRequestRef.onValue.listen-> ${event}');
    });
  }

  /*
  * This responsible to go online for the driver. with help of geofire
  * */
  void GoOffline() {
    Geofire.removeLocation(currentFirebaseUser.uid);
    tripRequestRef.onDisconnect();
    tripRequestRef.remove();
    tripRequestRef = null;
  }

  /*
  * When our drivers go place to place this steam subs are updating the locations
  * */
  void getLocationUpdates() {
    homeTabPositionStream = geoLocator
        .getPositionStream(locationOptions)
        .listen((Position position) {
      currentPosition = position;
      if (isAvailable) {
        //Update the location to the firebase
        Geofire.setLocation(
            currentFirebaseUser.uid, position.latitude, position.longitude);
      }

      //Move the camera position on the map. so whenever driver move camera position moves
      LatLng pos = LatLng(position.latitude, position.longitude);
      mapController.animateCamera(CameraUpdate.newLatLng(pos));
    });
  }
}
