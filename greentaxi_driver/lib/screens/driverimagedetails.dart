import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:connectivity/connectivity.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/helpers/helpermethods.dart';
import 'package:greentaxi_driver/screens/mainpage.dart';
import 'package:greentaxi_driver/screens/userstatusscreenpending.dart';
import 'package:greentaxi_driver/shared/auth/userrepo.dart';
import 'package:greentaxi_driver/widgets/BrandDivider.dart';
import 'package:greentaxi_driver/widgets/TaxiButton.dart';
import 'package:greentaxi_driver/widgets/TaxiButtonSmall.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class DriverMoreInfo extends StatefulWidget {
  static const String Id = 'driverMoreInfo';
  @override
  _StartUpScrState createState() => _StartUpScrState();
}

class _StartUpScrState extends State<DriverMoreInfo> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  DateTime selectedDate = DateTime.now();

  final picker = ImagePicker();

  var docCRMV;
  var docDriversLicense;
  var docinsurance;
  var docVehicleLicense;
  var docAccountDetails;
  var _imageFile;

  Future pickImage(String functionType) async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    print("fileName : ${pickedFile.path != null ? pickedFile.path : ""}");
    HelperMethods.showProgressDialog(context);
    setState(() {
      if (functionType == "CRMV") {
        ///Need to handle error The getter 'path' was called on null.
        docCRMV = io.File(pickedFile.path);
      } else if (functionType == "DL") {
        docDriversLicense = io.File(pickedFile.path);
      } else if (functionType == "INS") {
        docinsurance = io.File(pickedFile.path);
      } else if (functionType == "VL") {
        docVehicleLicense = io.File(pickedFile.path);
      } else if (functionType == "ACD") {
        docAccountDetails = io.File(pickedFile.path);
      }
      uploadFile(functionType);
    });
  }

  void uploadFile(String functionType) async {
    String fileName = currentFirebaseUser.uid + ".jpg";
    String ImageFileName = "";
    try {
      if (functionType == "CRMV") {
        _imageFile = docCRMV;
        ImageFileName = "docCRMV.jpg";
      } else if (functionType == "DL") {
        _imageFile = docDriversLicense;
        ImageFileName = "docDriversLicense.jpg";
      } else if (functionType == "INS") {
        _imageFile = docinsurance;
        ImageFileName = "docinsurance.jpg";
      } else if (functionType == "VL") {
        _imageFile = docVehicleLicense;
        ImageFileName = "docVehicleLicense.jpg";
      } else if (functionType == "ACD") {
        _imageFile = docAccountDetails;
        ImageFileName = "docAccountDetails.jpg";
      }

      await firebase_storage.FirebaseStorage.instance
          .ref()
          .child('$userDocumentPath/${currentFirebaseUser.uid}/$ImageFileName')
          .putFile(_imageFile);
      print(
          "Image Upload Done To $userDocumentPath/${currentFirebaseUser.uid}/$ImageFileName");
      print("Getting image from web");
      Navigator.pop(context);
      //getImage();
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print("FirebaseException : ${e.code}");
    }
  }

  void registerVehicle() async {
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        DatabaseReference dbRef = FirebaseDatabase.instance.reference().child(
            'drivers/${FirebaseAuth.instance.currentUser.uid}/vehicle_details');
        Map vehicleMap = {
          // 'fleetNo': fleetnocontoller.text,
          // 'make': makecontoller.text,
          // 'model': modelcontoller.text,
          // 'color': colorcontoller.text,
          // 'insuranceNo': insuranceNumbercontoller.text,
          'insuranceExpire': selectedDate.toString()
        };
        dbRef.set(vehicleMap);
        print('Save Done');
        Navigator.pushNamedAndRemoveUntil(
            context, MainPage.Id, (route) => false);
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
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
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
    return Scaffold(
        key: scaffoldKey,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top: 5, left: 20, right: 20),
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
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 80.0, 0.0, 10.0),
                          child: Center(
                            child: Text(
                              'Driver',
                              style: GoogleFonts.lobster(
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFff6f00)),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Additional Documents',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),

                        ///Certificate of Registration of Motor Vehicle **************************************************************************************
                        ///***********************************************************************************************************************************
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Certificate of Registration of Motor Vehicle(මෝටර් වාහනය ලියාපදිංචි කිරීමේ සහතිකය)',
                                style: GoogleFonts.roboto(
                                    color: Color(0xFFef6c00),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                width: 400,
                                height: 130,
                                decoration: BoxDecoration(
                                    color: Color(0xFFf5f5f5),
                                    border:
                                        Border.all(color: Color(0xFF9e9e9e))),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      docCRMV != null
                                          ? Image.file(
                                              docCRMV,
                                              width: 100,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              "images/icons/booking.png",
                                              width: 100,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              width: 220,
                                              child: Text(
                                                'Image details',
                                                style: GoogleFonts.roboto(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            BrandDivider(),
                                            Container(
                                              width: 220,
                                              child: Text(
                                                'Click the "Browse Image" button to insert image',
                                                style: GoogleFonts.roboto(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Row(
                                                children: <Widget>[
                                                  Container(
                                                    color: Colors.red,
                                                  ),
                                                  TaxiButtonSmall(
                                                    title: "Browse Image",
                                                    color: Color(0xFF424242),
                                                    onPress: () {
                                                      pickImage("CRMV");
                                                    },
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        ///Drivers License   *****************************************************************************************************************
                        ///***********************************************************************************************************************************
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Drivers License(රියැදුරු බලපත්‍රය)',
                                style: GoogleFonts.roboto(
                                    color: Color(0xFFef6c00),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                width: 400,
                                height: 130,
                                decoration: BoxDecoration(
                                    color: Color(0xFFf5f5f5),
                                    border:
                                        Border.all(color: Color(0xFF9e9e9e))),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      docDriversLicense != null
                                          ? Image.file(
                                              docDriversLicense,
                                              width: 100,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              "images/icons/booking.png",
                                              width: 100,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              width: 220,
                                              child: Text(
                                                'Image details',
                                                style: GoogleFonts.roboto(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            BrandDivider(),
                                            Container(
                                              width: 220,
                                              child: Text(
                                                'Click the "Browse Image" button to insert image',
                                                style: GoogleFonts.roboto(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Row(
                                                children: <Widget>[
                                                  Container(
                                                    color: Colors.red,
                                                  ),
                                                  TaxiButtonSmall(
                                                    title: "Browse Image",
                                                    color: Color(0xFF424242),
                                                    onPress: () {
                                                      pickImage("DL");
                                                    },
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        ///motor insurance policy   *****************************************************************************************************************
                        ///***********************************************************************************************************************************
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Motor Insurance Policy(මෝටර් වාහන රක්ෂණ ඔප්පුව)',
                                style: GoogleFonts.roboto(
                                    color: Color(0xFFef6c00),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                width: 400,
                                height: 130,
                                decoration: BoxDecoration(
                                    color: Color(0xFFf5f5f5),
                                    border:
                                        Border.all(color: Color(0xFF9e9e9e))),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      docinsurance != null
                                          ? Image.file(
                                              docinsurance,
                                              width: 100,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              "images/icons/booking.png",
                                              width: 100,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              width: 220,
                                              child: Text(
                                                'Image details',
                                                style: GoogleFonts.roboto(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            BrandDivider(),
                                            Container(
                                              width: 220,
                                              child: Text(
                                                'Click the "Browse Image" button to insert image',
                                                style: GoogleFonts.roboto(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Row(
                                                children: <Widget>[
                                                  Container(
                                                    color: Colors.red,
                                                  ),
                                                  TaxiButtonSmall(
                                                    title: "Browse Image",
                                                    color: Color(0xFF424242),
                                                    onPress: () {
                                                      pickImage("INS");
                                                    },
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        ///Vehicle Revenue License   *****************************************************************************************************************
                        ///***********************************************************************************************************************************
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Vehicle Revenue License(වාහන අදායම් බලපත්‍රය)',
                                style: GoogleFonts.roboto(
                                    color: Color(0xFFef6c00),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                width: 400,
                                height: 130,
                                decoration: BoxDecoration(
                                    color: Color(0xFFf5f5f5),
                                    border:
                                        Border.all(color: Color(0xFF9e9e9e))),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      docVehicleLicense != null
                                          ? Image.file(
                                              docVehicleLicense,
                                              width: 100,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              "images/icons/booking.png",
                                              width: 100,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              width: 220,
                                              child: Text(
                                                'Image details',
                                                style: GoogleFonts.roboto(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            BrandDivider(),
                                            Container(
                                              width: 220,
                                              child: Text(
                                                'Click the "Browse Image" button to insert image',
                                                style: GoogleFonts.roboto(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Row(
                                                children: <Widget>[
                                                  Container(
                                                    color: Colors.red,
                                                  ),
                                                  TaxiButtonSmall(
                                                    title: "Browse Image",
                                                    color: Color(0xFF424242),
                                                    onPress: () {
                                                      pickImage("VL");
                                                    },
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        ///Bank Passbook Copy   *****************************************************************************************************************
                        ///***********************************************************************************************************************************
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Bank Passbook Copy(බැංකු පාස් පොත් පිටපත)',
                                style: GoogleFonts.roboto(
                                    color: Color(0xFFef6c00),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                width: 400,
                                height: 130,
                                decoration: BoxDecoration(
                                    color: Color(0xFFf5f5f5),
                                    border:
                                        Border.all(color: Color(0xFF9e9e9e))),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      docAccountDetails != null
                                          ? Image.file(
                                              docAccountDetails,
                                              width: 100,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              "images/icons/booking.png",
                                              width: 100,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              width: 220,
                                              child: Text(
                                                'Image details',
                                                style: GoogleFonts.roboto(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            BrandDivider(),
                                            Container(
                                              width: 220,
                                              child: Text(
                                                'Click the "Browse Image" button to insert image',
                                                style: GoogleFonts.roboto(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Row(
                                                children: <Widget>[
                                                  Container(
                                                    color: Colors.red,
                                                  ),
                                                  TaxiButtonSmall(
                                                    title: "Browse Image",
                                                    color: Color(0xFF424242),
                                                    onPress: () {
                                                      pickImage("ACD");
                                                    },
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  TaxiButton(
                    title: "Complete Registration",
                    color: Color(0xFFff6f00),
                    onPress: () async {
                      print("docCRMV path ${docCRMV.toString()}");
                      if (docCRMV == null) {
                        showSnackBar(
                            'Please insert Certificate of Registration of Motor Vehicle (කරුණාකර මෝටර් වාහන ලියාපදිංචි කිරීමේ සහතිකය ඇතුළත් කරන්න)');
                        print(
                            'Please insert Certificate of Registration of Motor Vehicle (කරුණාකර මෝටර් වාහන ලියාපදිංචි කිරීමේ සහතිකය ඇතුළත් කරන්න)');
                        return;
                      }
                      if (docDriversLicense == null) {
                        showSnackBar(
                            'Please insert Drivers License (කරුණාකර රියදුරු බලපත්‍රය ඇතුළත් කරන්න)');
                        print(
                            'Please insert Drivers License (කරුණාකර රියදුරු බලපත්‍රය ඇතුළත් කරන්න)');
                        return;
                      }
                      if (docinsurance == null) {
                        showSnackBar(
                            'Please insert motor insurance policy (කරුණාකර මෝටර් වාහන රක්ෂණ ඔප්පුව ඇතුළත් කරන්න)');
                        print(
                            'Please insert motor insurance policy (කරුණාකර මෝටර් වාහන රක්ෂණ ඔප්පුව ඇතුළත් කරන්න)');
                        return;
                      }
                      if (docVehicleLicense == null) {
                        showSnackBar(
                            'Please insert Vehicle Revenue License (කරුණාකර වාහන ආදායම් බලපත්‍රය ඇතුළත් කරන්න)');
                        print(
                            'Please insert Vehicle Revenue License (කරුණාකර වාහන ආදායම් බලපත්‍රය ඇතුළත් කරන්න)');
                        return;
                      }
                      if (docAccountDetails == null) {
                        showSnackBar(
                            'Please insert Bank Passbook Copy (කරුණාකර බැංකු පාස් පොත් පිටපත ඇතුළත් කරන්න)');
                        print(
                            'Please insert Bank Passbook Copy (කරුණාකර බැංකු පාස් පොත් පිටපත ඇතුළත් කරන්න)');
                        return;
                      }

                      DatabaseReference dbRef2 = FirebaseDatabase.instance
                          .reference()
                          .child(
                              'drivers/${FirebaseAuth.instance.currentUser.uid}/profile/accountStatus');
                      dbRef2.set("Pending");

                      DatabaseReference dbRef3 = FirebaseDatabase.instance
                          .reference()
                          .child(
                              'listTree/driverList/${FirebaseAuth.instance.currentUser.uid}/accountStatus');
                      dbRef3.set("Pending");

                      dbRef2 = null;
                      dbRef3 = null;

                      Navigator.pushNamedAndRemoveUntil(context,
                          UserStatusScreenPending.Id, (route) => false);
                    },
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
