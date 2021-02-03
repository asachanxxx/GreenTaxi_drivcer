
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greentaxi_driver/dataprovider/appdata.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/models/tripdetails.dart';
import 'package:greentaxi_driver/widgets/NotificationDialog.dart';
import 'package:greentaxi_driver/widgets/ProgressDialog.dart';
import 'package:provider/provider.dart';

class PushNotificationService {

  final FirebaseMessaging fcm = FirebaseMessaging();



  Future<String> getToken() async{

    String token = await fcm.getToken();
    print('token: $token');

    DatabaseReference tokenRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/token');
    tokenRef.set(token);

    fcm.subscribeToTopic('alldrivers');
    fcm.subscribeToTopic('allusers');

  }

  Future initialize(context,LatLng pos) async {


    if (Platform.isIOS) {
      fcm.requestNotificationPermissions(IosNotificationSettings());
    }
    print("Inside FCM");


    fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage : $message');
        if(Platform.isAndroid){
          print('onMessage : ${message['data']['ride_id']}');
        }
        getRideID(message);
        fetchRideInfo(getRideID(message), context,pos);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch : $message');
        if(Platform.isAndroid){
          print('onLaunch : ${message['data']['ride_id']}');
        }

        fetchRideInfo(getRideID(message), context,pos);
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume : $message');
        if(Platform.isAndroid){
          print('onLaunch : ${message['data']['ride_id']}');
        }
        getRideID(message);
        fetchRideInfo(getRideID(message), context,pos);
      },

    );
  }

  void fetchRideInfo(String rideID, context,LatLng pos){
    if(!isOnline){

      return;
    }
    //show please wait dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: 'Fetching details',),
    );

    DatabaseReference rideRef = FirebaseDatabase.instance.reference().child('rideRequest/$rideID');
    rideRef.once().then((DataSnapshot snapshot){

      Navigator.pop(context);

      if(snapshot.value != null){

        assetsAudioPlayer.open(
          Audio('sounds/alert.mp3'),
        );
        assetsAudioPlayer.play();

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


        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => NotificationDialog(tripDetails: tripDetails,),
        );

      }

    });



  }



  String getRideID(Map<String, dynamic> message){

    String rideID = '';

    if(Platform.isAndroid){
      rideID = message['data']['ride_id'];
    }
    else{
      rideID = message['ride_id'];
      print('ride_id: $rideID');
    }
    print('getRideID ride_id : $rideID');
    return rideID;
  }

}