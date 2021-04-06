
import 'package:firebase_database/firebase_database.dart';

class Messaging {
  String uId;
  String message;
  String type; //Message/RideRequest
  String customerId;
  String tripId;
  String requestTime;
  String timeStamp;


  Messaging(this.uId, this.message,this.type,
      this.customerId,this.tripId,this.requestTime,this.timeStamp );

  Messaging.fromShapShot(DataSnapshot snapshot) {
    this.uId = snapshot.value['uId'].toString();
    this.message = snapshot.value['message'].toString();
    this.type = snapshot.value['type'].toString();
    this.customerId = snapshot.value['customerId'].toString();
    this.tripId = snapshot.value['tripId'].toString();
    this.requestTime = snapshot.value['requestTime'].toString();
    this.timeStamp = snapshot.value['timeStamp'].toString();
  }



}
