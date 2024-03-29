import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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