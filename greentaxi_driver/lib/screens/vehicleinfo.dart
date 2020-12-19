import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:connectivity/connectivity.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/brand_colors.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/models/drivers.dart';
import 'package:greentaxi_driver/models/vehicleinfo.dart';
import 'package:greentaxi_driver/screens/mainpage.dart';
import 'package:greentaxi_driver/shared/auth/driverrepository.dart';
import 'package:greentaxi_driver/shared/auth/userrepo.dart';
import 'package:greentaxi_driver/styles/styles.dart';
import 'package:greentaxi_driver/widgets/TaxiButton.dart';
//import 'package:date_time_picker/date_time_picker.dart';
import 'package:intl/intl.dart';

class VehicleInfo extends StatefulWidget {
  static const String Id = 'vehicleinfo';
  @override
  _StartUpScrState createState() => _StartUpScrState();
}

class _StartUpScrState extends State<VehicleInfo> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  DateTime selectedDate = DateTime.now();


  final fleetnocontoller = TextEditingController();
  final modelcontoller = TextEditingController();
  final makecontoller = TextEditingController();
  final colorcontoller = TextEditingController();
  final insuranceNumbercontoller = TextEditingController();
  final insuranceExpiryDatecontoller = TextEditingController();

  void registerVehicle() async {
    try {
      if (currentFirebaseUser != null) {
        DatabaseReference dbRef = FirebaseDatabase.instance.reference().child(
            'drivers/${currentFirebaseUser.uid}/vehicle_details');
        Map vehicleMap = {
          'fleetNo': fleetnocontoller.text,
          'make': makecontoller.text,
          'model': modelcontoller.text,
          'color': colorcontoller.text,
          'insuranceNo': insuranceNumbercontoller.text,
          'insuranceExpire': selectedDate.toString()
        };
        dbRef.set(vehicleMap);
        print('Save Done');
        Navigator.pushNamedAndRemoveUntil(context, MainPage.Id, (route) => false);
      } else {
        print('Current User nUll');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }


  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  String getCurrentUserName() {
    var cusName = 'xxx';
    UserRepository.getCurrentUserInfoRet().then((value) {
      cusName = value.fullName;
    });
    return cusName;
  }

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Welcome to Flutter',
        home: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("images/backgrounds/pagemain.jpg"),
                  fit: BoxFit.cover)),
          child: Container(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: 100, left: 20, right: 20),
                child: Scaffold(
                  key: scaffoldKey,
                  body: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 25,),
                        Text('Vehicle information',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        // Text('Driver: ' + currentFirebaseUser.displayName,
                        //   textAlign: TextAlign.center,
                        //   style: GoogleFonts.roboto(
                        //       fontSize: 15, fontWeight: FontWeight.normal),
                        // ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(40, 5, 40, 5),
                          child: Column(
                            children: <Widget>[
                              TextField(
                                onChanged: (value) {
                                  print('Text Change' + value);
                                },
                                controller: fleetnocontoller,
                                keyboardType: TextInputType.text,
                                decoration: getInputDecoration(
                                    'Plate No (EX: BCD-6555)'),
                                style: f_font_text_Input,
                              ),
                              SizedBox(height: 10,),
                              TextField(
                                controller: makecontoller,
                                keyboardType: TextInputType.emailAddress,
                                decoration: getInputDecoration(
                                    'Vehicle Make (EX: Suzuki)'),
                                style: f_font_text_Input,
                              ),
                              SizedBox(height: 10,),
                              TextField(
                                controller: modelcontoller,
                                keyboardType: TextInputType.text,
                                decoration: getInputDecoration(
                                    'Vehicle Model (EX: Alto)'),
                                style: f_font_text_Input,
                              ),
                              SizedBox(height: 10,),
                              TextField(
                                controller: colorcontoller,
                                obscureText: debugInstrumentationEnabled,
                                keyboardType: TextInputType.text,
                                decoration: getInputDecoration(
                                    'Vehicle Color (EX: Red)'),
                                style: f_font_text_Input,
                              ),

                              SizedBox(height: 10,),
                              TextField(
                                controller: insuranceNumbercontoller,
                                keyboardType: TextInputType.text,
                                obscureText: debugInstrumentationEnabled,
                                decoration: getInputDecoration(
                                    'Insurance No(EX: MCCNH200441011)'),
                                style: f_font_text_Input,
                              ),


                              SizedBox(height: 10,),
                              //Text("${selectedDate.toLocal()}".split(' ')[0]),

                              // DateTimePicker(
                              //   type: DateTimePickerType.date,
                              //   dateMask: 'd MMM, yyyy',
                              //   initialValue: DateTime.now().toString(),
                              //   firstDate: DateTime(2000),
                              //   lastDate: DateTime(2100),
                              //   icon: Icon(Icons.event),
                              //   dateLabelText: 'Insurance Expire',
                              //   timeLabelText: "Hour",
                              //   onChanged: (val) {
                              //     selectedDate = new DateFormat('yyyy-MM-dd').parse(val).toLocal();
                              //     print(selectedDate);
                              //   },
                              //   validator: (val) {
                              //     print(val);
                              //     return null;
                              //   },
                              //   onSaved: (val){
                              //   },
                              // ),
                              SizedBox(height: 30,),
                              TaxiButton(
                                title: "Register",
                                color: Color(0xff5a5fff),
                                onPress: () async {
                                  //Check network aialability
                                  var connectivity = await Connectivity()
                                      .checkConnectivity();
                                  if(connectivity != ConnectivityResult.mobile && connectivity != ConnectivityResult.wifi){
                                    showSnackBar(
                                        'Oops! seems you are offline.');
                                    print('Oops! seems you are offline.');
                                    return;
                                  }
                                  if (fleetnocontoller.text.length != 8) {
                                    showSnackBar(
                                        'Oops! invalid plate no.');
                                    print('Oops! invalid plate no.');
                                    return;
                                  }

                                  print('On Press.2');
                                  if (makecontoller.text.length < 2) {
                                    showSnackBar(
                                        'Oops! invalid make (EX:Suzuki).');
                                    print(
                                        'Oops! invalid make (EX:Suzuki,BMW).');
                                    return;
                                  }
                                  if (modelcontoller.text.length < 2) {
                                    showSnackBar(
                                        'Oops! invalid model (EX:Alto).');
                                    print(
                                        'Oops! invalid model (EX:Alto,228 Gran Coupe).');
                                    return;
                                  }
                                  if (colorcontoller.text.length < 3) {
                                    showSnackBar(
                                        'Oops! invalid color (EX:light green).');
                                    print(
                                        'Oops! invalid color (EX:light green,red).');
                                    return;
                                  }
                                  if (insuranceNumbercontoller.text.length <
                                      3) {
                                    showSnackBar(
                                        'Oops! invalid insurance Number .');
                                    print('Oops! invalid insurance Number .');
                                    return;
                                  }
                                  // if (insuranceExpiryDatecontoller.text.length < 3) {
                                  //   showSnackBar(
                                  //       'Oops! invalid color (EX:light green,red).');
                                  //   return;
                                  // }
                                  registerVehicle();
                                },
                              )
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
    );
  }
}
