import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/globalvariables.dart';

class RatingsTab extends StatelessWidget {

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

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
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    children: [
                      Text("Ratings",
                          style: GoogleFonts.roboto(
                              fontSize: 30, fontWeight:FontWeight.bold,color: Color(0xFFffffff))
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


            ],
          ),
        ),
      ),
    );
  }
}
