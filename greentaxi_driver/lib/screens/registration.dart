import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
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
  final nicontoller = TextEditingController();


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
          'nic': nicontoller.text,
          'accountStatus': "NoVehicleDet",
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: 10, left: 20, right: 20),
            child: Column(
              children: <Widget>[
            Container(
            child: Stack(
                children: <Widget>[

                  Container(
                    //padding: EdgeInsets.fromLTRB(50.0, 10.0, 0.0, 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:<Widget> [
                        Text(
                          'GO',
                          style:
                          GoogleFonts.rubik(fontSize: 60.0, fontWeight: FontWeight.bold, color: Color(0xFFff6f00) ),
                        ),
                        Text(
                          '2',
                          style:
                          GoogleFonts.rubik(fontSize: 80.0, fontWeight: FontWeight.bold, color: Color(0xFF424242) ),
                        ),
                        Text(
                          'GO',
                          style:
                          GoogleFonts.rubik(fontSize: 60.0, fontWeight: FontWeight.bold, color: Color(0xFFff6f00) ),
                        ),
                      ],
                    ),
                  ),

          ],
        ),
      ),
                Container(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height:10,),
                      Text('Sign In',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),

                      Padding(
                        padding:  EdgeInsets.all(20.0),
                        child: Column(
                          children: <Widget>[
                            TextField(
                              controller: fullnamecontoller,
                              keyboardType: TextInputType.name,
                              inputFormatters:[
                                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z ]')),
                              ],
                              decoration: getInputDecorationRegister('Full Name',Icon(Icons.keyboard)),
                              style: GoogleFonts.roboto(color: Colors.black87,fontSize: 15,height: 1),
                            ),
                            SizedBox(height: 10,),
                            TextField(
                              controller: emailcontoller,
                              keyboardType: TextInputType.emailAddress,
                              inputFormatters:[
                                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z@.]')),
                              ],
                              decoration: getInputDecorationRegister('E-Mail',Icon(Icons.email)),
                              style: GoogleFonts.roboto(color: Colors.black87,fontSize: 15,height: 1),
                            ),
                            SizedBox(height: 10,),
                            TextField(
                              controller: phonecontoller,
                              inputFormatters:[
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                              ],
                              keyboardType: TextInputType.phone,
                              decoration: getInputDecorationRegister('Mobile No',Icon(Icons.phone)),
                              style: GoogleFonts.roboto(color: Colors.black87,fontSize: 15),
                            ),
                            SizedBox(height: 10,),
                            TextField(
                              controller: passwordcontoller,
                              obscureText: true,
                              decoration: getInputDecorationRegister('Password',Icon(Icons.vpn_key_sharp)),
                              style: GoogleFonts.roboto(color: Colors.black87,fontSize: 15),
                            ),
                            SizedBox(height: 10,),
                            TextField(
                              controller: nicontoller,
                              inputFormatters:[
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9vxVX]')),
                              ],
                              decoration: getInputDecorationRegister('ID Card No',Icon(Icons.card_membership)),
                              style: GoogleFonts.roboto(color: Colors.black87,fontSize: 15),
                            ),
                            SizedBox(height: 30,),
                            TaxiButton(
                              title: "Register",
                              color:Color(0xFFff6f00),
                              onPress: () async {
                                bool emailValid = RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(emailcontoller.text);

                                //print("isNicValid(0778151151) ${isNicValid("77815115115V")}");

                                //Check network aialability
                                var connectivity = await Connectivity()
                                    .checkConnectivity();
                                if(connectivity != ConnectivityResult.mobile && connectivity != ConnectivityResult.wifi){
                                  showSnackBar(
                                      'It seems you are offline.(කරුණාකර ඔබගේ දුරකතනයේ අන්තර්ජාල සම්බන්දතාවය පන ගන්වන්න)');
                                  return;
                                }
                                if (fullnamecontoller.text.length < 8) {
                                  showSnackBar(
                                      'Full name must be more than 3 characters.(සම්පූර්ණ නම අක්ෂර 8 ට වඩා වැඩි විය යුතුය.)');
                                  return;
                                }
                                if (!emailValid) {
                                  showSnackBar(
                                      'Invalid E-Mail address.(කරුණාකර වලංගු ඊමේල් ලිපිනයක් ඇතුලත් කරන්න )');
                                  return;
                                }
                                if (phonecontoller.text.length != 10) {
                                  showSnackBar(
                                      'Phone number must be 10 characters.(දුරකථන අංකය අක්ෂර 10 ක් විය යුතුය)');
                                  return;
                                }

                                if (passwordcontoller.text.length < 6) {
                                  showSnackBar(
                                      'The password must be at least 6 characters.(මුරපදය අවම වශයෙන් අක්ෂර 6 ක් විය යුතුය)');
                                  return;
                                }
                                if (!isNicValid(nicontoller.text.trim())) {
                                  showSnackBar(
                                      'invalid National Id card number.(කරුණාකර වලංගු ජාතික හැඳුනුම්පත් අංකයක්  ඇතුලත් කරන්න)');
                                  return;
                                }



                                registerUser(emailcontoller.text,
                                    passwordcontoller.text);
                              },
                            )
                          ],
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally,
                        children:<Widget> [
                          Text('Already have an account,' ,style: f_font_16_Normal_Black100,),
                          FlatButton(
                              onPressed: (){
                                Navigator.pushNamedAndRemoveUntil(context, LoginPage.Id, (route) => false);
                              },
                              child: Text('Log In' ,style: GoogleFonts.roboto(fontSize: 17,fontWeight: FontWeight.bold, color:  Color(0xFFff6f00)),)
                          ),
                        ],
                      ),
                      //
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isNicValid(String nic){
    print("nic: - $nic  Length : ${nic.length}");

    bool nicValid = false;
    if(nic.length <=10) {
      nicValid = RegExp(
          r"^(?:[+0]9)?[0-9]{9}[V,X,v,x]$")
          .hasMatch(nic);
    }else{
      nicValid = RegExp(
          r"^(?:[+0]9)?[0-9]{12}$")
          .hasMatch(nic);
    }
    return nicValid;
  }

}

