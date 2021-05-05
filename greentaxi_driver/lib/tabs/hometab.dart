import 'dart:async';
import 'dart:ui';
import 'package:background_location/background_location.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/helpers/helpermethods.dart';
import 'package:greentaxi_driver/helpers/pushnotificationservice.dart';
import 'package:greentaxi_driver/models/drivers.dart';
import 'package:greentaxi_driver/models/tripdetails.dart';
import 'package:greentaxi_driver/models/vehicleinfo.dart';
import 'package:greentaxi_driver/screens/misc/requesttrip.dart';
import 'package:greentaxi_driver/screens/newtripspage.dart';
import 'package:greentaxi_driver/shared/repository/firebase_service.dart';
import 'package:greentaxi_driver/shared/repository/sales_service.dart';
import 'package:greentaxi_driver/styles/styles.dart';
import 'package:greentaxi_driver/widgets/AvailabilityButton.dart';
import 'package:greentaxi_driver/widgets/BrandDivider.dart';
import 'package:greentaxi_driver/widgets/ConfirmSheet.dart';
import 'package:greentaxi_driver/widgets/TaxiButton.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with WidgetsBindingObserver {
  var earnignController = TextEditingController();
  var passwordController = TextEditingController();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();

  DatabaseReference tripRequestRef;

  var geoLocator = Geolocator();
  var locationOptions = LocationOptions(
      accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 4);

  bool isAvailable = false;
  bool isOnlineStatus = false;
  bool cancelLocationUpdate = false;
  bool _tryAgain = false;
  double earnings = 0.0;

  var inMiddleOfTrip = false;
  var existingRideId = "";
  // double getEarning(){
  //    earnings = 0.0;
  // }

  @override
  void initState() {
    super.initState();
    currentTab = "Home";
    print("Just before getCurrentPosition");
    print("System Config: fireBaseLogEnable ${systemSettings != null? systemSettings.fireBaseLogEnable: "Config Null"}");
    fireBaseLogEnable = systemSettings != null? systemSettings.fireBaseLogEnable:false;
    initializeTab();
  }

  void initializeTab() async {
    logger.d("Inside getCurrentPosition");
    try {
      //Position position = await HelperMethods.determinePositionRaw();
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      currentPosition = Location(longitude: position.longitude,latitude: position.latitude);
      print('Inside getCurrentPosition position.latitude = ${position != null ? position.latitude : "position Is empty"} ');
      print('Inside getCurrentPosition currentPosition.latitude = ${currentPosition != null ? currentPosition.latitude : "currentPosition Is empty"} ');

      await getCurrentDriverInfo(currentPosition);
    } catch (e) {
      logger.e('Error: ${e.toString()}');
    }
  }

  Future<void> getCurrentDriverInfo(Location currentPositionx) async {
    print("Inside getCurrentDriverInfo");
    FirebaseService.logtoFirebaseInfo("HomeTab- getCurrentDriverInfo ","Inside the Method");
    currentFirebaseUser = FirebaseAuth.instance.currentUser;
    DatabaseReference driverRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebaseUser.uid}/profile');

    driverRef.once().then((DataSnapshot snapshot) {
      FirebaseService.logtoFirebaseInfo("HomeTab- getCurrentDriverInfo ","isOnlineStatus =   ${snapshot.value["onlineStatus"]}");

      if (snapshot.value != null) {
        currentDriverInfo = Driver.fromSnapshot(snapshot);
        logger.d(
            "onlineStatus : ${snapshot.value["onlineStatus"] != null ? snapshot.value["onlineStatus"] : ""}");

        if (snapshot.value["onlineStatus"] != null &&
            snapshot.value["onlineStatus"] == "online") {
          logger.d("Inside getCurrentDriverInfo isOnlineStatus = true");
          FirebaseService.logtoFirebaseInfo("HomeTab- getCurrentDriverInfo ","Set isOnlineStatus =  True");
          isOnlineStatus = true;
        }
        if (snapshot.value["earnings"] != null) {
          logger.d("earnings ${snapshot.value["earnings"].toString()}");
          earnings = double.tryParse(snapshot.value["earnings"].toString());
        }

        if (snapshot.value["inMiddleOfTrip"] != null) {
          logger.d(
              "inMiddleOfTrip ${snapshot.value["inMiddleOfTrip"].toString()}");
          inMiddleOfTrip =
              snapshot.value["inMiddleOfTrip"].toString().toLowerCase() ==
                  'true';
        }
        if (snapshot.value["rideId"] != null) {
          logger.d("existingRideId  ${snapshot.value["rideId"].toString()}");
          existingRideId = snapshot.value["rideId"];
        }
        if (inMiddleOfTrip) {
          restartRide();
        }
        availabilityButtonPress();
      }
    });

    DataSnapshot vehicleRef = await FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebaseUser.uid}/vehicle_details')
        .once();

    currentVehicleInfomation = VehicleInfomation.fromShapShot(vehicleRef);
    //logger.d("Vehicle type :- ${currentVehicleInfomation.vehicleType}");
    logger.d(
        "Vehicle type VtypeConverter :- ${VtypeConverter(currentVehicleInfomation.vehicleType)}");
    var latlng = new LatLng(currentPositionx.latitude, currentPositionx.longitude);
    PushNotificationService pushNotificationService = PushNotificationService();
    pushNotificationService.initialize(context, latlng);
    pushNotificationService.getToken();
  }

  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  void availabilityButtonPress() async {
    FirebaseService.logtoFirebaseInfo("HomeTab- availabilityButtonPress ","Start of the method");
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      showAlertGlobal(
          context,
          "No internet Connection",
          'No internet connectivity(අන්තර්ජාල සම්බන්ධතාවය විසන්ධි වී ඇත. කරුණාකර නැවත සම්බන්ද කරන්න.)',
          Icons.signal_wifi_off);
      return;
    }

    FirebaseService.logtoFirebaseInfo("HomeTab- availabilityButtonPress ","isOnlineStatus =   $isOnlineStatus");
    logger.d("availabilityButtonPress->isOnlineStatus123  $isOnlineStatus");
    if (isOnlineStatus) {
      FirebaseService.logtoFirebaseInfo("HomeTab- availabilityButtonPress ","availabilityButtonPress() point 0");
      logger.d("availabilityButtonPress() point 0");

      GoOnline();

      logger.d("availabilityButtonPress() point 1");
      FirebaseService.logtoFirebaseInfo("HomeTab- availabilityButtonPress ","availabilityButtonPress() point 1");

      getLocationUpdates();

      logger.d("availabilityButtonPress() point 2");
      FirebaseService.logtoFirebaseInfo("HomeTab- availabilityButtonPress ","availabilityButtonPress() point 2");


      setState(() {
        availabilityColor = Colors.greenAccent;
        availabilityTitle = 'GO OFFLINE';
        isAvailable = true;
      });

      FirebaseService.logtoFirebaseInfo("HomeTab- availabilityButtonPress ","End Of the method");


    }
  }

  void checkAvailablity(context, String rideID) {
    print("checkAvailablity rideID $rideID");
    DatabaseReference rideRef =
        FirebaseDatabase.instance.reference().child('rideRequest/$rideID');
    rideRef.once().then((DataSnapshot snapshot) {
      // Navigator.pop(context);
        if (snapshot.value != null) {
        double pickupLat =
            double.parse(snapshot.value['location']['latitude'].toString());
        double pickupLng =
            double.parse(snapshot.value['location']['longitude'].toString());
        String pickupAddress = snapshot.value['pickup_address'].toString();

        double destinationLat =
            double.parse(snapshot.value['destination']['latitude'].toString());
        double destinationLng =
            double.parse(snapshot.value['destination']['longitude'].toString());

        String destinationAddress = snapshot.value['destination_address'];
        String paymentMethod = snapshot.value['payment_method'];
        String riderName = snapshot.value['rider_name'];
        String riderPhone = snapshot.value['rider_phone'];

        TripDetails tripDetails = TripDetails();

        tripDetails.rideID = rideID;
        tripDetails.pickupAddress = pickupAddress;
        tripDetails.destinationAddress = destinationAddress;
        tripDetails.pickup = LatLng(pickupLat, pickupLng);
        tripDetails.destination = LatLng(destinationLat, destinationLng);
        //tripDetails.driverLocation = LatLng(pos.latitude, pos.longitude);
        tripDetails.paymentMethod = paymentMethod;
        tripDetails.riderName = riderName;
        tripDetails.riderPhone = riderPhone;
        tripDetails.status = snapshot.value['status'];

        if (snapshot.value['ownDriver'] != null) {
          tripDetails.commissionedDriverId = "system";
          tripDetails.commissionApplicable = false;
        } else if (snapshot.value['ownDriver'] == "system") {
          tripDetails.commissionedDriverId = "system";
          tripDetails.commissionApplicable = false;
        } else {
          tripDetails.commissionedDriverId = snapshot.value['ownDriver'];
          tripDetails.commissionApplicable = true;
        }

        print(
            "tripDetails.commissionedDriverId = ${tripDetails.commissionedDriverId} tripDetails.commissionApplicable = ${tripDetails.commissionApplicable}");

        Navigator.pop(context);

        HelperMethods.disableHomTabLocationUpdates();
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewTripPage(
                tripDetails: tripDetails,
                restartRide: true,
              ),
            ));
      }else{
        var ref = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/profile/inMiddleOfTrip');
        ref.set(false);
        Navigator.pop(context);
      }
    });
  }

  restartRide() async {
    logger.d(
        "On _checkWifi inMiddleOfTrip = $inMiddleOfTrip  existingRideId = $existingRideId");
    if (inMiddleOfTrip) {
      showAlert(context, existingRideId);
    }
  }

  void showAlert(BuildContext context, String existingRideIdx) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog(
              title: Center(
                  child: Column(
                children: <Widget>[
                  Icon(
                    Icons.home,
                    color: Colors.black54,
                    size: 80,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Unfinished ride detected.',
                    style: GoogleFonts.roboto(fontSize: 20),
                  ),
                ],
              )),
              content: Text(
                "The system close in middle of a ride. please press ok to continue with the ride!",
                style: GoogleFonts.roboto(fontSize: 17),
              ),
              actions: <Widget>[
                Center(
                  child: FlatButton(
                    child: Text("OK"),
                    onPressed: () {
                      checkAvailablity(context, existingRideIdx);
                    },
                  ),
                ),
              ],
            ));
  }





  @override
  Widget build(BuildContext context) {
    return Stack(
      key: scaffoldKey,
      children: <Widget>[
        GoogleMap(
          padding: EdgeInsets.only(top: 190),
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          initialCameraPosition: googlePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            print("Map Controller Initialzied");
            mapController = controller;

            print('Inside GoogleMap currentPosition.latitude = ${currentPosition != null ? currentPosition.latitude : "currentPosition Is empty"} ');



          },
        ),
        Container(
          //child: Text("Check Container"),
          height: 190,
          width: double.infinity,
          decoration: boxDecoDefualt,
        ),

        ///Menu Buttons *************************************************************************************************************
        Positioned(
          top: 200,
          left: 15,
          child: GestureDetector(
            onTap: () async {
              //showAlertBookTrip(context,"Book a trip for customer");

              FirebaseService.logtoFirebase(currentFirebaseUser.uid , "Home Tab- Book A trip","Info", "Testing the Method");

              var respons = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SimpleRecorder(),
                  ));
            },
            child: Container(
              alignment: Alignment.center,
              decoration: kBoxDecorationStyleFloat,
              height: 40.0,
              width: 130,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.call,
                    color: Color(0xfff57f17),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "Book a trip",
                    style: GoogleFonts.roboto(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          top: 40,
          left: 0,
          right: 0,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AvailabilityButton(
                    title: availabilityTitle,
                    color: availabilityColor,
                    onPressed: () async {
                      //check network availability
                      var connectivityResult =
                          await Connectivity().checkConnectivity();
                      if (connectivityResult != ConnectivityResult.mobile &&
                          connectivityResult != ConnectivityResult.wifi) {
                        showAlertGlobal(
                            context,
                            "No internet Connection",
                            'No internet connectivity(අන්තර්ජාල සම්බන්ධතාවය විසන්ධි වී ඇත. කරුණාකර නැවත සම්බන්ද කරන්න.)',
                            Icons.signal_wifi_off);
                        return;
                      }

                      print("ConfirmSheet onPressed");
                      bool error = false;
                      var location = await HelperMethods.determinePositionRaw()
                          .catchError((Object err) {
                        print("Call location in catchError $error");
                        error = true;
                      });

                      print("Call location in ConfirmSheet $error");

                      if (error) {
                        showToastRaw(context,
                            "කරුණාකර  ඔබගේ දුරකතනයේ (ස්ථාන සේවා)Location Service සක්‍රිය කරන්න");
                      } else {
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
                      }
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              BrandDivider(),
              SizedBox(
                height: 10,
              ),
              FutureBuilder(
                  future: SalesService.getdateWiseSummary(context),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        child: Padding(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              _textTodayEarnings(snapshot.data.totalEarning),
                              SizedBox(
                                width: 10,
                              ),
                              _textTodayCommission(
                                  snapshot.data.totalCommission),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        child: Padding(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              _textTodayEarnings(0.00),
                              SizedBox(
                                width: 10,
                              ),
                              _textTodayCommission(0.00),
                            ],
                          ),
                        ),
                      );
                    }
                  })
            ],
          ),
        )
      ],
    );
  }

  Widget _textTodayEarnings(double earning) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 45),
          child: Text(
            'EARNING',
            style: kLabelStyleEarnig,
          ),
        ),
        SizedBox(height: 5.0),
        Container(
          alignment: Alignment.center,
          decoration: kBoxDecorationStyle,
          height: 40.0,
          width: 150,
          child: Text("LKR $earning",
              style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _textTodayCommission(double comm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Text(
            'COMMISSION',
            style: kLabelStyleEarnig,
          ),
        ),
        SizedBox(height: 5.0),
        Container(
          alignment: Alignment.center,
          decoration: kBoxDecorationStyle,
          height: 40.0,
          width: 150,
          child: Text("LKR $comm",
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
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

  static void showToastRaw(BuildContext context, String text) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(text),
        action: SnackBarAction(
            label: 'Hide', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  void GoOnline() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      showAlertGlobal(
          context,
          "No internet Connection",
          'No internet connectivity(අන්තර්ජාල සම්බන්ධතාවය විසන්ධි වී ඇත. කරුණාකර නැවත සම්බන්ද කරන්න.)',
          Icons.signal_wifi_off);
      return;
    }

    logger.d('Inside GoOnline currentPosition.latitude = ${currentPosition != null ? currentPosition.latitude : "currentPosition Is empty"} ');

    isOnline = true;
    cancelLocationUpdate = false;
    Geofire.initialize('driversAvailable');
    logger.d("Geofire Started");
    Geofire.setLocation(
        currentFirebaseUser.uid,
        currentPosition != null
            ? currentPosition.latitude
            : posError.latitude,
        currentPosition != null
            ? currentPosition.longitude
            : posError.longitude);
    print("Location set");

    tripRequestRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebaseUser.uid}/profile/newtrip');
    tripRequestRef.set('waiting');

    tripRequestRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebaseUser.uid}/profile/onlineStatus');
    tripRequestRef.set('online');

    tripRequestRef.onValue.listen((event) {
      logger.d('tripRequestRef.onValue.listen-> ${event}');
    });


  }

  /*
  * This responsible to go online for the driver. with help of geofire
  * */
  void GoOffline() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      showAlertGlobal(
          context,
          "No internet Connection",
          'No internet connectivity(අන්තර්ජාල සම්බන්ධතාවය විසන්ධි වී ඇත. කරුණාකර නැවත සම්බන්ද කරන්න.)',
          Icons.signal_wifi_off);
      return;
    }
    isOnline = false;
    cancelLocationUpdate = true;

    Geofire.removeLocation(currentFirebaseUser.uid);
    tripRequestRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebaseUser.uid}/profile/newtrip');

    tripRequestRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebaseUser.uid}/profile/onlineStatus');
    tripRequestRef.set('offline');
    setState(() {
      cancelLocationUpdate = true;
    });
    tripRequestRef.onDisconnect();
  }

  /*
  * When our drivers go place to place this steam subs are updating the locations
  * Internally the Geolocator will check if Google Play Services are installed on the device.
  * If they are not installed the Geolocator plugin will automatically switch to the LocationManager
  * implementation. However if you want to force the Geolocator plugin to use the LocationManager
  * implementation even when the Google Play Services are installed you could set this property to true.
  * */

  void getLocationUpdates() {

    // var lastKnownPosition =  Geolocator.getLastKnownPosition().then((value){
    //   logger.d("lastKnownPosition ${value.latitude}");
    //   currentPosition = new Location(latitude: value.latitude, longitude: value.longitude);
    // });
    logger.d(
        "getLocationUpdates cancelLocationUpdate= $cancelLocationUpdate   isAvailable= $isAvailable");
    homeTabPositionStream = Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 2)
        .listen((Position position) {
      logger.d(
          "getLocationUpdates Status  Inside= $cancelLocationUpdate   isAvailable= $isAvailable");

      currentPosition = new Location(longitude: position.longitude,latitude: position.latitude);
      if (isAvailable) {
        //Update the location to the firebase
        logger.d(
            "LocationUpdates -> ${currentFirebaseUser.uid} ON ${position.latitude.toString()} and ${position.longitude.toString()}");
        Geofire.setLocation(
            currentFirebaseUser.uid, position.latitude, position.longitude);
      }
      if (cancelLocationUpdate) {
        homeTabPositionStream?.cancel();
      } else {
        LatLng pos = LatLng(position.latitude, position.longitude);
        if(mapController != null) {
          mapController.animateCamera(CameraUpdate.newLatLng(pos));
        }
      }
    });
  }

  void showAlertBookTrip(BuildContext context, String title) {
    showDialog(
        useSafeArea: true,
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) => AlertDialog(
              title: Center(
                  child: Column(
                children: <Widget>[
                  Icon(
                    Icons.supervised_user_circle_rounded,
                    color: Color(0xFFff6f00),
                    size: 60,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    title,
                    style: GoogleFonts.roboto(
                        fontSize: 20, color: Color(0xFFff6f00)),
                  ),
                ],
              )),
              contentPadding: EdgeInsets.all(10.0),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  //position
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 20, bottom: 20, left: 5, right: 5),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular((25))),
                                            border: Border.all(
                                                width: 3.0,
                                                color: Color(0xFFef6c00)),
                                          ),
                                          child: Icon(Icons.call,
                                              color: Color(0xFFef6c00)),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'Voice Cut',
                                          style: GoogleFonts.roboto(
                                              color: Color(0xFFef6c00)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular((25))),
                                            border: Border.all(
                                                width: 3.0,
                                                color: Color(0xFFef6c00)),
                                          ),
                                          child: Icon(Icons.list,
                                              color: Color(0xFFef6c00)),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text('Browse Trips',
                                            style: GoogleFonts.roboto(
                                                color: Color(0xFFef6c00))),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    print("deactivated");
    currentTab = "";
    cancelLocationUpdate = true;
    mapController.dispose();
    super.deactivate();
  }

  /*
    Dispose is called when the State object is removed, which is permanent.
    This method is where you should unsubscribe and cancel all animations, streams, etc.
    */
  @override
  void dispose() {
    // TODO: implement dispose

    print("disposed");
    super.dispose();
  }
}
