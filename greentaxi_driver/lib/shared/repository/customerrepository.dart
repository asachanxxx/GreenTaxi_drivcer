import 'package:firebase_database/firebase_database.dart';
import 'package:greentaxi_driver/dataprovider/SystemConfigs.dart';
import 'package:greentaxi_driver/models/customer.dart';

class CustomerRepository {

  Future<List<Customer>> filterData(String driverID) async {
    var checkRef = await FirebaseDatabase.instance.reference().child(
        "customers").orderByChild("driverID").equalTo(driverID).once();
    if (checkRef != null || checkRef.value != null) {
      List<Customer> theList = new List<Customer>();
      //print ("Type of the checkRef  : $checkRef" );

      checkRef.value.entries.forEach((snapshot) {
        print("fullName of customer ---  ${snapshot.value["fullName"]}");
        theList.add(Customer(snapshot.value["fullName"],snapshot.value["phoneNumber"] ,snapshot.value["driverID"],checkRef.key ));
      });
      return theList;
    }
    return null;
  }




}