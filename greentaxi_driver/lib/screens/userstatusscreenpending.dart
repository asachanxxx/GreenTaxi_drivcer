import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/helpers/helpermethods.dart';
import 'package:greentaxi_driver/screens/login.dart';
import 'package:greentaxi_driver/screens/mainpage.dart';
import 'package:greentaxi_driver/screens/vehicleinfo.dart';
import 'package:greentaxi_driver/shared/auth/userrepo.dart';
import 'package:greentaxi_driver/widgets/ProgressDialog.dart';
import 'package:greentaxi_driver/widgets/TaxiButton.dart';

class UserStatusScreenPending extends StatefulWidget {
  static const String Id = 'userstatuspending';

  @override
  _UserStatusScreenState createState() => _UserStatusScreenState();
}

class _UserStatusScreenState extends State<UserStatusScreenPending> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top: 20, left: 20, right: 20),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          //padding: EdgeInsets.fromLTRB(50.0, 10.0, 0.0, 0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'GO',
                                style: GoogleFonts.rubik(
                                    fontSize: 60.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFff6f00)),
                              ),
                              Text(
                                '2',
                                style: GoogleFonts.rubik(
                                    fontSize: 80.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF424242)),
                              ),
                              Text(
                                'GO',
                                style: GoogleFonts.rubik(
                                    fontSize: 60.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFff6f00)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Go2Go වෙත සාදරයෙන් පිළිගනිමු.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 40,
                              ),
                              Text(
                                'ඔබ දැනටමත් Go2GO සමඟ ගිණුමක් නිර්මාණය කර ඇති නමුත් ගිණුම තවමත් සක්‍රිය කර නොමැත. අපි ඔබේ තොරතුරු සකසා ඔබගේ ගිණුම සක්‍රිය කරන තුරු කරුණාකර රැඳී සිටින්න. සක්‍රිය කිරීමෙන් පසු ඔබට ගිණුමට ලොග් වී සියලු අංග භුක්ති විඳිය හැකිය.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                              SizedBox(
                                height: 40,
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    'Contact        ',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.roboto(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '+94 011518548 ',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.roboto(
                                          color: Color(0xFFff6f00),
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    '   Hotline  ',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.roboto(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '  +94 0778151151',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.roboto(
                                          color: Color(0xFFff6f00),
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    '    E-Mail  ',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.roboto(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'inquery@gotogo.com',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.roboto(
                                          color: Color(0xFFff6f00),
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TaxiButton(
                                title: "Log Off",
                                color: Color(0xFFff6f00),
                                onPress: () {
                                  UserRepository.signOut();
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, LoginPage.Id, (route) => false);
                                },
                              ),
                              TaxiButton(
                                title: "Inform Go2Go",
                                color: Color(0xFFff6f00),
                                onPress: () async {
                                  DatabaseReference dref = FirebaseDatabase
                                      .instance
                                      .reference()
                                      .child("inquiry")
                                      .push();
                                  Map inqueryMap = {
                                    'userId': currentFirebaseUser.uid,
                                    'type': "AccActivation",
                                    'des': 'Request to activate account'
                                  };
                                  dref.set(inqueryMap);
                                  dref = null;
                                  showSnackBar(
                                      "your inquiry has been submitted successfully.we will get back to you shortly. (ඔබේ ප්‍රශ්නය සාර්ථකව ඉදිරිපත් කර ඇත. අපි ඉක්මනින් ඔබව සම්බන්දකරගන්නෙමු )");
                                },
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 160,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
