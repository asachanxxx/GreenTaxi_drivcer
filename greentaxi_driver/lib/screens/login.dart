
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/brand_colors.dart';
import 'package:greentaxi_driver/screens/mainpage.dart';
import 'package:greentaxi_driver/screens/registration.dart';
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
      builder: (BuildContext context) => ProgressDialog(status: 'Logging you in',),
    );

    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text
    ).catchError((ex){

      //check error and display message
      Navigator.pop(context);
      //PlatformException thisEx = ex;
      showSnackBar(ex.message);

    });

    User user = userCredential.user;

    // final FirebaseUser user = (await _auth.signInWithEmailAndPassword(
    //   email: emailController.text,
    //   password: passwordController.text,
    // ).catchError((ex){
    //
    //   //check error and display message
    //   Navigator.pop(context);
    //   PlatformException thisEx = ex;
    //   showSnackBar(thisEx.message);
    //
    // })).user;

    if(user != null){
      // verify login
      DatabaseReference userRef = FirebaseDatabase.instance.reference().child('drivers/${user.uid}');
      userRef.once().then((DataSnapshot snapshot) {
        if(snapshot.value != null){
          Navigator.pushNamedAndRemoveUntil(context, MainPage.Id, (route) => false);
        }
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("images/backgrounds/pagemain.jpg"),
                  fit: BoxFit.cover)),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 100, left: 20, right: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white
                ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        SizedBox(height:50,),
                        Text('Log In',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(
                              fontSize: 40, fontWeight: FontWeight.bold),
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
                                keyboardType: TextInputType.visiblePassword,
                                decoration: getInputDecorationLogin('Password',Icon(Icons.security)),
                                style: f_font_text_Input,
                              ),
                              SizedBox(height: 40,),
                              TaxiButton(
                                title: 'LOGIN',
                                color: BrandColors.colorAccentPurple,
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

                        FlatButton(
                            onPressed: (){
                              Navigator.pushNamedAndRemoveUntil(context, RiderRegister.Id, (route) => false);
                            },
                            child: Text('Don\'t have an account, sign up here' ,style: f_font_16_Normal_Black100,)
                        ),

                        SizedBox(height: 160,),
                      ],
                    ),
                  ),

              ),
            ),
          ),
        )
    );
  }
}

