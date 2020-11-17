import 'package:flutter/cupertino.dart';
import 'package:greentaxi_driver/models/address.dart';
import 'package:greentaxi_driver/models/history.dart';

class AppData extends ChangeNotifier {
  Address pickupAdrress;
  Address destinationAdrress;

  void updatePickupAddress(Address picup) {
    pickupAdrress = picup;
    notifyListeners();
  }

  void updateDestinationAdrress(Address destin) {
    print('updateDestinationAdrress placeFormatAddress :- ' + destin.placeFormatAddress + " latitude " + destin.latitude.toString() + "  logitude  " + destin.logitude.toString() );

    destinationAdrress = destin;
    notifyListeners();
  }

  String earnings = '0';
  int tripCount = 0;
  List<String> tripHistoryKeys = [];
  List<History> tripHistory = [];

  void updateEarnings(String newEarnings){
    earnings = newEarnings;
    notifyListeners();
  }

  void updateTripCount(int newTripCount){
    tripCount = newTripCount;
    notifyListeners();
  }

  void updateTripKeys(List<String> newKeys){
    tripHistoryKeys = newKeys;
    notifyListeners();
  }

  void updateTripHistory(History historyItem){
    tripHistory.add(historyItem);
    notifyListeners();
  }
}
