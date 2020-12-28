import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greentaxi_driver/dataprovider/SystemConfigs.dart';
import 'package:greentaxi_driver/models/company.dart';
import 'package:greentaxi_driver/models/tripdetails.dart';

class CompanyRepository {

  // ignore: missing_return
  Future<SystemSettings> fetchSystemConfigurations() async {
    var checkRef = await FirebaseDatabase.instance.reference().child("companies").once();
    if(checkRef != null){
      Map<dynamic, dynamic> map = checkRef.value;
      //var firstElement = map.values.toList()[0]['SCR'];
      SystemSettings entity =  SystemSettings.fromDb(map);
      return entity;
    }
    return null;
  }

  Future<List<SystemSettings>> filterData() async {
    var checkRef = await FirebaseDatabase.instance.reference().child("rideRequest").orderByChild("status").equalTo("ended") .once();
    if(checkRef != null){
      List<SystemSettings> theList = new List<SystemSettings>();
      //print ("Type of the checkRef  : $checkRef" );

      checkRef.value.entries.forEach((snapshot) {
        print("car_details ---  ${snapshot.value["car_details"]}");
        print("latitude --- ${snapshot.value["driver_location"]["latitude"]}");

      });

      //print ("Type of the checkRef END  : $checkRef" );
      //Map<dynamic, dynamic> map = checkRef.value;
      //var firstElement = map.values.toList()[0]['SCR'];

      //return entity;
    }
    return null;
  }


  void Create(Company object) {
    DatabaseReference companyRef = FirebaseDatabase.instance.reference();
    var id = companyRef.child('companies/').push();
    Map companyMap = {
      'address': object.address,
      'appName': object.appName,
      'city': object.city,
      'commissionCutMode': object.commissionCutMode,
      'companyName': object.companyName,
      'country': object.country,
      'Currency': object.country,
      'imagePath': object.imagePath,
      'ODR': object.ODR,
      'SCR': object.SCR,
    };
    id.set(companyMap);
    print('CompanyRepository: Id: ' + id.key.toString());
  }


  Future<String> getNewTripStatus(String uid) async {
    var checkRef = await FirebaseDatabase.instance.reference().child('drivers/$uid/newtrip').once();
    if(checkRef != null){
      // Map<dynamic, dynamic> map = checkRef.value;
      // var firstElement = map.values.toList()[0];

      print('xxxxxxx ${checkRef.value}');
      return checkRef.value;
    }
    return null;
  }


  Future<TripDetails> getTripDetails(String dRoute) async {

    TripDetails tripDetails = TripDetails();
    var rideRef = await FirebaseDatabase.instance.reference().child(
        'rideRequest/$dRoute').once();
    var snapshot = rideRef;

    // rideRef.((DataSnapshot snapshot) {
      if (snapshot.value != null) {

        double pickupLat = double.parse(
            snapshot.value['location']['latitude'].toString());
        double pickupLng = double.parse(
            snapshot.value['location']['longitude'].toString());
        String pickupAddress = snapshot.value['pickup_address'].toString();

        double destinationLat = double.parse(
            snapshot.value['destination']['latitude'].toString());
        double destinationLng = double.parse(
            snapshot.value['destination']['longitude'].toString());

        double driverLat = double.parse(snapshot.value['driver_location']['latitude'].toString());
        double driverLng = double.parse(snapshot.value['driver_location']['longitude'].toString());


        String destinationAddress = snapshot.value['destination_address'];
        String paymentMethod = snapshot.value['payment_method'];
        String riderName = snapshot.value['rider_name'];
        String riderPhone = snapshot.value['rider_phone'];



        tripDetails.rideID = dRoute;
        tripDetails.pickupAddress = pickupAddress;
        tripDetails.destinationAddress = destinationAddress;
        tripDetails.pickup = LatLng(pickupLat, pickupLng);
        tripDetails.destination = LatLng(destinationLat, destinationLng);
        tripDetails.driverLocation = LatLng(driverLat, driverLng);
        tripDetails.paymentMethod = paymentMethod;
        tripDetails.riderName = riderName;
        tripDetails.riderPhone = riderPhone;

        print("inside getTripDetails $pickupAddress");
        return tripDetails;
      }
    // });
    return null;
  }


}
