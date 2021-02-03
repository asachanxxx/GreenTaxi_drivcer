import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripDetails {
  String destinationAddress;
  String pickupAddress;
  LatLng pickup;
  LatLng destination;
  LatLng driverLocation;
  String rideID;
  String paymentMethod;
  String riderName;
  String riderPhone;
  bool commissionApplicable;
  String commissionedDriverId;
  String status;

  TripDetails({
    this.pickupAddress,
    this.rideID,
    this.destinationAddress,
    this.destination,
    this.pickup,
    this.paymentMethod,
    this.riderName,
    this.riderPhone,
    this.status
  });

}