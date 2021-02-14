class Customer {
  final String fullName;
  final String phoneNumber;
  final String driverID;
  final String CustomerID;

  Customer(this.fullName, this.phoneNumber,this.driverID,this.CustomerID);

}

class CustomerTrip {
  final String tripName;
  final double pickupLat;
  final double pickupLan;
  final double dropLat;
  final double dropLan;
  final String customerID;

  CustomerTrip(this.customerID, this.tripName,this.pickupLat,this.pickupLan,this.dropLat,this.dropLan);

}