import 'package:google_maps_flutter/google_maps_flutter.dart';

class PaymentDetails {
  String destinationAddress;
  String pickupAddress;
  String rideID;
  double kmPrice;
  double appPrice;
  double timePrice;
  double totalFare;
  double companyPayable;
  bool commissionApplicable;
  double commission;


  PaymentDetails({
    this.pickupAddress,
    this.destinationAddress,
    this.rideID,
    this.kmPrice,
    this.appPrice,
    this.timePrice,
    this.totalFare,
    this.companyPayable,
    this.commissionApplicable,
    this.commission
  });

}