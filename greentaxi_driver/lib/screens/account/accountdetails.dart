import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/widgets/BrandDivider.dart';

class AccountDetails extends StatefulWidget {
  @override
  _AccountDetailsState createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<AccountDetails> {
  @override
  Widget build(BuildContext context) {
    //var fireDb = FirebaseDatabase.instance.reference().child('customers');
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
                          SizedBox(
                            width: 10,

                          ),
                          GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                  Icons.arrow_back, color: Color(0xFFffffff))
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                  "Account Details",
                                  style: GoogleFonts.roboto(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFffffff))),

                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              FutureBuilder(
                  future: FirebaseDatabase.instance.reference().child(
                      'drivers/${currentFirebaseUser.uid}/profile').once(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      print("snapshot Data ${snapshot.data.value}");
                      return Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0, right: 20.0),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              GestureDetector(
                                  onTap: () {

                                  },
                                  child: menuColumn(
                                      Icons.account_box_rounded, "Full Name",
                                      "${snapshot.data.value!= null? snapshot.data.value["fullName"] : "No Full Name"}", false)),
                              GestureDetector(
                                  onTap: () {

                                  },
                                  child: menuColumn(
                                      Icons.email, "Email Address",
                                      "${snapshot.data.value!= null? snapshot.data.value["email"]: "No email Address"}", false)
                              ),
                              GestureDetector(
                                  onTap: () {

                                  },
                                  child: menuColumn(
                                      Icons.article_outlined, "NIC",
                                      "${snapshot.data.value!= null? snapshot.data.value["nic"]: "No email Address"}", false)),
                              GestureDetector(
                                  onTap: () {

                                  },
                                  child: menuColumn(
                                      Icons.phone,
                                      "Phone Number",
                                      "${snapshot.data.value!= null? snapshot.data.value["phoneNumber"]: "No email Address"}", false)),
                              GestureDetector(
                                  onTap: () {

                                  },
                                  child: menuColumn(
                                      Icons.security,
                                      "Security Key",
                                      "${snapshot.data.value!= null? snapshot.data.value["key"]: "No email Address"}", false)),
                              GestureDetector(
                                  onTap: () {

                                  },
                                  child: menuColumn(
                                      Icons.vpn_key, "Change Password",
                                      "**************", false)
                              ),
                              SizedBox(
                                height: 1,
                              ),
                              BrandDivider(),
                            ],
                          ),
                        );
                    }else{
                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20.0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                                onTap: () {

                                },
                                child: menuColumn(
                                    Icons.account_box_rounded, "Full Name",
                                    "Asanga Chandrakumara", false)),
                            GestureDetector(
                                onTap: () {

                                },
                                child: menuColumn(
                                    Icons.email, "Email Address",
                                    "xxx@xxxx.com", false)
                            ),
                            GestureDetector(
                                onTap: () {

                                },
                                child: menuColumn(
                                    Icons.article_outlined, "NIC",
                                    "855854587V", false)),
                            GestureDetector(
                                onTap: () {

                                },
                                child: menuColumn(
                                    Icons.phone,
                                    "Phone Number",
                                    "0778151151", false)),
                            GestureDetector(
                                onTap: () {

                                },
                                child: menuColumn(
                                    Icons.vpn_key, "Change Password",
                                    "**************", false)
                            ),
                            SizedBox(
                              height: 1,
                            ),
                            BrandDivider(),
                          ],
                        ),
                      );
                    }
                  }
              )

            ],
          ),
        ),
      ),
    );
  }

  Column menuColumn(IconData iconData, String headerText, String detailText, bool futherNav) {
    return Column(
      children: <Widget>[
        BrandDivider(),
        SizedBox(
          height: 10,
        ),
        Row(
          children: <Widget>[
            Icon(
              iconData,
              color: Color(0xFFe65100),
              size: 35.0,
              semanticLabel: 'Text to announce in accessibility modes',
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(headerText,
                      style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF102027))),
                  Text(detailText,
                      style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF102027))),
                ],
              ),
            ),
            SizedBox(
              width: 20,
            ),
            futherNav ?
            Icon(
              Icons.keyboard_arrow_right,
              color: Colors.black54,
              size: 30.0,
              semanticLabel: 'Text to announce in accessibility modes',
            ):Container(),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        //BrandDivider(),
      ],
    );
  }
}
