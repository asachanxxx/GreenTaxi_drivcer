import 'package:flutter/cupertino.dart';
import 'package:greentaxi_driver/models/address.dart';
import 'package:greentaxi_driver/models/dateWiseSummary.dart';

class AppData extends ChangeNotifier {
  Address pickupAdrress;
  Address destinationAdrress;
  DateWiseSummary dateWiseSummary;

  void updatePickupAddress(Address picup) {
    pickupAdrress = picup;
    notifyListeners();
  }

  void updateDestinationAdrress(Address destin) {
    print('updateDestinationAdrress placeFormatAddress :- ' + destin.placeFormatAddress + " latitude " + destin.latitude.toString() + "  logitude  " + destin.logitude.toString() );

    destinationAdrress = destin;
    notifyListeners();
  }

  void updatedateWiseSummary(DateWiseSummary dws) {
    dateWiseSummary = dws;
    notifyListeners();
  }

  void updatedateWiseSummaryEarning(double newValue) {
    if(dateWiseSummary == null){
      dateWiseSummary = new DateWiseSummary(0,0,0,0,0,0,0);
    }
    dateWiseSummary.totalEarning += newValue;
    notifyListeners();
  }

}
