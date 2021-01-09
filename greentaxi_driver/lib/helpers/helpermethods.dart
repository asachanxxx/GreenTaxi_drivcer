import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greentaxi_driver/dataprovider/appdata.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/helpers/requestHelper.dart';
import 'package:greentaxi_driver/models/address.dart';
import 'package:greentaxi_driver/models/directionDetails.dart';
import 'package:greentaxi_driver/models/paymenthistory.dart';
import 'package:greentaxi_driver/models/tripdetails.dart';
import 'package:greentaxi_driver/models/vtype.dart';
import 'package:greentaxi_driver/widgets/ProgressDialog.dart';
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

  static Future<DirectionDetails> getDirectionDetails(
      LatLng startPosition, LatLng endPosition) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      return null;
    }

    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude}, ${startPosition.longitude}&destination=${endPosition.latitude}, ${endPosition.longitude}&mode=driving&key=AIzaSyBSixR5_gpaPVfXXIXV-bdDKW624mBrRqQ";
    print('Direction URL: ' + url);
    var response = await RequestHelper.getRequest(url);
    if (response == 'failed' || response == 'ZERO_RESULTS') {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();
    directionDetails.durationText =
        response['routes'][0]['legs'][0]['duration']['text'];
    print('directionDetails.durationText: ' + directionDetails.durationText);
    directionDetails.durationValue =
        response['routes'][0]['legs'][0]['duration']['value'];
    print('directionDetails.durationValue: ' +
        directionDetails.durationValue.toString());

    directionDetails.distanceText =
        response['routes'][0]['legs'][0]['distance']['text'];
    print('directionDetails.distanceText: ' + directionDetails.distanceText);
    directionDetails.distanceValue =
        response['routes'][0]['legs'][0]['distance']['value'];
    print('directionDetails.distanceValue: ' +
        directionDetails.distanceValue.toString());

    directionDetails.encodedPoints =
        response['routes'][0]['overview_polyline']['points'];
    print('directionDetails.encodedPoints: ' +
        directionDetails.encodedPoints.toString());

    return directionDetails;
  }

  // static int estimateFares(DirectionDetails details, int durationValue){
  //     /*
  //     * Fire Calculation
  //     * ----------------
  //     * Base Fares: This is the base or the fla amount of money witch will charged for a trip
  //     *
  //     * Distance Fares: This is the amount charge for Kilometer base
  //     *
  //     * Time Fares: this is the amount charged for every minute spend on the trip
  //     *
  //     * Total Fire  = Sum(Base Fares + Distance Fares +Time Fares)
  //     * KM = 0.3
  //     * Per Minute = 0.2
  //     * Base Fire = $3
  //     *
  //     * Side NoteL: the reason we pass durationValue is that the time google api  provide may be not accurate in some cases
  //     * becouse the rider may stop for trafic or some other reasons. so we calculate our own time
  //     * */
  //   if(details != null) {
  //     double baseFire = 50;
  //     double distanceFire = (details.distanceValue / 1000) * 43;
  //     double timeFire = (durationValue / 50) * 5;

  //     double totalFire = baseFire + distanceFire + timeFire;

  //     return totalFire.truncate();
  //   }else{
  //     return 0;
  //   }
  // }

  static int estimateFares(DirectionDetails details, String vehicleType,TripDetails tripDetails) {
    var PerMinute = 2;

    /*
      Bikes-25
      Tuk-Tuk -36
      Flex-Nano -45
      Flex-Alto -48
      Mini -50
      Car -68
      Minivan -55
      Van-58
      Minilorry
      Lorry
    * */
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
      * Per Minute = 2
      * Base Fire = $3
      * */
    if (details != null) {
      double baseFire = 40;
      double distanceFire = (details.distanceValue / 1000) * 40;
      double timeFire = (details.durationValue / 60) * PerMinute;
      VType tukObject = VType(
          "", double.minPositive, double.minPositive, double.minPositive, "");

      if (vehicleType == "Type1") {
        // Tuk-Tuk
        tukObject = globalVTypes
            .singleWhere((element) => element.name.trim() == "Type1");
        baseFire = tukObject.baseFare;
        distanceFire = (details.distanceValue / 1000) * tukObject.perKM;
        timeFire = (details.durationValue / 60) * tukObject.minutePrice;
      } else if (vehicleType == "Type2") {
        // Flex-Nano
        tukObject = globalVTypes
            .singleWhere((element) => element.name.trim() == "Type2");
        baseFire = tukObject.baseFare;
        distanceFire = (details.distanceValue / 1000) * tukObject.perKM;
        timeFire = (details.durationValue / 60) * tukObject.minutePrice;
      } else if (vehicleType == "Type3") {
        // Flex-Alto
        tukObject = globalVTypes
            .singleWhere((element) => element.name.trim() == "Type3");
        baseFire = tukObject.baseFare;
        distanceFire = (details.distanceValue / 1000) * tukObject.perKM;
        timeFire = (details.durationValue / 60) * tukObject.minutePrice;
      } else if (vehicleType == "Type4") {
        // Mini
        tukObject = globalVTypes
            .singleWhere((element) => element.name.trim() == "Type4");
        baseFire = tukObject.baseFare;
        distanceFire = (details.distanceValue / 1000) * tukObject.perKM;
        timeFire = (details.durationValue / 60) * tukObject.minutePrice;
      } else if (vehicleType == "Type5") {
        // Car
        tukObject = globalVTypes
            .singleWhere((element) => element.name.trim() == "Type5");
        baseFire = tukObject.baseFare;
        distanceFire = (details.distanceValue / 1000) * tukObject.perKM;
        timeFire = (details.durationValue / 60) * tukObject.minutePrice;
      } else if (vehicleType == "Type6") {
        // Minivan
        tukObject = globalVTypes
            .singleWhere((element) => element.name.trim() == "Type6");
        baseFire = tukObject.baseFare;
        distanceFire = (details.distanceValue / 1000) * tukObject.perKM;
        timeFire = (details.durationValue / 60) * tukObject.minutePrice;
      } else if (vehicleType == "Type7") {
        // Van
        tukObject = globalVTypes
            .singleWhere((element) => element.name.trim() == "Type7");
        baseFire = tukObject.baseFare;
        distanceFire = (details.distanceValue / 1000) * tukObject.perKM;
        timeFire = (details.durationValue / 60) * tukObject.minutePrice;
      }

      double totalFire = baseFire + distanceFire + timeFire;

      paymentDetails.kmPrice = distanceFire;
      paymentDetails.timePrice = timeFire;
      paymentDetails.appPrice = baseFire;
      paymentDetails.totalFare = totalFire;


      double SCR = double.minPositive;
      double ODR = double.minPositive;

      if(systemSettings == null || systemSettings.SCR == null ){
        SCR = ((distanceFire +timeFire) * 10)/100;
      }else {
        SCR = ((distanceFire + timeFire) * systemSettings.SCR) / 100;
      }

      if(systemSettings == null || systemSettings.ODR == null ){
        ODR = ((distanceFire +timeFire) * 5)/100;
      }else {
        ODR = ((distanceFire + timeFire) * systemSettings.ODR) / 100;
      }

      paymentDetails.companyPayable = SCR;
      paymentDetails.commissionApplicable = tripDetails.commissionApplicable;
      paymentDetails.commission = ODR;


      print(
          "estimateFares baseFire = $baseFire distanceFire= $distanceFire timeFire= $timeFire ");

      print("Full Payment details $paymentDetails");
      return totalFire.truncate();
    } else {
      return 0;
    }
  }

  static void disableHomTabLocationUpdates() {
    homeTabPositionStream.pause();
    Geofire.removeLocation(currentFirebaseUser.uid);
  }

  static void enableHomTabLocationUpdates() {
    homeTabPositionStream.resume();
    Geofire.setLocation(currentFirebaseUser.uid, currentPosition.latitude,
        currentPosition.longitude);
  }

  static void showProgressDialog(context) {
    //show please wait dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Please wait',
      ),
    );
  }
}
