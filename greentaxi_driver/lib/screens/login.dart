
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/brand_colors.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/helpers/helpermethods.dart';
import 'package:greentaxi_driver/screens/mainpage.dart';
import 'package:greentaxi_driver/screens/registration.dart';
import 'package:greentaxi_driver/screens/userstatusscreen.dart';
import 'package:greentaxi_driver/screens/vehicleinfo.dart';
import 'package:greentaxi_driver/styles/styles.dart';
import 'package:greentaxi_driver/widgets/ProgressDialog.dart';
import 'package:greentaxi_driver/widgets/TaxiButton.dart';

class LoginPage extends StatefulWidget {

  static const String Id = 'login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title){
    final snackbar = SnackBar(
      content: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  void login() async {
    //show please wait dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(status: 'Logging you in',),
    );

    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text
    ).catchError((ex) {
      //check error and display message
      Navigator.pop(context);
      //PlatformException thisEx = ex;
      showSnackBar(ex.message);
    });


    User user = userCredential.user;
    if (user != null) {
      // verify login
      DatabaseReference userRef = FirebaseDatabase.instance.reference().child(
          'drivers/${user.uid}');
      userRef.once().then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          if (snapshot.value["accountStatus"] == "Banned") {
            Navigator.pushNamedAndRemoveUntil(
                context, UserStatusScreen.Id, (route) => false);
          } else {
            if (snapshot.value["vehicle_details"] != null) {
              currentFirebaseUser = FirebaseAuth.instance.currentUser;
              Navigator.pushNamedAndRemoveUntil(
                  context, MainPage.Id, (route) => false);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                  context, VehicleInfo.Id, (route) => false);
            }
          }
        } else {
          //check error and display message
          Navigator.pop(context);
          showSnackBar("Oops! this account has no Associated driver account");
        }
      });
      HelperMethods.determinePosition().then((value) {
        print("currentpossitionCheck $value");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top: 20, left: 20, right: 20),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget> [
                  Container(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.fromLTRB(15.0, 30.0, 0.0, 0.0),
                          child: Text(
                            'taXy',
                            style:
                            GoogleFonts.lobster(fontSize: 80.0, fontWeight: FontWeight.bold, color: Color(0xFFff6f00) ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(140.0, 40.0, 0.0, 0.0),
                          child: Text(
                            '.',
                            style: TextStyle(
                                fontSize: 80.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFff6f00)),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white
                    ),
                      child: Column(
                        children: <Widget>[
                          SizedBox(height:10,),
                          Text('Log In',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Column(
                              children: <Widget>[
                                TextField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: getInputDecorationLogin('Email address',Icon(Icons.email)),
                                  style: f_font_text_Input,
                                ),
                                SizedBox(height: 10,),
                                TextField(
                                  controller: passwordController,
                                  obscureText: true,
                                  keyboardType: TextInputType.visiblePassword,
                                  decoration: getInputDecorationLogin('Password',Icon(Icons.security)),
                                  style: f_font_text_Input,
                                ),
                                SizedBox(height: 40,),
                                TaxiButton(
                                  title: 'LOGIN',
                                  color: Color(0xFFff6f00),
                                  onPress: () async {
                                    //check network availability
                                    var connectivityResult = await Connectivity().checkConnectivity();
                                    if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){
                                      showSnackBar('No internet connectivity');
                                      return;
                                    }

                                    if(!emailController.text.contains('@')){
                                      showSnackBar('Please enter a valid email address');
                                      return;
                                    }

                                    if(passwordController.text.length < 8){
                                      showSnackBar('Please enter a valid password');
                                      return;
                                    }

                                    login();

                                  },
                                ),

                              ],
                            ),
                          ),

                          Row(
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally,
                            children:<Widget> [
                              Text('Don\'t have an account,' ,style: f_font_16_Normal_Black100,),
                              FlatButton(
                                  onPressed: (){
                                    Navigator.pushNamedAndRemoveUntil(context, RiderRegister.Id, (route) => false);
                                  },
                                  child: Text('Sign Up here' ,style: GoogleFonts.roboto(fontSize: 17,fontWeight: FontWeight.bold, color:  Color(0xFFff6f00)),)
                              ),
                            ],
                          ),
                          SizedBox(height: 160,),
                        ],
                      ),

                  ),
                ],
              ),
            ),
          ),
        )
    );
  }
}

