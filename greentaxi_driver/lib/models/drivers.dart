
import 'package:firebase_database/firebase_database.dart';

class Driver{

  String fullName;
  String email;
  String phone;
  String pass;
  String id;


  Driver({
    this.fullName,
    this.email,
    this.phone,
    this.pass,
    this.id,
  });

  Driver.fromShapShot(DataSnapshot snapshot){
    print('snapshot is calling ********************');
    this.fullName = snapshot.value['fullName'];
    this.email = snapshot.value['email'];
    this.phone =snapshot.value['phone'];
    this.id = snapshot.key;

  }
}