import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:greentaxi_driver/dataprovider/SystemConfigs.dart';
import 'package:greentaxi_driver/models/company.dart';

class CompanyRepository {

  // ignore: missing_return
  Future<SystemSettings> fetchSystemConfigurations() async {
    var checkRef = await FirebaseDatabase.instance.reference().child("companies").once();
    if(checkRef != null){
      Map<dynamic, dynamic> map = checkRef.value;
      //var firstElement = map.values.toList()[0]['SCR'];
      SystemSettings entity =  SystemSettings.fromDb(map);
      return entity;
    }
    return null;
  }

  Future<List<SystemSettings>> filterData() async {
    var checkRef = await FirebaseDatabase.instance.reference().child("rideRequest").orderByChild("status").equalTo("ended") .once();
    if(checkRef != null){
      List<SystemSettings> theList = new List<SystemSettings>();
      //print ("Type of the checkRef  : $checkRef" );

      checkRef.value.entries.forEach((snapshot) {
        print("car_details ---  ${snapshot.value["car_details"]}");
        print("latitude --- ${snapshot.value["driver_location"]["latitude"]}");

      });

      //print ("Type of the checkRef END  : $checkRef" );
      //Map<dynamic, dynamic> map = checkRef.value;
      //var firstElement = map.values.toList()[0]['SCR'];

      //return entity;
    }
    return null;
  }


  void Create(Company object) {
    DatabaseReference companyRef = FirebaseDatabase.instance.reference();
    var id = companyRef.child('companies/').push();
    Map companyMap = {
      'address': object.address,
      'appName': object.appName,
      'city': object.city,
      'commissionCutMode': object.commissionCutMode,
      'companyName': object.companyName,
      'country': object.country,
      'Currency': object.country,
      'imagePath': object.imagePath,
      'ODR': object.ODR,
      'SCR': object.SCR,
    };
    id.set(companyMap);
    print('CompanyRepository: Id: ' + id.key.toString());
  }

  // static void Find() {
  //   DatabaseReference companyRef = FirebaseDatabase.instance.reference().child('companies');
  //   companyRef.once().then((DataSnapshot snapshot) {
  //     Map<dynamic, dynamic> map = snapshot.value;
  //     var firstElement = map.values.toList()[0]['SCR'];
  //     print('Connected to second database and read ${firstElement}');
  //   });
  // }


}
