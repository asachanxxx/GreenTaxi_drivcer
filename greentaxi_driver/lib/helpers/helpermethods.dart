import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greentaxi_driver/dataprovider/appdata.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/helpers/requestHelper.dart';
import 'package:greentaxi_driver/models/address.dart';
import 'package:greentaxi_driver/models/directionDetails.dart';
import 'package:provider/provider.dart';

class HelperMethods {

  static Future<String> findCordinateAddress(Position position, context) async {
    String placeAddress = '';

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      return placeAddress;
    }
    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$ApiKey';

    var response = await RequestHelper.getRequest(url);
    if (response != 'failed') {
      placeAddress = response['results'][0]['formatted_address'];
    }

    Address pickupAddress = new Address();

    pickupAddress.latitude = position.latitude;
    pickupAddress.logitude = position.longitude;
    pickupAddress.placeName = placeAddress;

    Provider.of<AppData>(context, listen: false)
        .updatePickupAddress(pickupAddress);
    return placeAddress;
  }

  static Future<DirectionDetails> getDirectionDetails(LatLng startPosition, LatLng endPosition) async{
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      return null;
    }

    String url = "https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude}, ${startPosition.longitude}&destination=${endPosition.latitude}, ${endPosition.longitude}&mode=driving&key=AIzaSyBSixR5_gpaPVfXXIXV-bdDKW624mBrRqQ";
    print('Direction URL: ' + url);
    var response = await RequestHelper.getRequest(url);
    if (response == 'failed' || response == 'ZERO_RESULTS') {
      return null;
    }


    DirectionDetails directionDetails = DirectionDetails();
    directionDetails.durationText = response['routes'][0]['legs'][0]['duration']['text'];
    print('directionDetails.durationText: ' + directionDetails.durationText);
    directionDetails.durationValue = response['routes'][0]['legs'][0]['duration']['value'];
    print('directionDetails.durationValue: ' + directionDetails.durationValue.toString());

    directionDetails.distanceText = response['routes'][0]['legs'][0]['distance']['text'];
    print('directionDetails.distanceText: ' + directionDetails.distanceText);
    directionDetails.distanceValue = response['routes'][0]['legs'][0]['distance']['value'];
    print('directionDetails.distanceValue: ' + directionDetails.distanceValue.toString());

    directionDetails.encodedPoints = response['routes'][0]['overview_polyline']['points'];
    print('directionDetails.encodedPoints: ' + directionDetails.encodedPoints.toString());

    return directionDetails;
  }

  static int estimateFares(DirectionDetails details){
      /*
      * Fire Calculation
      * ----------------
      * Base Fares: This is the base or the fla amount of money witch will charged for a trip
      *
      * Distance Fares: This is the amount charge for Kilometer base
      *
      * Time Fares: this is the amount charged for every minute spend on the trip
      *
      * Total Fire  = Sum(Base Fares + Distance Fares +Time Fares)
      * KM = 0.3
      * Per Minute = 0.2
      * Base Fire = $3
      * */
    if(details != null) {
      double baseFire = 3;
      double distanceFire = (details.distanceValue / 1000) * 0.3;
      double timeFire = (details.durationValue / 50) * 0.2;

      double totalFire = baseFire + distanceFire + timeFire;

      return totalFire.truncate();
    }else{
      return 0;
    }

  }



}
