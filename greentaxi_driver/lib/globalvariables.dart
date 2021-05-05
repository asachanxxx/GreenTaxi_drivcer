import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:background_location/background_location.dart';
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
import 'package:greentaxi_driver/models/vehicleinfo.dart';
import 'package:greentaxi_driver/models/vtype.dart';
import 'package:logger/logger.dart';

String ApiKey = "AIzaSyBSixR5_gpaPVfXXIXV-bdDKW624mBrRqQ";

final String geoCodeUrl = 'https://maps.googleapis.com/maps/api/geocode/json';


final CameraPosition googlePlex = CameraPosition(
  target: LatLng(6.885173, 80.015352),
  zoom: 14.4746,
);

var logger = Logger(printer: PrettyPrinter(
  methodCount: 0,
  errorMethodCount: 3,
  lineLength: 50,
  colors: true,
  printEmojis: true
));

final String operatingCountry = 'LK';

User currentFirebaseUser;

StreamSubscription<Position> homeTabPositionStream;

StreamSubscription<Position> ridePositionStream;

Location currentPosition;

var assetsAudioPlayer = AssetsAudioPlayer.withId("0");

DatabaseReference rideRef;

Driver currentDriverInfo;
VehicleInfomation currentVehicleInfomation;

String availabilityTitle = 'GO ONLINE';

Color availabilityColor = Colors.redAccent;

SystemSettings systemSettings;

LatLng driverInitialPos;

String dRoute = "";

TripDetails tripDetails;

bool appRestaredMiddleOfRide = false;

PaymentDetails paymentDetails;

List<VType> globalVTypes = [];

bool isOnline = false;
bool vehicleInfoCompleteStatus;
LatLng posError = LatLng(6.877133555388284, 79.98983549839619);
String currentTab = "Home";

final defaultLocationLat = 6.878947;
final defaultLocationLng = 79.921883;



String userProfilePath = "images/drivers/profilePics";
String userDocumentPath = "images/drivers/docpath";
String userAudioPath = "audio/rideRequest";

void showAlertGlobal(BuildContext context, String title, String content, IconData iconData) {
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => AlertDialog(
            title: Center(
                child: Column(
              children: <Widget>[
                Icon(
                  iconData,
                  color: Color(0xFFff6f00),
                  size: 80,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  title,
                  style: GoogleFonts.roboto(
                      fontSize: 20, color: Color(0xFFff6f00)),
                ),
              ],
            )),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              //position
              mainAxisSize: MainAxisSize.min,
              // wrap content in flutter
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Text(
                  content,
                  style: GoogleFonts.roboto(fontSize: 18),
                ),
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
          ));
}

String VtypeConverter(String Vtype) {
  String GlobalVtype = "Type1";
  if (Vtype == null || Vtype.trim() == "") {
    GlobalVtype = "Type1";
  } else {
    switch (Vtype.trim().toUpperCase()) {
      case "TUK":
        GlobalVtype = "Type1";
        break;
      case "NANO":
        GlobalVtype = "Type2";
        break;
      case "ALTO":
        GlobalVtype = "Type3";
        break;
      case "WAGONR":
        GlobalVtype = "Type4";
        break;
      case "CLASSIC":
        GlobalVtype = "Type5";
        break;
      case "DELUXE":
        GlobalVtype = "Type6";
        break;
      case "MINI-VAN":
        GlobalVtype = "Type7";
        break;
      case "VAN":
        GlobalVtype = "Type8";
        break;
    }
  }

  return GlobalVtype;
}

double roundUp(double val) {
  return double.parse(val.toStringAsFixed(2));
}

bool fireBaseLogEnable = true;