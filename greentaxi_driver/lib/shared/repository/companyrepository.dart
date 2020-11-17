import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:greentaxi_driver/models/company.dart';

class CompanyRepository {

  static void Create(Company object) {
    DatabaseReference companyRef = FirebaseDatabase.instance.reference();
    var id = companyRef.child('companies/').push();
    Map companyMap = {
      'address': object.address,
      'appName': object.appName,
      'city': object.city,
      'commissionCutMode': object.commissionCutMode,
      'companyName': object.companyName,
      'country': object.country,
      'imagePath': object.imagePath,
      'ODR': object.ODR,
      'SCR': object.SCR,
    };
    id.set(companyMap);
    print('CompanyRepository: Id: ' + id.key.toString());
  }

  static void Find() {
    DatabaseReference companyRef = FirebaseDatabase.instance.reference().child('companies');
    companyRef.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> map = snapshot.value;
      var firstElement = map.values.toList()[0]['SCR'];
      print('Connected to second database and read ${firstElement}');
    });
  }


}
