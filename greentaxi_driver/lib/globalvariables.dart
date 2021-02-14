import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greentaxi_driver/dataprovider/SystemConfigs.dart';
import 'package:greentaxi_driver/models/drivers.dart';
import 'package:greentaxi_driver/models/paymenthistory.dart';
import 'package:greentaxi_driver/models/tripdetails.dart';
import 'package:greentaxi_driver/models/vtype.dart';

String ApiKey = "AIzaSyBSixR5_gpaPVfXXIXV-bdDKW624mBrRqQ";

final CameraPosition googlePlex = CameraPosition(
  target: LatLng(6.885173, 80.015352),
  zoom: 14.4746,
);

final String operatingCountry = 'LK';

// Driver currentUser;
Driver fullUser;

User currentFirebaseUser;

StreamSubscription<Position> homeTabPositionStream;

StreamSubscription<Position> ridePositionStream;

//final assetsAudioPlayer = AssetsAudioPlayer();

Position currentPosition;

final assetsAudioPlayer = AssetsAudioPlayer();

DatabaseReference rideRef;

Driver currentDriverInfo;

String availabilityTitle = 'GO ONLINE';
Color availabilityColor = Colors.redAccent;

SystemSettings systemSettings;

LatLng driverInitialPos;

String dRoute = "";
TripDetails tripDetails;
bool appRestaredMiddleOfRide = false;

PaymentDetails paymentDetails;

List<VType> globalVTypes = new List<VType>();

bool isOnline = false;
bool vehicleInfoCompleteStatus;
LatLng posError = LatLng(6.877133555388284, 79.98983549839619);
String currentTab = "Home";

String userProfilePath = "images/drivers/profilePics";
String userDocumentPath = "images/drivers/docpath";


void showAlertGlobal(BuildContext context , String title, String content) {
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) =>
          AlertDialog(
            title: Center(child: Column(
              children: <Widget>[
                Icon(Icons.signal_wifi_off,  color: Color(0xFFff6f00), size: 80,),
                SizedBox(height: 20,),
                Text(title,
                  style: GoogleFonts.roboto(fontSize: 20, color: Color(0xFFff6f00)),),
              ],
            )),

            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              //position
              mainAxisSize: MainAxisSize.min,
              // wrap content in flutter
              children: <Widget>[
                SizedBox(height: 10,),
                Text(
                  content, style: GoogleFonts.roboto(fontSize: 18),),

              ],
            ),

            actions: <Widget>[
              Center(
                child: FlatButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          )
  );
}