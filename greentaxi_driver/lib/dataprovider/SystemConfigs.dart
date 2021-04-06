import 'package:flutter/material.dart';

class SystemSettings extends ChangeNotifier {

  String address;
  String appName;
  String city;
  String commissionCutMode;
  String companyName;
  String country;
  int currency;
  String imagePath;
  int ODR;
  int SCR;

  SystemSettings.fromDb( Map<dynamic, dynamic> map) {
    var data = map.values.toList().last;
    address = data['address'];
    appName =data['appName'];
    city =data['city'];
    commissionCutMode =data['commissionCutMode'];
    companyName =data['companyName'];
    country =data['country'];
    currency =data['currency'];
    imagePath =data['imagePath'];
    ODR =data['ODR'];
    SCR =data['SCR'];
  }
}

