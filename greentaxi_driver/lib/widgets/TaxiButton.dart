import 'package:flutter/material.dart';
import 'package:greentaxi_driver/styles/styles.dart';

class TaxiButton extends StatelessWidget {

  final String title;
  final Color color;
  final Function onPress;

  TaxiButton({this.title,this.onPress,this.color});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color:color,
      textColor: Colors.black,
      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(25)
      ),
      child: Container(height: 40, child: Center(child: Text(title, style: f_font_Taxi_Button,))),
      onPressed: onPress,
    );
  }
}