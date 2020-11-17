import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:connectivity/connectivity.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/brand_colors.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/screens/login.dart';
import 'package:greentaxi_driver/screens/mainpage.dart';
import 'package:greentaxi_driver/screens/vehicleinfo.dart';
import 'package:greentaxi_driver/styles/styles.dart';
import 'package:greentaxi_driver/widgets/TaxiButton.dart';


class RiderRegister extends StatefulWidget {
  static const String Id = 'register';
  @override
  _CustomRegiterState createState() => _CustomRegiterState();
}

class _CustomRegiterState extends State<RiderRegister> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title) {
    final snackbar = SnackBar(content: Text(
      title,
      textAlign: TextAlign.center, style: TextStyle(fontSize: 15.0),
    ));
    scaffoldKey.currentState.showSnackBar(snackbar);
  }


  final fullnamecontoller = TextEditingController();
  final phonecontoller = TextEditingController();
  final emailcontoller = TextEditingController();
  final passwordcontoller = TextEditingController();


  void registerUser(text1, text2) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: emailcontoller.text,
          password: passwordcontoller.text
      );

      currentFirebaseUser = userCredential.user;

      if (userCredential != null) {
        print("EMAIL: " + userCredential.user.email);
        print("Password: " + passwordcontoller.text);
        DatabaseReference newuser = FirebaseDatabase.instance.reference().child(
            'drivers/${userCredential.user.uid}');

        Map usermap = {
          'fullName': fullnamecontoller.text,
          'email': emailcontoller.text,
          'phoneNumber': phonecontoller.text,
          'pass': passwordcontoller.text,
          'datetime': DateTime.now().toString()
        };
        newuser.set(usermap);
      }
      showSnackBar('Hurray! Account created successfully');
      //Navigator.pushNamedAndRemoveUntil(context, VehicleInfo.Id, (route) => false);
      Navigator.pushNamed(context, VehicleInfo.Id);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showSnackBar('Oops! The password provided is too weak.');
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showSnackBar('Oops! The account already exists for that email.');
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
      showSnackBar('Oops! There is a problem! Try again later.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/backgrounds/pagemain.jpg"),
                fit: BoxFit.cover)),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(top: 100, left: 20, right: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white
                ),
                child: Column(
                  children: <Widget>[
                    SizedBox(height:50,),
                    Text('Sign In',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                          fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    // Text('Create a rider\'s account',
                    //   textAlign: TextAlign.center,
                    //   style: GoogleFonts.roboto(fontSize: 30, fontWeight: FontWeight.bold),
                    // ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 5, 40, 5),
                      child: Column(
                        children: <Widget>[
                          TextField(
                            controller: fullnamecontoller,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                labelText: 'Full Name',
                                labelStyle: GoogleFonts.roboto(color: Colors.black38,fontSize: 16),
                                hintStyle: GoogleFonts.roboto(color: Colors.black38,fontSize: 14)
                            ),
                            style: GoogleFonts.roboto(color: Colors.black87,fontSize: 20),
                          ),
                          SizedBox(height: 10,),
                          TextField(
                            controller: emailcontoller,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                                labelText: 'Email address',
                                labelStyle: GoogleFonts.roboto(color: Colors.black38,fontSize: 16),
                                hintStyle: GoogleFonts.roboto(color: Colors.black54)

                            ),
                            style: GoogleFonts.roboto(color: Colors.black87,fontSize: 20),
                          ),
                          SizedBox(height: 10,),
                          TextField(
                            controller: phonecontoller,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                                labelText: 'Phone Number',
                                labelStyle: GoogleFonts.roboto(color: Colors.black38,fontSize: 16),
                                hintStyle: GoogleFonts.roboto(color: Colors.black54)

                            ),
                            style: GoogleFonts.roboto(color: Colors.black87,fontSize: 20),
                          ),
                          SizedBox(height: 10,),
                          TextField(
                            controller: passwordcontoller,
                            obscureText: debugInstrumentationEnabled,
                            decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: GoogleFonts.roboto(color: Colors.black38,fontSize: 16),
                                hintStyle: GoogleFonts.roboto(color: Colors.black54)

                            ),
                            style: GoogleFonts.roboto(color: Colors.black87,fontSize: 20),
                          ),
                          SizedBox(height: 30,),
                          TaxiButton(
                            title: "Register",
                            color: Color(0xff5a5fff),
                            onPress: () async {
                              bool emailValid = RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(emailcontoller.text);

                              //Check network aialability
                              var connectivity = await Connectivity()
                                  .checkConnectivity();
                              if(connectivity != ConnectivityResult.mobile && connectivity != ConnectivityResult.wifi){
                                showSnackBar(
                                    'Oops! seems you are offline.');
                                return;
                              }


                              if (fullnamecontoller.text.length < 3) {
                                showSnackBar(
                                    'Oops! full name must be more than 3 characters.');
                                return;
                              }
                              if (passwordcontoller.text.length < 6) {
                                showSnackBar(
                                    'Oops! password must be at least 6 characters.');
                                return;
                              }
                              if (phonecontoller.text.length != 10) {
                                showSnackBar(
                                    'Oops! Phone number must be 10 characters.');
                                return;
                              }
                              if (!emailValid) {
                                showSnackBar(
                                    'Oops! Invalid E-Mail address.');
                                return;
                              }
                              registerUser(emailcontoller.text,
                                  passwordcontoller.text);
                            },
                          )
                        ],
                      ),
                    ),

                    FlatButton(onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, LoginPage.Id, (route) => false);
                    },
                        child: Text('Already have an account? log in' ,style: f_font_16_Normal_Black100,))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

