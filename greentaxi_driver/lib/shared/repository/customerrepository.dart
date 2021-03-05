import 'package:firebase_database/firebase_database.dart';
import 'package:greentaxi_driver/dataprovider/SystemConfigs.dart';
import 'package:greentaxi_driver/models/customer.dart';

class CustomerRepository {
  // Future<List<Customer>> filterData(String driverID) async {
  Future<List<Customer>> filterData(String driverID) async {
    // var checkRef = await FirebaseDatabase.instance.reference().child(
    //     "customers").orderByChild("driverID").equalTo(driverID).once();
    // if (checkRef != null || checkRef.value != null) {
    //   List<Customer> theList = [];
    //   //print ("Type of the checkRef  : $checkRef" );
    //
    //   if(checkRef.value != null) {
    //
    //     checkRef.value.entries.forEach((snapshot) {
    //       print("filterData checkRef.value ---  ${ snapshot.value}");
    //       print("filterData fullName of fullName ---  ${snapshot.value["fullName"]}");
    //       print("filterData  fullName of driverID ---  ${snapshot.value["driverID"]}");
    //       print("filterData  fullName of phoneNumber ---  ${snapshot.value["phoneNumber"]}");
    //       print("filterData  fullName of checkRef.key ---  ${checkRef.key}");
    //       theList.add(Customer(
    //           snapshot.value["fullName"], snapshot.value["phoneNumber"],
    //           snapshot.value["driverID"], checkRef.key));
    //     });
    //   }
    //   return theList;
    // }
    List<Customer> theList = [];

    DatabaseReference keyRef = FirebaseDatabase.instance.reference();
    keyRef.child('customers')
        .orderByChild('driverID')
        .equalTo(driverID)
        .once()
        .then((DataSnapshot snapshot) {
      print("filterData checkRef.value ---  ${ snapshot.value}");

      snapshot.value.entries.forEach((snapshot) {
        //String newKey = snapshot.value.key;
        print("filterData checkRef.value ---  ${ snapshot.value}");
        print("filterData fullName of fullName ---  ${snapshot
            .value["fullName"]}");
        print("filterData  fullName of driverID ---  ${snapshot
            .value["driverID"]}");
        print("filterData  fullName of phoneNumber ---  ${snapshot
            .value["phoneNumber"]}");
        //print("filterData  fullName of checkRef.key ---  ${newKey}");
        theList.add(Customer(fullName:snapshot.value["fullName"], phoneNumber:snapshot.value["phoneNumber"],driverID:snapshot.value["driverID"],CustomerID:""));
      });
      return theList;
    });

    //String newKey = snapshot.value.keys[0];
    //print(newKey);
    // });

    return null;
  }

  Future filterCustomers(String driverID) async {
    DatabaseReference keyRef = FirebaseDatabase.instance.reference();
    return keyRef.child('customers')
        .orderByChild('driverID')
        .equalTo(driverID).once();
  }

}


