import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/brand_colors.dart';
import 'package:greentaxi_driver/widgets/TaxiButton.dart';
import 'package:greentaxi_driver/widgets/TaxiOutlineButton.dart';

class ConfirmSheet extends StatelessWidget {

  final String title;
  final String subtitle;
  final Function onPressed;

  ConfirmSheet({this.title, this.subtitle, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15.0, // soften the shadow
            spreadRadius: 0.5, //extend the shadow
            offset: Offset(
              0.7, // Move to right 10  horizontally
              0.7, // Move to bottom 10 Vertically
            ),
          )
        ],

      ),
      height: 220,
      child: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          children: <Widget>[SizedBox(height:  10,),
           Text(
             title,
             textAlign: TextAlign.center,
             style: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.bold, color: BrandColors.colorText),
           ),

            SizedBox(height: 20,),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(color: BrandColors.colorTextLight),
            ),

            SizedBox(height: 24,),

            Row(
              children: <Widget>[

                Expanded(
                  child: Container(
                    child: TaxiOutlineButton(
                      title: 'BACK',
                      color: Colors.black45,
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),

                SizedBox(width: 16,),

                Expanded(
                  child: Container(
                    child: TaxiButton(
                      onPress: onPressed,
                      color: (title == 'GO ONLINE') ? BrandColors.colorGreen : Colors.red,
                      title: 'CONFIRM',
                    ),
                  ),
                ),
              ],
            )

          ],
        ),
      ),
    );
  }
}
