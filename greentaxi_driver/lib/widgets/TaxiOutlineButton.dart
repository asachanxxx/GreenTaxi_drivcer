import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/brand_colors.dart';

class TaxiOutlineButton extends StatelessWidget {

  final String title;
  final Function onPressed;
  final Color color;

  TaxiOutlineButton({this.title, this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
        borderSide: BorderSide(color: color),
        shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(25.0),
        ),
        onPressed: onPressed,
        color: color,
        textColor: color,
        child: Container(
          height: 40.0,
          child: Center(
            child: Text(title,
                style: GoogleFonts.roboto(fontSize: 15.0, color: BrandColors.colorText)),
          ),
        )
    );
  }
}


