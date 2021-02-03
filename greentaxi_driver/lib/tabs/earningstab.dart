import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/brand_colors.dart';
import 'package:greentaxi_driver/dataprovider/appdata.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/styles/styles.dart';
import 'package:greentaxi_driver/widgets/BrandDivider.dart';
import 'package:greentaxi_driver/widgets/TaxiButton.dart';
import 'package:greentaxi_driver/widgets/TaxiButtonSmall.dart';
import 'package:provider/provider.dart';

class EarningsTab extends StatefulWidget {

  @override
  _EarningsTabState createState() => _EarningsTabState();
}

class _EarningsTabState extends State<EarningsTab>  with TickerProviderStateMixin{
  var fireDb = FirebaseDatabase.instance.reference().child('customers');

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  double searchSheetHeight = (Platform.isIOS) ? 250 : 200;

  final fullnamecontoller = TextEditingController();
  final phonecontoller = TextEditingController();
  final emailcontoller = TextEditingController();

  double earningsMonth = 0.0;
  double commissionMonth = 0.0;
  double tripsNoOf = 0.0;
  double kmNoOf = 0.0;
  double balance = -10.0;

  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
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
                      Text("Earnings",
                          style: GoogleFonts.roboto(
                              fontSize: 25, fontWeight:FontWeight.bold,color: Color(0xFFffffff))
                      ),
                      Text("Driver E-Mail: ${currentFirebaseUser.email}",
                          style: GoogleFonts.roboto(
                              fontSize: 12, color: Color(0xFFffffff),fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10,),
              ///Summary *************************************************************************************************************
              Container(
                  margin: const EdgeInsets.only(
                      top: 10, bottom: 5, left: 20, right: 20),
                  height: searchSheetHeight,
                  decoration:tabBoxDecorations,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 5),
                        Text(
                          'Earning for Month',
                          style: f_font_15_Bold_Black100,
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(child: _textTodayEarnings()),
                            SizedBox(width: 10,),
                            Expanded(child: _textTodayCommission()),
                           ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: <Widget>[
                            Text(
                              'You have Completed ',
                              style: f_font_15_Bold_Black100,
                            ),
                            Text(
                              '$tripsNoOf',
                              style:GoogleFonts.roboto(fontSize: 18,fontWeight: FontWeight.bold,color: Color(0xfff57f17)) ,
                            ),
                            Text(
                              ' trips today',
                              style: f_font_15_Bold_Black100,
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: <Widget>[
                            Text(
                              'You have travelled ',
                              style: f_font_15_Bold_Black100,
                            ),
                            Text(
                              '$kmNoOf',
                              style:GoogleFonts.roboto(fontSize: 18,fontWeight: FontWeight.bold,color: Color(0xfff57f17)) ,
                            ),
                            Text(
                              ' KM today',
                              style: f_font_15_Bold_Black100,
                            ),
                          ],
                        ),
                      ],
                    ),



                  )),
              SizedBox(height: 10,),
              ///Summary *************************************************************************************************************
              Container(
                  margin: const EdgeInsets.only(
                      top: 5, bottom: 20, left: 20, right: 20),
                  height: 280,
                  decoration:tabBoxDecorations,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 5),
                        Text(
                          'Account Summary',
                          style: f_font_15_Bold_Black100,
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _textBalance(),
                          ],
                        ),
                        SizedBox(height: 15),
                        TaxiButtonSmallWithSize(
                          title: "Payment Summary(ගෙවුම් සාරාංශය)",
                          color:Color(0xFFff6f00),
                          fontSize: 14,
                          onPress: () async {
                          },
                        ),
                        TaxiButtonSmallWithSize(
                          title: "Monthly Summary(මාසික සාරාංශය)",
                          color:Color(0xFFff6f00),
                          fontSize: 14,
                          onPress: () async {
                          },
                        ),
                        TaxiButtonSmallWithSize(
                          title: "Total Summary(සම්පූර්ණ සාරාංශය)",
                          color:Color(0xFFff6f00),
                          fontSize: 14,
                          onPress: () async {
                          },
                        ),


                      ],
                    ),
                  )),

            ],
          ),
        ),
      ),
    );
  }


  Widget _textTodayEarnings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 45),
          child: Text(
            'EARNING',
            style: kLabelStyleEarnig,
          ),
        ),
        SizedBox(height: 5.0),
        Container(
          alignment: Alignment.center,
          decoration: kBoxDecorationStyle,
          height: 40.0,
          width: 150,
          child: Text("LKR ${earningsMonth.toString()}",
              style: GoogleFonts.roboto(
                  color: Colors.white, fontSize: 18,fontWeight: FontWeight.bold)
          ),
        ),
      ],
    );
  }

  Widget _textTodayCommission() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Text(
            'COMMISSION',
            style: kLabelStyleEarnig,
          ),
        ),
        SizedBox(height: 5.0),
        Container(
          alignment: Alignment.center,
          decoration: kBoxDecorationStyle,
          height: 40.0,
          width: 150,
          child: Text( "LKR 0.00",textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                  color: Colors.white, fontSize: 18,fontWeight: FontWeight.bold)
          ),
        ),
      ],
    );
  }

  Widget _textBalance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Text(
            'Balance(අද වන විට ශේෂය)',
            style: kLabelStyleEarnig,
          ),
        ),
        SizedBox(height: 5.0),
        Container(
          alignment: Alignment.center,
          decoration: kBoxDecorationStyle,
          height: 40.0,
          width: 250,
          child: (balance <0)?
          Text( "LKR $balance",textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                  color: Colors.red, fontSize: 25,fontWeight: FontWeight.bold)
          ):
          Text( "LKR $balance",textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                  color: Colors.white, fontSize: 25,fontWeight: FontWeight.bold)
          )
          ,
        ),
      ],
    );
  }

}
