import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/models/company.dart';
import 'package:greentaxi_driver/models/drivers.dart';
import 'package:greentaxi_driver/screens/login.dart';
import 'package:greentaxi_driver/shared/auth/userrepo.dart';
import 'package:greentaxi_driver/shared/repository/companyrepository.dart';
import 'package:greentaxi_driver/styles/styles.dart';
import 'package:greentaxi_driver/widgets/BrandDivider.dart';
import 'package:greentaxi_driver/widgets/TaxiButton.dart';

class ProfileTab extends StatefulWidget {
  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {

  var compa = CompanyRepository();
  var valueExists = null;

  var mytest = "";

  void getExists() async {

  }

  void getCurrentDriverInfo() async {
    currentFirebaseUser = FirebaseAuth.instance.currentUser;
    DatabaseReference driverRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebaseUser.uid}');

    driverRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        currentDriverInfo = Driver.fromSnapshot(snapshot);
      }
    });


  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentDriverInfo();
    getExists();
  }

  @override
  Widget build(BuildContext context) {
    var fireDb = FirebaseDatabase.instance.reference().child('customers');
    final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

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
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    children: [
                      Row(
                        children: <Widget>[
                          SizedBox(width: 5,),
                          ClipOval(
                            child: Container(
                              height: 80,
                              width: 80,
                              color: Theme
                                  .of(context)
                                  .scaffoldBackgroundColor,
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Theme
                                      .of(context)
                                      .primaryColor,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 20,),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("${currentDriverInfo != null ? "Driver Name" : "Taxy Driver"} ",
                                  style: GoogleFonts.roboto(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFffffff))
                              ),
                              SizedBox(height: 5,),
                              Text("E-mail: ${currentFirebaseUser.email != null
                                  ? currentFirebaseUser.email
                                  : ""}  Phone: ${currentFirebaseUser
                                  .phoneNumber != null
                                  ? "0778151151"
                                  : "0778151151"}",
                                  style: GoogleFonts.roboto(
                                      fontSize: 12,
                                      color: Color(0xFFffffff),
                                      fontWeight: FontWeight.bold)
                              ),
                              SizedBox(height: 5,),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 24.0,
                                    semanticLabel: 'Text to announce in accessibility modes',
                                  ),
                                  Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 24.0,
                                    semanticLabel: 'Text to announce in accessibility modes',
                                  ),
                                  Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 24.0,
                                    semanticLabel: 'Text to announce in accessibility modes',
                                  ),
                                  Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 24.0,
                                    semanticLabel: 'Text to announce in accessibility modes',
                                  ),
                                  Icon(
                                    Icons.star_half,
                                    color: Colors.white,
                                    size: 24.0,
                                    semanticLabel: 'Text to announce in accessibility modes',
                                  ),
                                  Text("4.3 ",
                                      style: GoogleFonts.roboto(
                                          fontSize: 20,
                                          color: Color(0xFFffffff),
                                          fontWeight: FontWeight.bold)
                                  ),
                                ],
                              ),

                            ],
                          ),

                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Column(
                  children: [
                    BrandDivider(),
                    SizedBox(height: 10,),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.accessibility,
                          color: Colors.black,
                          size: 30.0,
                          semanticLabel: 'Text to announce in accessibility modes',
                        ),
                        SizedBox(width: 5,),
                        Flexible( //newly added
                            child: Container(
                              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 15.0),
                              child: Text(
                                  "Tell the customers about your in 150 words (ඔබ ගැන ගනුදෙනුකරුවන්ට කියන්න)",
                                  style: GoogleFonts.roboto(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                      color: Color(0xFFe65100))
                              ),
                            )
                        )
                      ],
                    ),
                    SizedBox(height: 10,),


                    GestureDetector(
                      onTap: (){

                      },
                      child: menuColumn(Icons.group_add,"Account Details","To find out more details about your account")
                    ),
                    //SizedBox(height: 10,),

                    GestureDetector(
                        onTap: (){

                        },
                        child: menuColumn(Icons.directions,"Trip Details","Search through your past trip details            ")
                    ),
                    GestureDetector(
                        onTap: (){

                        },
                        child: menuColumn(Icons.local_shipping,"Vehicle Details","view or edit the details of your vehicle         ")
                    ),


                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Column menuColumn(IconData iconData,String headerText,String detailText) {
    return Column(
      children: <Widget>[
        BrandDivider(),
        SizedBox(height: 10,),
        Row(
          children: <Widget>[
            Icon(
              iconData,
              color: Colors.black,
              size: 50.0,
              semanticLabel: 'Text to announce in accessibility modes',
            ),
            SizedBox(width: 20,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(headerText,
                    style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF102027))
                ),
                Text(detailText,
                    style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF102027))
                ),
              ],
            ),
            SizedBox(width: 20,),
            Icon(
              Icons.keyboard_arrow_right,
              color: Colors.black,
              size: 40.0,
              semanticLabel: 'Text to announce in accessibility modes',
            ),
          ],
        ),
        SizedBox(height: 10,),
        BrandDivider(),
      ],
    );
  }
}




//*
//   TaxiButton (
//                       onPress: () async {
//                         UserRepository.signOut();
//                         Navigator.pushNamedAndRemoveUntil(context, LoginPage.Id, (route) => false);
//                       },
//                       color: Colors.redAccent,
//                       title: "Log Off",
//                     ),
//                     TaxiButton (
//                       onPress: () async {
//                         LatLng _originLatLng = LatLng(13.01463, 77.63556500000004);
//                         LatLng _destinationLatLng = LatLng(13.0216685, 77.63998420000007);
//                         // _launchMapsUrl(_originLatLng,_destinationLatLng);
//
//                       },
//                       color: Colors.redAccent,
//                       title: "Map",
//                     ),
//                     TaxiButton (
//                       onPress: () async {
//                        var systemSettingsx =  await CompanyRepository().fetchSystemConfigurations();
//                        print("valuesx   ${systemSettingsx.companyName} - ${systemSettingsx.SCR}" );
//
//                       },
//                       color: Colors.green,
//                       title: "Load System Configs",
//                     ),
// */