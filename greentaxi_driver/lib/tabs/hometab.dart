import 'dart:async';
import 'dart:ui';
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
import 'package:greentaxi_driver/screens/newtripspage.dart';
import 'package:greentaxi_driver/styles/styles.dart';
import 'package:greentaxi_driver/widgets/AvailabilityButton.dart';
import 'package:greentaxi_driver/widgets/BrandDivider.dart';
import 'package:greentaxi_driver/widgets/ConfirmSheet.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with WidgetsBindingObserver {



  var earnignController = TextEditingController();
  var passwordController = TextEditingController();


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

  void getCurrentPosition() async {
    print("Inside getCurrentPosition");
    try {
      Position position = await HelperMethods.determinePositionRaw();
      // setState(() {
        currentPosition = position;
        LatLng pos = LatLng(position.latitude, position.longitude);
        driverInitialPos = pos;
      // });
    } catch (e) {
      print('Error: ${e.toString()}');
    }
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
        print("onlineStatus : ${snapshot.value["onlineStatus"] != null ?snapshot.value["onlineStatus"] : ""}");

        if(snapshot.value["onlineStatus"] != null && snapshot.value["onlineStatus"] == "online"){
          isOnlineStatus = true;
        }
        if(snapshot.value["earnings"] != null){
          print("earnings ${snapshot.value["earnings"].toString()}" );
          earnings = double.tryParse(snapshot.value["earnings"].toString());
        }

        if(snapshot.value["inMiddleOfTrip"] != null){
          print("inMiddleOfTrip ${snapshot.value["inMiddleOfTrip"].toString()}" );
          inMiddleOfTrip =  snapshot.value["inMiddleOfTrip"].toString().toLowerCase() == 'true';
        }
        if(snapshot.value["rideId"] != null){
          print("existingRideId  ${snapshot.value["rideId"].toString()}" );
          existingRideId = snapshot.value["rideId"];
        }
        if(inMiddleOfTrip){
          restartRide();
        }

      }
    });

    PushNotificationService pushNotificationService = PushNotificationService();
    pushNotificationService.initialize(context, driverInitialPos);
    pushNotificationService.getToken();

  }

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title){
    final snackbar = SnackBar(
      content: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }


  void availabilityButtonPress() async{
    //check network availability
    var connectivityResult = await Connectivity().checkConnectivity();
    if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){
      showAlertGlobal(context, "No internet Connection", 'No internet connectivity(අන්තර්ජාල සම්බන්ධතාවය විසන්ධි වී ඇත. කරුණාකර නැවත සම්බන්ද කරන්න.)');
      return;
    }

    print("availabilityButtonPress->isOnlineStatus123  $isOnlineStatus");
    if (isOnlineStatus) {
      print("availabilityButtonPress() point 0");
      GoOnline();
      print("availabilityButtonPress() point 1");
      getLocationUpdates();
      print("availabilityButtonPress() point 2");
      setState(() {
        availabilityColor = Colors.greenAccent;
        availabilityTitle = 'GO OFFLINE';
        isAvailable = true;
      });
    }
  }


  void checkAvailablity(context, String rideID) {

    DatabaseReference rideRef = FirebaseDatabase.instance.reference().child('rideRequest/$rideID');
    rideRef.once().then((DataSnapshot snapshot){

      // Navigator.pop(context);
      print("availabilityButtonPress snapshot ========================================================================================> $snapshot");
      if(snapshot.value != null){

        double pickupLat = double.parse(snapshot.value['location']['latitude'].toString());
        double pickupLng = double.parse(snapshot.value['location']['longitude'].toString());
        String pickupAddress = snapshot.value['pickup_address'].toString();

        double destinationLat = double.parse(snapshot.value['destination']['latitude'].toString());
        double destinationLng = double.parse(snapshot.value['destination']['longitude'].toString());

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

        if(snapshot.value['ownDriver'] != null){
          tripDetails.commissionedDriverId = "system";
          tripDetails.commissionApplicable = false;
        }else if (snapshot.value['ownDriver']  == "system") {
          tripDetails.commissionedDriverId = "system";
          tripDetails.commissionApplicable = false;
        }else{
          tripDetails.commissionedDriverId = snapshot.value['ownDriver'] ;
          tripDetails.commissionApplicable = true;
        }

        print("tripDetails.commissionedDriverId = ${tripDetails.commissionedDriverId} tripDetails.commissionApplicable = ${tripDetails.commissionApplicable}");

        Navigator.pop(context);

        HelperMethods.disableHomTabLocationUpdates();
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  NewTripPage(
                    tripDetails: tripDetails,restartRide: true,
                  ),
            ));
      }

    });
  }


  restartRide() async {
    print("On _checkWifi inMiddleOfTrip = $inMiddleOfTrip  existingRideId = $existingRideId");
    if(inMiddleOfTrip) {
      showAlert(context,existingRideId);
    }
  }

  void showAlert(BuildContext context , String existingRideIdx) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            AlertDialog(
              title: Center(child: Column(
                children: <Widget>[
                  Icon(Icons.home, color: Colors.black54, size: 80,),
                  SizedBox(height: 20,),
                  Text('Unfinished ride detected.',
                    style: GoogleFonts.roboto(fontSize: 20),),
                ],
              )),
              content: Text(
                "The system close in middle of a ride. please press ok to continue with the ride!",
                style: GoogleFonts.roboto(fontSize: 17),),
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
            )
    );
  }




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentTab = "Home";
    getCurrentPosition();
    getCurrentDriverInfo();

    print("initState->isOnlineStatus  $isOnlineStatus");
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

            //getCurrentPosition();

            availabilityButtonPress();
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
            onTap: () {

            },
            child: Container(
              alignment: Alignment.center,
              decoration: kBoxDecorationStyleFloat,
              height: 40.0,
              width: 130,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children:<Widget> [
                  SizedBox(width: 10,),
                  Icon(
                    Icons.call ,
                    color: Color(0xfff57f17),
                  ),
                  SizedBox(width: 8,),
                  Text("Book a trip",style: GoogleFonts.roboto(fontSize: 14),),

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
            children:<Widget> [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AvailabilityButton(
                    title: availabilityTitle,
                    color: availabilityColor,
                    onPressed: () async  {
                      //check network availability
                      var connectivityResult = await Connectivity().checkConnectivity();
                      if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){
                        showAlertGlobal(context, "No internet Connection", 'No internet connectivity(අන්තර්ජාල සම්බන්ධතාවය විසන්ධි වී ඇත. කරුණාකර නැවත සම්බන්ද කරන්න.)');
                        return;
                      }

                      print("ConfirmSheet onPressed");
                      bool error = false;
                      var location = await HelperMethods.determinePositionRaw().catchError((Object err){
                        print("Call location in catchError $error");
                        error = true;
                      });

                      print("Call location in ConfirmSheet $error");

                      if(error){
                        showToastRaw(context,"කරුණාකර  ඔබගේ දුරකතනයේ (ස්ථාන සේවා)Location Service සක්‍රිය කරන්න");
                      }else {
                        showModalBottomSheet(
                          isDismissible: false,
                          context: context,
                          builder: (BuildContext context) =>
                              ConfirmSheet(
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
              SizedBox(height: 10,),
              BrandDivider(),
              SizedBox(height: 10,),
              Container(
                child: Padding(
                  padding:  EdgeInsets.only(left: 20,right: 20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                    children:<Widget> [
                      _textTodayEarnings(),
                      SizedBox(width: 10,),
                      _textTodayCommission(),


                    ],
                  ),
                ),
              )
            ],
          ),
        )

      ],
    );
  }

  Widget _textTodayEarnings() {
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
          child: Text("LKR ${earnings.toString()}",
            style: GoogleFonts.roboto(
                color: Colors.white, fontSize: 18,fontWeight: FontWeight.bold)
            ),
          ),
      ],
    );
  }

  Widget _textTodayCommission() {
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
          child: Text( "LKR 0.00",textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                color: Colors.white, fontSize: 18,fontWeight: FontWeight.bold)
          ),
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
    if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){
      showAlertGlobal(context, "No internet Connection", 'No internet connectivity(අන්තර්ජාල සම්බන්ධතාවය විසන්ධි වී ඇත. කරුණාකර නැවත සම්බන්ද කරන්න.)');
      return;
    }
    isOnline = true;
    cancelLocationUpdate = false;
    Geofire.initialize('driversAvailable');
    print("Geofire Started");
    Geofire.setLocation(currentFirebaseUser.uid, driverInitialPos != null ?driverInitialPos.latitude : posError.latitude,
        driverInitialPos != null ? driverInitialPos.longitude: posError.longitude);
    print("Location set");

    tripRequestRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebaseUser.uid}/newtrip');
    tripRequestRef.set('waiting');

    tripRequestRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebaseUser.uid}/onlineStatus');
    tripRequestRef.set('online');


    tripRequestRef.onValue.listen((event) {
      print('tripRequestRef.onValue.listen-> ${event}');
    });
  }

  /*
  * This responsible to go online for the driver. with help of geofire
  * */
  void GoOffline()  async{
    var connectivityResult = await Connectivity().checkConnectivity();
    if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){
      showAlertGlobal(context, "No internet Connection", 'No internet connectivity(අන්තර්ජාල සම්බන්ධතාවය විසන්ධි වී ඇත. කරුණාකර නැවත සම්බන්ද කරන්න.)');
      return;
    }
    isOnline = false;
    cancelLocationUpdate = true;

    Geofire.removeLocation(currentFirebaseUser.uid);
    tripRequestRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebaseUser.uid}/newtrip');

    tripRequestRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebaseUser.uid}/onlineStatus');
    tripRequestRef.set('offline');
    setState(() {
      cancelLocationUpdate = true;
    });

    //tripRequestRef.set('offline');
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
    print(" getLocationUpdates Status Update canc elLocationUpdate= $cancelLocationUpdate   isAvailable= $isAvailable");
    homeTabPositionStream = Geolocator
        .getPositionStream(desiredAccuracy: LocationAccuracy.bestForNavigation,distanceFilter: 2)
        .listen((Position position) {
      print(" getLocationUpdates Status  Inside= $cancelLocationUpdate   isAvailable= $isAvailable");

      currentPosition = position;
      if (isAvailable) {
        //Update the location to the firebase
        print(
            "LocationUpdates -> ${currentFirebaseUser.uid} ON ${position.latitude.toString()} and ${position.longitude.toString()}");
        Geofire.setLocation(
            currentFirebaseUser.uid, position.latitude, position.longitude);
      }
      if(cancelLocationUpdate){
        homeTabPositionStream?.cancel();
      }else{
          print("Inside Move Camara Position..............");
          LatLng pos = LatLng(position.latitude, position.longitude);
          mapController.animateCamera(CameraUpdate.newLatLng(pos));
      }
    });
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
