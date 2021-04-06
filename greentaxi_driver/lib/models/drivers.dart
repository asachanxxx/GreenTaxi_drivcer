import 'package:firebase_database/firebase_database.dart';
import 'package:greentaxi_driver/globalvariables.dart';

class Driver {
  String fullName;
  String email;
  String phone;
  String id;
  String carMake;
  String carModel;
  String carColor;
  String vehicleNumber;
  double SCR;
  double ODR;

  Driver(
      {this.fullName,
      this.email,
      this.phone,
      this.id,
      this.carModel,
      this.carColor,
      this.vehicleNumber,
      this.SCR,
      this.ODR});

  Driver.fromSnapshot(DataSnapshot snapshot) {
    id = snapshot.value['key'];
    phone = snapshot.value['phone'];
    email = snapshot.value['email'];
    fullName = snapshot.value['fullName'];
    SCR = roundUp(double.parse(snapshot.value['SCR'].toString()));
    ODR = roundUp(double.parse(snapshot.value['ODR'].toString()));
    // carMake = snapshot.value['vehicle_details']['make'];
    // carModel = snapshot.value['vehicle_details']['model'];
    // carColor = snapshot.value['vehicle_details']['color'];
    // vehicleNumber = snapshot.value['vehicle_details']['fleetNo'];
  }
}
