import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/models/vehicleinfo.dart';


class VehicleRepository {
  static String collectiNName = 'vehicles';
  static void registerVehicle(VehicleInfomation newDriver) async {
    try {
     if (currentDriverInfo != null) {
        DatabaseReference dbRef = FirebaseDatabase.instance.reference().child('drivers/${currentDriverInfo.id}/vehicle_details');

        /*
        * String id;
          String fleetNo;
          String make;
          String model;
          String color;
          String insuranceNo;
          DateTime insuranceExpire;
          * */
        Map vehicleMap = {
          'fleetNo': newDriver.fleetNo,
          'make': newDriver.make,
          'model': newDriver.model,
          'color': newDriver.color,
          'insuranceNo': newDriver.insuranceNo,
          'insuranceExpire': DateTime.now().toString()
        };
        dbRef.set(vehicleMap);
        print('Save Done');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

}