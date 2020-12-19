
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/brand_colors.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/helpers/helpermethods.dart';
import 'package:greentaxi_driver/models/tripdetails.dart';
import 'package:greentaxi_driver/screens/newtripspage.dart';
import 'package:greentaxi_driver/widgets/BrandDivider.dart';
import 'package:greentaxi_driver/widgets/ProgressDialog.dart';
import 'package:greentaxi_driver/widgets/TaxiButton.dart';
import 'package:greentaxi_driver/widgets/TaxiOutlineButton.dart';
import 'package:toast/toast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationDialog extends StatelessWidget {
  final TripDetails tripDetails;

  NotificationDialog({this.tripDetails});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(4),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(4)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 30.0,
            ),
            Image.asset(
              'images/taxi.png',
              width: 100,
            ),
            SizedBox(
              height: 16.0,
            ),
            Text(
              'NEW TRIP REQUEST',
              style: GoogleFonts.roboto(fontSize: 18),
            ),
            SizedBox(
              height: 30.0,
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Image.asset(
                        'images/pickicon.png',
                        height: 16,
                        width: 16,
                      ),
                      SizedBox(
                        width: 18,
                      ),
                      Expanded(
                          child: Container(
                              child: Text(
                                tripDetails.pickupAddress,
                                style: GoogleFonts.roboto(fontSize: 18),
                              )))
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Image.asset(
                        'images/desticon.png',
                        height: 16,
                        width: 16,
                      ),
                      SizedBox(
                        width: 18,
                      ),
                      Expanded(
                          child: Container(
                              child: Text(
                                tripDetails.destinationAddress,
                                style: GoogleFonts.roboto(fontSize: 18),
                              )))
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            BrandDivider(),
            SizedBox(
              height: 8,
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: TaxiOutlineButton (
                        title: 'DECLINE',
                        color: BrandColors.colorPrimary,
                        onPressed: () async {
                          assetsAudioPlayer.stop();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      child: TaxiButton(
                        title: 'ACCEPT',
                        color: BrandColors.colorGreen,
                        onPress: () async {
                          assetsAudioPlayer.stop();
                          checkAvailablity(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
          ],
        ),
      ),
    );
  }

  void checkAvailablity(context) {
    //show please wait dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Accepting request',
      ),
    );

    DatabaseReference newRideRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebaseUser.uid}/newtrip');
    newRideRef.once().then((DataSnapshot snapshot) {
      Navigator.pop(context);
      Navigator.pop(context);

      String thisRideID = "";
      if (snapshot.value != null) {
        thisRideID = snapshot.value.toString();
      } else {
        Toast.show("Ride not found 1", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }


      if (thisRideID == tripDetails.rideID) {
        newRideRef.set('accepted');
        ///This will remove the incoming data stream to him cus he is on a trip
        HelperMethods.disableHomTabLocationUpdates();
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewTripPage(
                tripDetails: tripDetails,
              ),
            ));
      } else if (thisRideID == 'cancelled') {
        Toast.show("Ride has been cancelled", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      } else if (thisRideID == 'timeout') {
        Toast.show("Ride has timed out", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      } else {
        Toast.show("Ride not found 2", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }



    });
  }

  void _launchMapsUrl( LatLng _originLatLng,  LatLng _destinationLatLng)   async {
    final url = 'https://www.google.com/maps/dir/?api=1&origin=${_originLatLng.latitude},${_originLatLng.longitude}&destination=${_destinationLatLng.latitude},${_destinationLatLng.longitude}&travelmode=driving';
    if (await canLaunch(url)) {
      print("Launching map.... $url");
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

}
