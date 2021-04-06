import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/models/customer.dart';
import 'file:///I:/TaxiApp/GIT/GreenTaxi_Driver/GreenTaxi_drivcer/greentaxi_driver/lib/screens/misc/customerfunctions.dart';
import 'package:greentaxi_driver/shared/auth/userrepo.dart';
import 'package:greentaxi_driver/shared/repository/customerrepository.dart';
import 'package:greentaxi_driver/styles/styles.dart';
import 'package:greentaxi_driver/widgets/BrandDivider.dart';
import 'package:greentaxi_driver/widgets/ProgressDialog.dart';
import 'package:greentaxi_driver/widgets/TaxiButton.dart';
import 'package:greentaxi_driver/widgets/predictiontile.dart';

class CustomerTab extends StatefulWidget {
  @override
  _CustomerTabState createState() => _CustomerTabState();
}

class _CustomerTabState extends State<CustomerTab> {
  var fireDb = FirebaseDatabase.instance.reference().child('customers');
  List<Customer> customerList = new List<Customer>();
  UserCredential userCredentialx;

  final fullnamecontoller = TextEditingController();
  final phonecontoller = TextEditingController();
  final emailcontoller = TextEditingController();
  final passwordcontoller = TextEditingController();
  var _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final makecall = new MakeCall();
  final databaseReference = FirebaseDatabase.instance
      .reference()
      .child('listTree/customerList')
      .once();

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

  void getCustomers(String driverId) async {
    //customerList = await CustomerRepository().filterData("system");
  }

