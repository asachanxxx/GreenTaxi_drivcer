import 'package:firebase_database/firebase_database.dart';

class Customer {
  String key;
  final String fullName;
  final String phoneNumber;
  final String driverID;
  final String CustomerID;

  Customer({this.fullName, this.phoneNumber,this.driverID,this.CustomerID});

  Customer.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        fullName = snapshot.value["fullName"],
        phoneNumber= snapshot.value["phoneNumber"],
        driverID= snapshot.value["driverID"],
        CustomerID= snapshot.key;

  toJson() {
    return {
      "fullName": fullName,
      "phoneNumber": phoneNumber,
      "driverID": driverID,
      "CustomerID": CustomerID,
    };
  }

  factory Customer.fromJson(Map<dynamic,dynamic> parsedJson) {
    print ("Awa 7 $parsedJson");
    return Customer(fullName:parsedJson['fullName'],phoneNumber:parsedJson['phoneNumber'],driverID:parsedJson['driverID'],CustomerID: parsedJson['CustomerID']);
  }

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


class CustomerList{
  List<Customer> customerList;

  CustomerList({this.customerList});

  factory CustomerList.fromJSON(Map<dynamic,dynamic> json){
    return CustomerList(
        customerList: parseCustomer(json)
    );
  }
  static List<Customer> parseCustomer(recipeJSON){
    //var rList=recipeJSON['browseRecipes'] as List;
    print ("Awa 7 $recipeJSON");
    var rList=recipeJSON as List;
    print ("Awa 8 $rList");
  }
  static List<Customer> parserecipes(recipeJSON){
    var rList=recipeJSON as List;
    List<Customer> recipeList=rList.map((data) => Customer.fromJson(data)).toList();  //Add this
    return recipeList;                           //And this
  }

}


class MakeCall{
  List<Customer> listItems=[];

  Future<List<Customer>> firebaseCalls (DatabaseReference databaseReference) async{
    //print ("Awa 1");
    CustomerList customerList;
    DataSnapshot dataSnapshot = await databaseReference.once();
    //print ("Awa 2 ${dataSnapshot.value}");
    Map<dynamic,dynamic> jsonResponse=dataSnapshot.value;
    print ("Awa 3 ${jsonResponse}");
    customerList = new CustomerList.fromJSON(jsonResponse);
    print ("Awa 4 ${customerList.customerList}");
    listItems.addAll(customerList.customerList);
    print ("Awa 5 ${listItems}");
    return listItems;
  }
}

