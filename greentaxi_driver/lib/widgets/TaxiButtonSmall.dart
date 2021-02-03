import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/styles/styles.dart';

class TaxiButtonSmall extends StatelessWidget {

  final String title;
  final Color color;
  final Function onPress;

  TaxiButtonSmall({this.title,this.onPress,this.color});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color:color,
      textColor: Colors.black,
      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(25)
      ),
      child: Container(height: 30, child: Center(child: Text(title, style: f_font_Taxi_Button,))),
      onPressed: onPress,
    );
  }
}

class TaxiButtonSmallWithSize extends StatelessWidget {

  final String title;
  final Color color;
  final Function onPress;
  final double fontSize;

  TaxiButtonSmallWithSize({this.title,this.onPress,this.color,this.fontSize});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color:color,
      textColor: Colors.black,
      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(25)
      ),
      child: Container(height: 30, child: Center(child: Text(title, style: GoogleFonts.roboto(
          fontSize: fontSize, color: Colors.white, fontWeight: FontWeight.normal),))),
      onPressed: onPress,
    );
  }
}