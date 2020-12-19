import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/models/company.dart';
import 'package:greentaxi_driver/screens/login.dart';
import 'package:greentaxi_driver/shared/auth/userrepo.dart';
import 'package:greentaxi_driver/shared/repository/companyrepository.dart';
import 'package:greentaxi_driver/styles/styles.dart';
import 'package:greentaxi_driver/widgets/TaxiButton.dart';

class ProfileTab extends StatefulWidget {
  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {

  var compa = CompanyRepository();
  var valueExists = null;

  var mytest ="";

  void getExists() async {

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
                      Text("Profile",
                          style: GoogleFonts.roboto(
                              fontSize: 30, fontWeight:FontWeight.bold,color: Color(0xFFffffff))
                      ),
                      Text("Driver E-Mail: ${currentFirebaseUser.email}",
                          style: GoogleFonts.roboto(
                              fontSize: 12, color: Color(0xFFffffff),fontWeight: FontWeight.bold)
                      ),

                    ],
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Positioned(
                    top: 50,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        TaxiButton (
                          onPress: () async {
                            UserRepository.signOut();
                            Navigator.pushNamedAndRemoveUntil(context, LoginPage.Id, (route) => false);
                          },
                          color: Colors.redAccent,
                          title: "Log Off",
                        ),
                        TaxiButton (
                          onPress: () async {
                            LatLng _originLatLng = LatLng(13.01463, 77.63556500000004);
                            LatLng _destinationLatLng = LatLng(13.0216685, 77.63998420000007);
                            // _launchMapsUrl(_originLatLng,_destinationLatLng);

                          },
                          color: Colors.redAccent,
                          title: "Map",
                        ),
                        TaxiButton (
                          onPress: () async {
                           var systemSettingsx =  await CompanyRepository().fetchSystemConfigurations();
                           print("valuesx   ${systemSettingsx.companyName} - ${systemSettingsx.SCR}" );

                          },
                          color: Colors.green,
                          title: "Load System Configs",
                        ),
                        SizedBox(height: 110,),
                        TaxiButton (
                          onPress: () async {
                            var systemSettingsx =  await CompanyRepository().filterData();

                          },
                          color: Colors.green,
                          title: "Realtime Query",
                        ),
                      ],
                    ),
                  ),

            ],
          ),
        ),
      ),
    );

    // return Stack(
    //   children: <Widget>[
    //     Container(
    //       height: 200,
    //       width: double.infinity,
    //       decoration: boxDecoDefualt,
    //     ),
    //
    //     Positioned(
    //       top: 50,
    //       left: 0,
    //       right: 0,
    //       child: Column(
    //         children: [
    //           TaxiButton (
    //             onPress: () async {
    //               UserRepository.signOut();
    //               Navigator.pushNamedAndRemoveUntil(context, LoginPage.Id, (route) => false);
    //             },
    //             color: Colors.redAccent,
    //             title: "Log Off",
    //           ),
    //           TaxiButton (
    //             onPress: () async {
    //               LatLng _originLatLng = LatLng(13.01463, 77.63556500000004);
    //               LatLng _destinationLatLng = LatLng(13.0216685, 77.63998420000007);
    //               // _launchMapsUrl(_originLatLng,_destinationLatLng);
    //
    //             },
    //             color: Colors.redAccent,
    //             title: "Map",
    //           ),
    //           TaxiButton (
    //             onPress: () async {
    //              var systemSettingsx =  await CompanyRepository().fetchSystemConfigurations();
    //              print("valuesx   ${systemSettingsx.companyName} - ${systemSettingsx.SCR}" );
    //
    //             },
    //             color: Colors.green,
    //             title: "Load System Configs",
    //           ),
    //           SizedBox(height: 110,),
    //           TaxiButton (
    //             onPress: () async {
    //               var systemSettingsx =  await CompanyRepository().filterData();
    //
    //             },
    //             color: Colors.green,
    //             title: "Realtime Query",
    //           ),
    //         ],
    //       ),
    //     ),
    //
    //
    //
    //
    //   ],
    // );
  }
}
