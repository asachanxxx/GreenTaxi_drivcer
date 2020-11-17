import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greentaxi_driver/models/drivers.dart';


String ApiKey = "AIzaSyBSixR5_gpaPVfXXIXV-bdDKW624mBrRqQ";

final CameraPosition googlePlex = CameraPosition(
  target: LatLng(6.885173, 80.015352),
  zoom: 14.4746,
);

final String operatingCountry = 'LK';

Driver currentUser;
Driver fullUser;

User currentFirebaseUser;

StreamSubscription<Position> homeTabPositionStream;

StreamSubscription<Position> ridePositionStream;

//final assetsAudioPlayer = AssetsAudioPlayer();

Position currentPosition;