import 'package:firebase_database/firebase_database.dart';

class VType {
  String name;
  String displayName;
  double baseFare;
  double minutePrice;
  double perKM;

  VType(
      this.name, this.baseFare, this.minutePrice, this.perKM, this.displayName);

  VType.fromShapShot(DataSnapshot snapshot) {
    this.name = snapshot.value['name'];
    this.baseFare = snapshot.value['baseFire'];
    this.minutePrice = snapshot.value['minutePrice'];
    this.perKM = snapshot.value['perKm'];
  }
}
