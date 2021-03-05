import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/dataprovider/appdata.dart';
import 'package:greentaxi_driver/models/address.dart';
import 'package:greentaxi_driver/models/customer.dart';
import 'package:greentaxi_driver/models/predictions.dart';
import 'package:greentaxi_driver/screens/misc/searchpage.dart';
import 'package:greentaxi_driver/styles/styles.dart';
import 'package:greentaxi_driver/widgets/BrandDivider.dart';
import 'package:greentaxi_driver/widgets/predictiontile.dart';
import 'package:provider/provider.dart';


class CustomerTrips extends StatefulWidget {
  static const String Id = 'custrips';

  final String  customerId;
  CustomerTrips({this.customerId});

  @override
  _CustomerTripsState createState() => _CustomerTripsState();
}

class _CustomerTripsState extends State<CustomerTrips> {
  var fireDb = FirebaseDatabase.instance.reference().child('customers');
  List<Customer> customerList = new List<Customer>();
  UserCredential userCredentialx;

  final fullnamecontoller = TextEditingController();
  final phonecontoller = TextEditingController();
  final emailcontoller = TextEditingController();
  final passwordcontoller = TextEditingController();


  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  var pickupCOntroller = TextEditingController();
  var destinationCOntroller = TextEditingController();
  List<Prediction> destinationPredictionList = [];
  FocusNode myFocusNode;

  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    myFocusNode.dispose();
    customerList = null;
  }


  @override
  void initState() {
    // TODO: implement initState
    print("widget.customerId  ${widget.customerId }");
    myFocusNode = new FocusNode();
    myFocusNode.requestFocus();
    super.initState();
  }

  String emailGenarator() {
    String email = "";
    Random rand = Random();
    return "User${rand.nextInt(1000000)}@gmail.com";
  }

  @override
  Widget build(BuildContext context) {

    Widget returnControlMessage(String message1 , String message2 , bool isError){
      return Container(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                new Text(message1 , style: GoogleFonts.roboto(fontSize: 15,color: isError ? Color(0xFFd32f2f) :Color(0xFFff6f00) , fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                BrandDivider(),
                SizedBox(height: 10,),
                new Text(message2 , style: GoogleFonts.roboto(fontSize: 15),),
              ],
            ),
          )
      );
    }


    var futureBuilder = new StreamBuilder(
      stream: FirebaseDatabase.instance
          .reference()
          .child('listTree/tripList/${widget.customerId}')
          .onValue, // async work
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        Widget newwidget;

        if(widget.customerId == null)
        {
              newwidget = returnControlMessage(
                  "Problem with customer List (පාරිභෝගික ලැයිස්තුව)",
                  "The customer list cannot be shown at the moment. please try later(පාරිභෝගික ලැයිස්තුව මේ මොහොතේ පෙන්විය නොහැක. කරුණාකර පසුව උත්සාහ කරන්න)",
                  true);
        }else {
          List<dynamic> list;
          if (snapshot != null) {
            if (snapshot.data != null) {
              if (snapshot.data.snapshot != null) {
                if (snapshot.data.snapshot.value != null) {
                  print("point 1");
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      newwidget = returnControlMessage(
                          "Please wait until loading the data (කරුණාකර දත්ත පූරණය වන තෙක් රැඳී සිටින්න)",
                          "", true);
                      break;
                    case ConnectionState.waiting:
                      print("Waiting .........");
                      newwidget = returnControlMessage(
                          "Please wait until loading the data (කරුණාකර දත්ත පූරණය වන තෙක් රැඳී සිටින්න)",
                          "", true);
                      break;
                    default:
                      if (snapshot.hasError)
                        newwidget = returnControlMessage(
                            "Problem when loading saved trip details(ඇතුලත් කරන ලද  චාරිකා ව්ස්තර ලබාගැනීමේ ගැටළුවක් ඇත )",
                            "The customer list cannot be shown at the moment. please try later( චාරිකා ව්ස්තර මේ මොහොතේ පෙන්විය නොහැක. කරුණාකර පසුව උත්සාහ කරන්න)",
                            true);
                      else
                        print("Point 2 Value ${snapshot.data.snapshot.value}");
                      Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
                      list = map.values.toList();
                      print("Key : ${snapshot.data.snapshot.value}");
                      newwidget = ListView.builder(
                        itemCount: list.length, //snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          Address pickup = Address(placeId: list[index]["destinDetails"]["placeId"],
                                           latitude: list[index]["destinDetails"]["latitude"],
                                           logitude:  list[index]["destinDetails"]["logitude"],
                                           placeName: list[index]["destinDetails"]["placeName"] ,
                                           placeFormatAddress: list[index]["destinDetails"]["placeFormatAddress"]);
                          Address dropadd = Address(placeId: list[index]["pickupDetails"]["placeId"],
                              latitude: list[index]["pickupDetails"]["latitude"],
                              logitude:  list[index]["pickupDetails"]["logitude"],
                              placeName: list[index]["pickupDetails"]["placeName"] ,
                              placeFormatAddress: list[index]["pickupDetails"]["placeFormatAddress"]);

                          print("list[index][phoneNumber]  ${dropadd.placeFormatAddress}");

                          Customer cus = Customer(
                              phoneNumber: "",
                              fullName: "",
                              driverID: "",
                              CustomerID: "");
                          return TripTile2(
                              pickupAdd: pickup,
                              dropAdd:dropadd ,
                          );
                        },
                      );
                  }
                } else {
                  print("No Customers .........");
                  newwidget = returnControlMessage(
                      'No Trips Found(කිසිඳු චාරිකාවක්  හමු නොවීය)',
                      'Please Use plus signed button to add your trip(ඔබේ චාරිකාව ඇතුලත් කිරීමට කරුණාකර පහත බොත්තම භාවිතා කරන්න)',
                      false);
                }
              } else {
                print("No Customers .........");
                newwidget = returnControlMessage(
                    'No Trips Found(කිසිඳු චාරිකාවක් හමු නොවීය)',
                    'Please Use plus signed button to add your trip(ඔබේ චාරිකාව ඇතුලත් කිරීමට කරුණාකර පහත බොත්තම භාවිතා කරන්න)',
                    false);
              }
            } else {
              print("No Customers .........");
              newwidget = returnControlMessage(
                  'No Trips Found(කිසිඳු චාරිකාවක්  හමු නොවීය)',
                  'Please Use plus signed button to add your trip(ඔබේ චාරිකාව ඇතුලත් කිරීමට කරුණාකර පහත බොත්තම භාවිතා කරන්න)',
                  false);

            }
          } else {
            print("No Customers .........");
            newwidget = returnControlMessage(
                'No Trips Found(කිසිඳු චාරිකාවක්  හමු නොවීය)',
                'Please Use plus signed button to add your trip(ඔබේ චාරිකාව ඇතුලත් කිරීමට කරුණාකර පහත බොත්තම භාවිතා කරන්න)',
                false);

          }
        }
        return newwidget;
      },
    );




    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                color: Color(0xFFff6f00),
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      SizedBox(width: 10,),
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Expanded(child: Icon(Icons.arrow_back, color: Color(0xFFffffff)))
                      ),
                      SizedBox(width: 60,),
                      Expanded(
                        child: Text("Customer Trips",
                            style: GoogleFonts.roboto(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFffffff))
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 5,),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          height: 500,
                          decoration: BoxDecoration(
                            color: Color(0xFFeeeeee),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                width: 1.0, color: Color(0xFFe0e0e0)),
                          ),
                          child: futureBuilder
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10,),
              FloatingActionButton(
                onPressed: () async{
                  Address emptyPick = Address(latitude: 0,logitude: 0,placeFormatAddress: "",placeId: "",placeName: "Drop Location");
                  Address emptyDrop = Address(latitude: 0,logitude: 0,placeFormatAddress: "",placeId: "",placeName: "Pickup Location");
                  Provider.of<AppData>(context,listen: false).updateDestinationAdrress(emptyPick);
                  Provider.of<AppData>(context,listen: false).updatePickupAddress(emptyDrop);
                  print("Customer ID on Trips ${widget.customerId}");
                  var respons = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchPage(true , widget.customerId),
                      ));
                  if (respons != null) {
                    var address = Address();
                    address = respons;
                    print("Inside setupPositionLocationwithChanges ${address.placeName}");
                    //setupPositionLocationwithChanges(address);
                  }
                },
                child: Icon(Icons.add),
                backgroundColor: Color(0xFFff6f00),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void showAlertGlobal(BuildContext context, String title) {
    showDialog(
        useSafeArea: true,
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) =>
            AlertDialog(
              title: Center(child: Column(
                children: <Widget>[
                  Icon(Icons.supervised_user_circle_rounded,
                    color: Color(0xFFff6f00), size: 60,),
                  SizedBox(height: 10,),
                  Text(title,
                    style: GoogleFonts.roboto(fontSize: 20, color: Color(
                        0xFFff6f00)),),
                ],
              )),
              contentPadding: EdgeInsets.all(10.0),

              content: SingleChildScrollView(
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  //position
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 20, bottom: 20, left: 5, right: 5),
                        child: Column(
                          children: [

                            TextField(
                              controller: fullnamecontoller,
                              keyboardType: TextInputType.text,
                              decoration: getInputDecorationRegister(
                                  'Trip Name', Icon(Icons.keyboard)),
                              style: GoogleFonts.roboto(color: Colors.black87,
                                  fontSize: 15,
                                  height: 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
    );
  }





}
