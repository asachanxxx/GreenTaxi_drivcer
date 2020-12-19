import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/models/phoneverifyargs.dart';
import 'package:greentaxi_driver/styles/styles.dart';

class VerifyCode extends StatefulWidget {
  static const String Id = 'verifycode';

  @override
  _VerifyCodeState createState() => _VerifyCodeState();
}

class _VerifyCodeState extends State<VerifyCode> {
  FirebaseAuth _auth = FirebaseAuth.instance;

  void signInWithPhoneNumber(String verificationId) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: _vcodeController.text,
      );
      final User user = (await _auth.signInWithCredential(credential)).user;
      print("Successfully signed in UID: ${user.uid}");
      showSnackBar("Successfully signed in UID: ${user.uid}");
    } catch (e) {
      showSnackBar("Failed to sign in: " + e.toString());
      print("Failed to sign in: " + e.toString());
    }
  }

  static const routeName = '/extractArguments';
  var _vcodeController = TextEditingController();
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

  ScreenArguments args;
  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      key: scaffoldKey,
      body: Padding(
        padding: EdgeInsets.only(top: 100, left: 20, right: 20),
        child: Container(
          child: Column(
            children:<Widget> [
              Column(
                children:<Widget> [
                  Text("Verify Phone Code" ,style:   GoogleFonts.roboto(fontSize: 30,fontWeight: FontWeight.bold),),
                  SizedBox(height: 20,),
                  Text("verificationId ${(args!= null)?args.verificationId:"Null"}" ,style:   GoogleFonts.roboto(fontSize: 10),),
                  SizedBox(height: 20,),
                  _buildPasswordTF(),
                  SizedBox(height: 20,),
                  _buildLoginBtn()

                ],
              ),

            ],
          )
        ),
      ),
    );
  }


  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Let\'s enter the code received to your phone',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 70.0,
          child: TextField(
            controller: _vcodeController,
            style: GoogleFonts.roboto(
                        fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xff000000)),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 8.0),
              prefixIcon: Icon(
                Icons.vpn_key,
                color: Colors.black,
              ),
              hintText: 'Verification Code',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () async {
          var connectivityResult = await Connectivity().checkConnectivity();
          if (connectivityResult != ConnectivityResult.mobile &&
              connectivityResult != ConnectivityResult.wifi) {
            showSnackBar('No internet connectivity');
            return;
          }

          if (_vcodeController.text.length < 4) {
            showSnackBar('Please enter a verification code');
            return;
          }
          signInWithPhoneNumber(args.verificationId);

        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'LOGIN',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }


}
