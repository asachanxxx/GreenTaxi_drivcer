
import 'package:firebase_database/firebase_database.dart';

class Driver{
  String fullName;
  String email;
  String phone;
  String id;
  String carMake;
  String carModel;
  String carColor;
  String vehicleNumber;

  Driver({
    this.fullName,
    this.email,
    this.phone,
    this.id,
    this.carModel,
    this.carColor,
    this.vehicleNumber,
  });

  Driver.fromSnapshot(DataSnapshot snapshot){
    id = snapshot.key;
    phone = snapshot.value['phone'];
    email = snapshot.value['email'];
    fullName = snapshot.value['fullname'];
    carMake = snapshot.value['vehicle_details']['make'];
    carModel = snapshot.value['vehicle_details']['model'];
    carColor = snapshot.value['vehicle_details']['color'];
    vehicleNumber = snapshot.value['vehicle_details']['fleetNo'];
  }

}