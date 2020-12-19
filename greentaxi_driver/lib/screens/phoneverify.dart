import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/models/phoneverifyargs.dart';
import 'package:greentaxi_driver/screens/mainpage.dart';
import 'package:greentaxi_driver/screens/verificationcode.dart';
import 'package:greentaxi_driver/styles/styles.dart';
import 'package:greentaxi_driver/widgets/ProgressDialog.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:greentaxi_driver/globalvariables.dart';

class PhoneVerification extends StatefulWidget {
  static const String Id = 'phoneverify';
  @override
  _PhoneVerificationState createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final _phoneNumberController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _smsController = TextEditingController();
  final SmsAutoFill _autoFill = SmsAutoFill();
  String _verificationId;
  int vstatus =0;

  void showSnackBar(String title){
    final snackbar = SnackBar(
      content: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  void verifyPhoneNumber() async {



    //Callback for when the user has already previously signed in with this phone number on this device
    PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential phoneAuthCredential) async {
      await _auth.signInWithCredential(phoneAuthCredential);

      Navigator.pushNamedAndRemoveUntil(context, MainPage.Id, (route) => false, arguments: ScreenArguments(
        '',
        _auth.currentUser.uid,
      ),);
      print("Phone number automatically verified and user signed in: ${_auth.currentUser.uid}");
      showSnackBar("Phone number automatically verified and user signed in: ${_auth.currentUser.uid}");
    };

    //Listens for errors with verification, such as too many attempts
    PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
          vstatus = 2;
      print('Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
      showSnackBar('Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
    };

    //Callback for when the code is sent
    PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      Navigator.pushNamedAndRemoveUntil(context, VerifyCode.Id, (route) => false, arguments: ScreenArguments(
        verificationId,
        '',
      ),);
      showSnackBar('Please check your phone for the verification code.');
      print(" PhoneCodeSent codeSent $verificationId");
      _verificationId = verificationId;
    };

    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
          vstatus = 4;
      showSnackBar("verification code: " + verificationId);
      print(" PhoneCodeAutoRetrievalTimeout $verificationId");
      _verificationId = verificationId;
    };


    try {
      print(" verifyPhoneNumber");
      await _auth.verifyPhoneNumber(
          phoneNumber:"+94 " +  _phoneNumberController.text,
          timeout: const Duration(seconds: 5),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout
      );
      print(" verifyPhoneNumber END");
    } catch (e) {
      showSnackBar("Failed to Verify Phone Number: ${e}");
    }


  }




  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <
            Widget>[
          Container(
            child: Stack(
              children: <Widget>[
               Container(
                  padding: EdgeInsets.fromLTRB(15.0, 130.0, 0.0, 0.0),
                  child: Text(
                    'taXy',
                    style:
                    TextStyle(fontSize: 80.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(180.0, 140.0, 0.0, 0.0),
                  child: Text(
                    '.',
                    style: TextStyle(
                        fontSize: 80.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                )
              ],
            ),
          ),
          Container(
              padding: EdgeInsets.only(top: 35.0, left: 40.0, right: 40.0),
              child: Column(
                children: <Widget>[
                  _buildPasswordTF(),
                  SizedBox(height: 40.0),
                  Container(
                      height: 40.0,
                      child: Material(
                        borderRadius: BorderRadius.circular(20.0),
                        shadowColor: Colors.greenAccent,
                        color: Colors.green,
                        elevation: 7.0,
                        child: GestureDetector(
                          onTap: () async {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) => ProgressDialog(status: 'Logging you in',),
                              );
                              verifyPhoneNumber();
                              Navigator.pop(context);
                          },
                          child: Center(
                            child: Text(
                              'Verify Number',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat'),
                            ),
                          ),
                        ),
                      )),
                  SizedBox(height: 20.0),
                ],
              )),

        ]));
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Let\'s start with your mobile number',
          style: kLabelStyle,
        ),
        SizedBox(height: 20.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: new TextField(
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'OpenSans',
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(top: 14.0),
                    prefixIcon: Icon(
                      Icons.phone,
                      color: Colors.black,
                    ),
                    hintText: '+94',
                    hintStyle: kLabelStyle_Ceyan,
                  ),
                ),
              ),
              //SizedBox(width: 5.0,),
              Expanded(
                flex: 8,
                child: new TextField(
                  controller: _phoneNumberController,
                  style: GoogleFonts.roboto(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff000000)),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: ' xxx-xxx-xxxx ',
                    hintStyle: kHintTextStyle2,
                  ),

                ),
              ),
              SizedBox(width: 20.0,),
            ],
          ),

        ),
      ],
    );
  }


}
