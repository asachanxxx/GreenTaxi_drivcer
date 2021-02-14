import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/models/customer.dart';
import 'package:greentaxi_driver/shared/repository/customerrepository.dart';
import 'package:greentaxi_driver/styles/styles.dart';
import 'package:greentaxi_driver/widgets/BrandDivider.dart';
import 'package:greentaxi_driver/widgets/ProgressDialog.dart';
import 'package:greentaxi_driver/widgets/TaxiButton.dart';
import 'package:greentaxi_driver/widgets/predictiontile.dart';

class CustomerTrips extends StatefulWidget {
  static const String Id = 'custrips';

  final Customer  customer;
  CustomerTrips({this.customer});

  @override
  _CustomerTripsState createState() => _CustomerTripsState();
}

class _CustomerTripsState extends State<CustomerTrips> {
  var fireDb = FirebaseDatabase.instance.reference().child('customers');
  List<Customer> customerList = new List<Customer>();
  UserCredential userCredentialx;

  final fullnamecontoller = TextEditingController();
  final phonecontoller = TextEditingController();
  final emailcontoller = TextEditingController();
  final passwordcontoller = TextEditingController();


  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  void getCustomers(String driverId) async {
    customerList = await CustomerRepository().filterData("system");
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    customerList = null;
  }


  @override
  void initState() {
    // TODO: implement initState
    CustomerRepository().filterData(currentFirebaseUser.uid).then((value) =>
    {
      setState(() {
        customerList = value;
      })
    });

    super.initState();
  }

  String emailGenarator() {
    String email = "";
    Random rand = Random();
    return "User${rand.nextInt(1000000)}@gmail.com";
  }

  var _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) =>
      String.fromCharCodes(Iterable.generate(
          length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));


  Future<UserCredential> register(String email, String password) async {
    FirebaseApp app = await Firebase.initializeApp(
        name: 'Secondary', options: Firebase
        .app()
        .options);
    try {
      userCredentialx = await FirebaseAuth.instanceFor(app: app)
          .createUserWithEmailAndPassword(email: email, password: password);
    }
    on FirebaseAuthException catch (e) {
      // Do something with exception. This try/catch is here to make sure
      // that even if the user creation fails, app.delete() runs, if is not,
      // next time Firebase.initializeApp() will fail as the previous one was
      // not deleted.
    }
    await app.delete();
    return Future.sync(() => userCredentialx);
  }

  void registerUser() async {
    var email = emailGenarator();
    var password = getRandomString(10);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(status: 'Creating customer.....',),
    );

    print("EMAIL: " + email);
    print("Password: " + password);

    try {
      await register(email, password).then((value) {
        if (value != null) {
          var newuser = FirebaseDatabase.instance.reference().child(
              'customers/${value.user.uid}');

          Map usermap = {
            'fullName': fullnamecontoller.text,
            'email': email,
            'phoneNumber': phonecontoller.text,
            'pass': "123456",
            'datetime': DateTime.now().toString(),
            'driverID': currentFirebaseUser.uid,
            'isSystemOwned': true,
            'rating': 5,
          };

          print("usermap ${usermap}");
          newuser.set(usermap);
          CustomerRepository().filterData(currentFirebaseUser.uid).then((
              value) =>
          {
            setState(() {
              customerList = value;
            })
          });
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
                      Text("Customer Trips",
                          style: GoogleFonts.roboto(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFffffff))
                      ),
                      Text("Customer: ${currentFirebaseUser.email}",
                          style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: Color(0xFFffffff),
                              fontWeight: FontWeight.bold)
                      ),

                    ],
                  ),
                ),
              ),
              SizedBox(height: 5,),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[

                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text("Trip list",
                              style: GoogleFonts.roboto(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF000000))),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Container(
                        height: 400,
                        decoration: BoxDecoration(
                          color: Color(0xFFeeeeee),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(width: 1.0,
                              color: Color(0xFFe0e0e0)),
                        ),
                        child:
                        ListView.separated(
                          padding: EdgeInsets.all(0),
                          itemBuilder: (context, index) {
                            return SearchTile2(
                              searchHistory: customerList[index],
                              isPickUpSearch: true,
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              BrandDivider(),
                          itemCount: customerList.length,
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10,),
              FloatingActionButton(
                onPressed: () {
                  // Add your onPressed code here!
                  //showAlertGlobal(context, "Add your customers");
                  print("customer ID : ${widget.customer.CustomerID}");

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
        builder: (BuildContext context) =>
            AlertDialog(
              title: Center(child: Column(
                children: <Widget>[
                  Icon(Icons.supervised_user_circle_rounded,
                    color: Color(0xFFff6f00), size: 60,),
                  SizedBox(height: 10,),
                  Text(title,
                    style: GoogleFonts.roboto(fontSize: 20, color: Color(
                        0xFFff6f00)),),
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
                      // decoration: BoxDecoration(
                      //   color: Color(0xFFFFFFFF),
                      //   borderRadius: BorderRadius.circular(10),
                      //   border: Border.all(width: 1.0,
                      //       color: Color(0xFF78909c)),
                      // ),

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
                              style: GoogleFonts.roboto(color: Colors.black87,
                                  fontSize: 15,
                                  height: 1),
                            ),
                            SizedBox(height: 10,),
                            TextField(
                              controller: phonecontoller,
                              keyboardType: TextInputType.phone,
                              decoration: getInputDecorationRegister(
                                  'Mobile No', Icon(Icons.phone)),
                              style: GoogleFonts.roboto(
                                  color: Colors.black87, fontSize: 15),
                            ),
                            SizedBox(height: 10,),
                            TaxiButton(
                              title: "Add Customer",
                              color: Color(0xFFff6f00),
                              onPress: () async {
                                bool emailValid = RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(emailcontoller.text);

                                //Check network aialability
                                var connectivity = await Connectivity()
                                    .checkConnectivity();
                                if (connectivity != ConnectivityResult.mobile &&
                                    connectivity != ConnectivityResult.wifi) {
                                  showSnackBar(
                                      'Oops! seems you are offline.');
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
            )
    );
  }
}
