import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/brand_colors.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/models/customer.dart';
import 'package:greentaxi_driver/shared/repository/customerrepository.dart';
import 'package:greentaxi_driver/styles/styles.dart';
import 'package:greentaxi_driver/widgets/AvailabilityButton.dart';
import 'package:greentaxi_driver/widgets/ConfirmSheet.dart';
import 'package:greentaxi_driver/widgets/TaxiButton.dart';

class Scr_Customers extends StatefulWidget {
  static const String Id = 'customers';
  @override
  _Scr_CustomersState createState() => _Scr_CustomersState();
}

class _Scr_CustomersState extends State<Scr_Customers> {

  var fireDb = FirebaseDatabase.instance.reference().child('customers');
  List<Customer> customerList = new List<Customer>();

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

  final List<String> entries = <String>['A', 'B', 'C'];
  final List<int> colorCodes = <int>[600, 500, 100];

  @override
  void initState(){
    // TODO: implement initState
    CustomerRepository().filterData("system").then((value) => {
      setState(() {
        customerList = value;
      })
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                color: Color(0xFFff6f00),
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    children: [
                      Text("Manage Customers",
                          style: GoogleFonts.roboto(
                              fontSize: 30, fontWeight:FontWeight.bold,color: Color(0xFFffffff))
                      ),
                      Text("Driver E-Mail: ${currentFirebaseUser.email}",
                          style: GoogleFonts.roboto(
                              fontSize: 12, color: Color(0xFFffffff))
                      ),
                      Text("Driver ID: ${currentFirebaseUser.uid}",
                          style: GoogleFonts.roboto(
                              fontSize: 12, color: Color(0xFFffffff))
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20,),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children:<Widget> [
                      Text("Your Customers",
                        style: GoogleFonts.roboto(
                            fontSize: 16, fontWeight:FontWeight.bold , color: Color(0xFF000000))),
                      SizedBox(height: 10,),
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(width: 1.0,
                              color: Color(0xFFe0e0e0)),
                        ),
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(8),
                            itemCount: customerList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                height: 50,
                                color: Colors.amber[colorCodes[1]],
                                child: Center(child: Text('Entry ${customerList[index].fullName}')),
                              );
                            }
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 1.0,
                        color: Color(0xFF78909c)),
                  ),

                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 20,  left: 20,right: 20),
                    child: Column(
                      children: [

                        TextField(
                          controller: fullnamecontoller,
                          keyboardType: TextInputType.text,
                          decoration: getInputDecorationRegister('Full Name',Icon(Icons.keyboard)),
                          style: GoogleFonts.roboto(color: Colors.black87,fontSize: 15,height: 1),
                        ),
                        SizedBox(height: 10,),
                        TextField(
                          controller: phonecontoller,
                          keyboardType: TextInputType.phone,
                          decoration: getInputDecorationRegister('Mobile No',Icon(Icons.phone)),
                          style: GoogleFonts.roboto(color: Colors.black87,fontSize: 15),
                        ),
                        SizedBox(height: 10,),
                        TaxiButton(
                          title: "Add Customer",
                          color:Color(0xFFff6f00),
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
                            // registerUser(emailcontoller.text,
                            //     passwordcontoller.text);
                          },
                        )

                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () async
              {
                // List<Customer> result = await CustomerRepository().filterData();
                // result.forEach((element) {
                //   print("Updated Customer ${element.phoneNumber}");
                // });
                print("Updated Customer ");
              },
              child: Text('Reverse items'),
            ),
          ],
        ),
      ),
    );

  }
}
