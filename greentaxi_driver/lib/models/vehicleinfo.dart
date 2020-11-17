
import 'package:firebase_database/firebase_database.dart';

class VehicleInfomation{
  String id;
  String fleetNo;
  String make;
  String model;
  String color;
  String insuranceNo;
  DateTime insuranceExpire;

  VehicleInfomation(
    this.fleetNo,
    this.make,
    this.model,
    this.color,
    this.insuranceNo,
    this.insuranceExpire,
    this.id
  );

  VehicleInfomation.consturct(
      this.fleetNo,
      this.make,
      this.model,
      this.color,
      this.insuranceNo,
      );

  VehicleInfomation.fromShapShot(DataSnapshot snapshot){
    this.fleetNo = snapshot.value['fleetNo'];
    this.make = snapshot.value['make'];
    this.model =snapshot.value['model'];
    this.color =snapshot.value['color'];
    this.insuranceNo =snapshot.value['insuranceNo'];
    this.insuranceExpire =snapshot.value['insuranceExpire'];
    this.id = snapshot.key;
  }
}



