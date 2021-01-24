import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/helpers/pushnotificationservice.dart';
import 'package:greentaxi_driver/models/drivers.dart';
import 'package:greentaxi_driver/screens/newtripspage.dart';
import 'package:greentaxi_driver/widgets/TaxiButton.dart';

class RestartScreen extends StatefulWidget {
  static const String Id = 'restartscreen';
  //final String tripDetailsId;
  //RestartScreen({this.tripDetailsId});

  @override
  _RestartScreenState createState() => _RestartScreenState();
}

class _RestartScreenState extends State<RestartScreen> {

  var geoLocator = Geolocator();
  var locationOptions =
  LocationOptions(accuracy: LocationAccuracy.bestForNavigation);

  //
  // void fetchRideInfo() async {
  //   CompanyRepository().getTripDetails(dRoute).then((
  //       value) =>
  //   {
  //     setState(() {
  //       tripDetails = value;
  //     })
  //   });
  // }

  @override
  initState(){
    super.initState();
    //tripDetails =  await CompanyRepository().getTripDetails(dRoute);
    //fetchRideInfo();
    appRestaredMiddleOfRide = true;
    print("initState -> tripDetails ${tripDetails.riderName}"); // but here It's null!
    getCurrentDriverInfo();
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

    ridePositionStream = Geolocator
        .getPositionStream()
        .listen((Position position) {
      currentPosition = position;
    });

    print("getCurrentDriverInfo  currentPosition ${currentPosition.longitude.toString()} ");

    PushNotificationService pushNotificationService = PushNotificationService();
    pushNotificationService.initialize(context,driverInitialPos);
    pushNotificationService.getToken();

    //HelperMethods.getHistoryInfo(context);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(15.0, 30.0, 0.0, 0.0),
                      child: Text(
                        'taXy',
                        style:
                        GoogleFonts.lobster(fontSize: 80.0, fontWeight: FontWeight.bold, color: Color(0xFFff6f00) ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(140.0, 40.0, 0.0, 0.0),
                      child: Text(
                        '.',
                        style: TextStyle(
                            fontSize: 80.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFff6f00)),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 30,),
              Text("You are returning from a restart...  $dRoute",
                style: GoogleFonts.roboto(fontSize: 22),),
              TaxiButton(
                color: Colors.deepOrangeAccent,
                title: "Continue With Ride",
                onPress: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            NewTripPage(
                              tripDetails: tripDetails,
                            ),
                      ));
                },),
              TaxiButton(
                color: Colors.deepOrangeAccent,
                title: "End the current Ride",
                onPress: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            NewTripPage(
                              tripDetails: tripDetails,
                            ),
                      ));
                },)
            ],
          ),
        ),
      ),
    );
  }
}
