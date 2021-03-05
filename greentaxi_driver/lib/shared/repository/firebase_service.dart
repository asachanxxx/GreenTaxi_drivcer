
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:greentaxi_driver/models/address.dart';
import 'package:greentaxi_driver/models/searchmodels.dart';
import 'package:greentaxi_driver/shared/repository/serial_service.dart';

enum taskTypes {
  RideRequest,
  RideRequestVoice,
}

enum notificationTypes {
  Task,
  Info,
  Error,
  Warning
}

enum notificationApplyTo {
  Singleton,
  Multiple
}

enum notificationMedia {
  Sms,
  InApp,
  Both
}



class FirebaseService {

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<List<SearchHistory>> getSearchHistory(String uID) async {
    var checkRef = await FirebaseDatabase.instance
        .reference()
        .child("customers/$uID/searchhistory")
        .limitToLast(5)
        .once();
    if (checkRef != null) {
      List<SearchHistory> theList = [];
      checkRef.value.entries.forEach((snapshot) {
        theList.add(SearchHistory(
            snapshot.value["placeId"],
            snapshot.value["name"],
            snapshot.value["displayName"],
            double.parse(snapshot.value["lat"].toString()),
            double.parse(snapshot.value["lng"].toString()),
            ));
      });
      return theList;
    }
    return null;
  }


  Future<bool> addSearchHistory(SearchHistory obj,String uID) async {
    var ref = _database.reference()
        .child("customers/$uID/searchhistory")
        .push();
    Map searchHistory = {
      "placeId": obj.placeId,
      "name": obj.name,
      "displayName": obj.displayName,
      "lat": obj.lat,
      "lng": obj.lng
    };
    ref.set(searchHistory).catchError((err) {
      return Future.value(false);
    });
    ref = null;
    return Future.value(true);
  }


  static Future<bool> addRideRequestList(String customerId,Address pickup, Address destin) async {
    FirebaseDatabase _database = FirebaseDatabase.instance;
    var serial = await SerialService.getSerial(SetialTypes.rideRequest);
    Map pickupMap = {
      'placeName': pickup.placeName,
      'placeFormatAddress': pickup.placeFormatAddress,
      'placeId': pickup.placeId,
      'latitude': pickup.latitude,
      'logitude': pickup.logitude,
      'datetime': DateTime.now().toString(),
    };

    Map destinMap = {
      'placeName': destin.placeName,
      'placeFormatAddress': destin.placeFormatAddress,
      'placeId': destin.placeId,
      'latitude': destin.latitude,
      'logitude': destin.logitude,
      'datetime': DateTime.now().toString(),
    };

    var ref = _database.reference()
        .child("listTaskTree/RideRequestLists")
        .push();

    Map fullMap = {
      'key': ref.key,
      'token':serial,
      'customerID': customerId,
      'pickupDetails': pickupMap,
      'destinDetails': destinMap,
    };

    print("Point 1");

    await ref.set(fullMap);
    var res = await FirebaseService.addTask(ref.key, serial, "A ride request has been created.", taskTypes.RideRequest,DateTime.now());
    return res;
  }

  static Future<bool> addTask(String mainRefId,String refToken, String description,taskTypes type, DateTime taskDueAt) async {
    FirebaseDatabase _database = FirebaseDatabase.instance;
    var values = await SerialService.getSerial(SetialTypes.task);
    var ref = _database.reference()
        .child("listTaskTree/taskList")
        .push();

    Map fullMap = {
      'key': ref.key,
      'token': values,
      'referenceId':mainRefId,
      'referenceToken':refToken,
      'description': description,
      'Type': type.toString().substring(type.toString().indexOf('.') + 1),
      'taskDueAt': taskDueAt.toString(),
      'attended': "false",
      'timeStamp':DateTime.now().millisecondsSinceEpoch
    };

    print("addTask values = $values  ref.key = ${ref.key}");
    await ref.set(fullMap);
    return Future.value(true);
  }


  static Future<bool> addNotification(String referenceId, notificationTypes notificationType , notificationApplyTo notificationApply , notificationMedia notificationMedias ,String description) async {
    FirebaseDatabase _database = FirebaseDatabase.instance;
    var ref = _database.reference()
        .child("listTaskTree/notifications")
        .push();

    Map fullMap = {
      'key': ref.key,
      'referenceId':referenceId,
      'referenceToken':referenceId,
      'description': description,
      'notificationTypes': notificationType.toString().substring(notificationType.toString().indexOf('.') + 1),
      'notificationApplyTo': notificationApply.toString().substring(notificationApply.toString().indexOf('.') + 1),
      'notificationMedia': notificationMedias.toString().substring(notificationMedias.toString().indexOf('.') + 1),
      'timeStamp':DateTime.now().millisecondsSinceEpoch
    };

    print("addTask values = $referenceId  ref.key = ${ref.key}");
    await ref.set(fullMap);
    return Future.value(true);
  }


}