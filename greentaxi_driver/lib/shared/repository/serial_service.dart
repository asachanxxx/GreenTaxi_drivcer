import 'package:firebase_database/firebase_database.dart';

enum SetialTypes {
    customer,
    driver,
    task,
    notifications,
    rideRequest,
}

class SerialService {

  static FirebaseDatabase _database = FirebaseDatabase.instance;


  static Future<bool> initSerials() async {
    var ref = _database.reference()
        .child("serials");

    ref.once().then((value) {
      print("inside initSerials value = ${value.value}");
      if (value.value == null) {
        Map searchHistory = {
          "customer": 0,
          "driver": 0,
          "task": 0,
          "notifications": 0,
          "rideRequest": 0,
        };
        _database.reference()
            .child("serials").set(searchHistory).catchError((err) {
          return Future.value(false);
        });
      } else {
        return Future.value(true);
      }
    });

    ref = null;
    return Future.value(true);
  }


  static Future<String> getSerial(SetialTypes sType) async {
    String firebasePath = "serials/task";
    switch (sType) {
      case SetialTypes.task:
        firebasePath = "serials/task";
        break;
      case SetialTypes.customer:
        firebasePath = "serials/customer";
        break;
      case SetialTypes.driver:
        firebasePath = "serials/driver";
        break;
      case SetialTypes.notifications:
        firebasePath = "serials/notifications";
        break;
      case SetialTypes.rideRequest:
        firebasePath = "serials/rideRequest";
        break;
    }

    var ref = await _database.reference().child(firebasePath).once();
    if (ref.value != null) {
      int cSerial = ref.value;
      var ref2 = await _database.reference().child("serials/task").set(
          cSerial + 1);
      var finalSerial = "";
      
      switch (sType) {
        case SetialTypes.task:
          finalSerial = "TSK${cSerial.toString().padLeft(6,'0')}";
          break;
        case SetialTypes.customer:
          firebasePath = "serials/customer";
          break;
        case SetialTypes.driver:
          firebasePath = "serials/driver";
          break;
        case SetialTypes.notifications:
          firebasePath = "serials/notifications";
          break;
        case SetialTypes.rideRequest:
          finalSerial = "RRQ${cSerial.toString().padLeft(6,'0')}";
          break;
      }
      return finalSerial;
    }
    return "no Value";
  }


}