  Future<void> asyncMethod() async {
    //customerList =  await CustomerRepository().filterData(currentFirebaseUser.uid);
    await CustomerRepository()
        .filterData(currentFirebaseUser.uid)
        .then((value) {
      setState(() {
        customerList = value;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    customerList = null;
  }

  bool loaded = false;

  @override
  void initState() {
    print("Init Driver Details  ${currentDriverInfo.SCR} ODR = ${currentDriverInfo.ODR}");
    super.initState();
  }

  String emailGenarator() {
    String email = "";
    Random rand = Random();
    return "User${rand.nextInt(1000000)}@gmail.com";
  }

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<UserCredential> register(String email, String password) async {
    FirebaseApp app = await Firebase.initializeApp(
        name: 'Secondary', options: Firebase.app().options);
    try {
      userCredentialx = await FirebaseAuth.instanceFor(app: app)
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {}
    await app.delete();
    return Future.sync(() => userCredentialx);
  }

  void registerUser() async {
    var email = emailGenarator();
    var password = getRandomString(10);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Creating customer.....',
      ),
    );

    print("EMAIL: " + email);
    print("Password: " + password);

    try {
      await register(email, password).then((value) {
        if (value != null) {
          var newuser = FirebaseDatabase.instance
              .reference()
              .child('customers/${value.user.uid}/profile');

          Map usermap = {
            'key': value.user.uid,
            'fullName': fullnamecontoller.text,
            'email': email,
            'phoneNumber': phonecontoller.text,
            'pass': "123456",
            'datetime': DateTime.now().toString(),
            'driverID': currentFirebaseUser.uid,
            'isSystemOwned': true,
            'rating': 5,
          };
          newuser.set(usermap);

          DatabaseReference listUsers = FirebaseDatabase.instance
              .reference()
              .child('listTree/customerList/${value.user.uid}');
          listUsers.set(usermap);
        }
      });

      fullnamecontoller.text = "";
      phonecontoller.text = "";

      //showSnackBar('Hurray! Account created successfully');
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      //Navigator.pop(context);
      if (e.code == 'weak-password') {
        showSnackBar('Oops! The password provided is too weak.');
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showSnackBar('Oops! The account already exists for that email.');
        print('The account already exists for that email.');
      }
    } catch (e) {
      //Navigator.pop(context);
      print(e);
      showSnackBar('Oops! There is a problem! Try again later.');
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    Widget returnControlMessage(
        String message1, String message2, bool isError) {
      return Container(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                new Text(
                  message1,
                  style: GoogleFonts.roboto(
                      fontSize: 15,
                      color: isError ? Color(0xFFd32f2f) : Color(0xFFff6f00),
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                BrandDivider(),
                SizedBox(
                  height: 10,
                ),
                new Text(
                  message2,
                  style: GoogleFonts.roboto(fontSize: 15),
                ),
              ],
            ),
          ));
    }

    var futureBuilder = new StreamBuilder(
      stream: FirebaseDatabase.instance
          .reference()
          .child('listTree/customerList')
          .orderByChild('driverID')
          .equalTo(currentFirebaseUser.uid)
          .onValue, // async work
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        Widget newwidget;
        List<dynamic> list;
        if (snapshot != null) {
          if (snapshot.data != null) {
            if (snapshot.data.snapshot != null) {
              if (snapshot.data.snapshot.value != null) {
                print("point 1");
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    newwidget = returnControlMessage(
                        "Please wait until loading the data (කරුණාකර දත්ත පූරණය වන තෙක් රැඳී සිටින්න)",
                        "",
                        true);
                    break;
                  case ConnectionState.waiting:
                    print("Waiting .........");
                    newwidget = returnControlMessage(
                        "Please wait until loading the data (කරුණාකර දත්ත පූරණය වන තෙක් රැඳී සිටින්න)",
                        "",
                        true);
                    break;
                  default:
                    if (snapshot.hasError)
                      newwidget = returnControlMessage(
                          "Problem with customer List (පාරිභෝගික ලැයිස්තුව)",
                          "The customer list cannot be shown at the moment. please try later(පාරිභෝගික ලැයිස්තුව මේ මොහොතේ පෙන්විය නොහැක. කරුණාකර පසුව උත්සාහ කරන්න)",
                          true);
                    else
                      print("Point 2");
                    Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
                    list = map.values.toList();
                    print("Key : ${snapshot.data.snapshot.value}");
                    newwidget = ListView.builder(
                      itemCount: list.length, //snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        Customer cus = Customer(
                            phoneNumber: list[index]["phoneNumber"],
                            fullName: list[index]["fullName"],
                            driverID: list[index]["driverID"],
                            CustomerID: list[index]["key"]);
                        print("Customer ID on Customer Tab $cus");
                        return SearchTile2(
                          custommerObj: cus,
                          isPickUpSearch: true,
                        );
                      },
                    );
                }
              } else {
                print("No Customers .........");
                newwidget = returnControlMessage(
                    'No Customers Found(කිසිඳු ගනුදෙනුකරුවකු හමු නොවීය)',
                    'Please Use plus signed button to add your customers(ඔබේ ගනුදෙනුකරුවන් ඇතුලත් කිරීමට කරුණාකර පහත බොත්තම භාවිතා කරන්න)',
                    false);
              }
            } else {
              print("No Customers .........");
              newwidget = returnControlMessage(
                  'No Customers Found(කිසිඳු ගනුදෙනුකරුවකු හමු නොවීය)',
                  'Please Use plus signed button to add your customers(ඔබේ ගනුදෙනුකරුවන් ඇතුලත් කිරීමට කරුණාකර පහත බොත්තම භාවිතා කරන්න)',
                  false);
            }
          } else {
            print("No Customers .........");
            newwidget = returnControlMessage(
                'No Customers Found(කිසිඳු ගනුදෙනුකරුවකු හමු නොවීය)',
                'Please Use plus signed button to add your customers(ඔබේ ගනුදෙනුකරුවන් ඇතුලත් කිරීමට කරුණාකර පහත බොත්තම භාවිතා කරන්න)',
                false);
          }
        } else {
          print("No Customers .........");
          newwidget = returnControlMessage(
              'No Customers Found(කිසිඳු ගනුදෙනුකරුවකු හමු නොවීය)',
              'Please Use plus signed button to add your customers(ඔබේ ගනුදෙනුකරුවන් ඇතුලත් කිරීමට කරුණාකර පහත බොත්තම භාවිතා කරන්න)',
              false);
        }
        return newwidget;
      },
    );

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
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      Text("Customers",
                          style: GoogleFonts.roboto(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFffffff))),
                      Text("Driver E-Mail: ${currentFirebaseUser.email}",
                          style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: Color(0xFFffffff),
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          height: 400,
                          decoration: BoxDecoration(
                            color: Color(0xFFeeeeee),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                width: 1.0, color: Color(0xFFe0e0e0)),
                          ),
                          child: futureBuilder),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                onPressed: () {
                  // Add your onPressed code here!
                  showAlertGlobal(context, "Add your customers");
                },
                child: Icon(Icons.add),
                backgroundColor: Color(0xFFff6f00),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showAlertGlobal(BuildContext context, String title) {
    showDialog(
        useSafeArea: true,
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) => AlertDialog(
              title: Center(
                  child: Column(
                children: <Widget>[
                  Icon(
                    Icons.supervised_user_circle_rounded,
                    color: Color(0xFFff6f00),
                    size: 60,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    title,
                    style: GoogleFonts.roboto(
                        fontSize: 20, color: Color(0xFFff6f00)),
                  ),
                ],
              )),
              contentPadding: EdgeInsets.all(10.0),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  //position
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 20, bottom: 20, left: 5, right: 5),
                        child: Column(
                          children: [
                            TextField(
                              controller: fullnamecontoller,
                              keyboardType: TextInputType.text,
                              decoration: getInputDecorationRegister(
                                  'Full Name', Icon(Icons.keyboard)),
                              style: GoogleFonts.roboto(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  height: 1),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: phonecontoller,
                              keyboardType: TextInputType.phone,
                              decoration: getInputDecorationRegister(
                                  'Mobile No', Icon(Icons.phone)),
                              style: GoogleFonts.roboto(
                                  color: Colors.black87, fontSize: 15),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TaxiButton(
                              title: "Add Customer",
                              color: Color(0xFFff6f00),
                              onPress: () async {
                                bool emailValid = RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(emailcontoller.text);

                                //Check network aialability
                                var connectivity =
                                    await Connectivity().checkConnectivity();
                                if (connectivity != ConnectivityResult.mobile &&
                                    connectivity != ConnectivityResult.wifi) {
                                  showSnackBar('Oops! seems you are offline.');
                                  return;
                                }
                                if (fullnamecontoller.text.length < 3) {
                                  showSnackBar(
                                      'Oops! full name must be more than 3 characters.');
                                  return;
                                }
                                if (phonecontoller.text.length != 10) {
                                  showSnackBar(
                                      'Oops! Phone number must be 10 characters.');
                                  return;
                                }
                                registerUser();
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

}
