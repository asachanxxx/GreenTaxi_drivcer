import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greentaxi_driver/brand_colors.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/helpers/helpermethods.dart';
import 'package:greentaxi_driver/helpers/mapkithelper.dart';
import 'package:greentaxi_driver/models/tripdetails.dart';
import 'package:greentaxi_driver/widgets/CollectPaymentDialog.dart';
import 'package:greentaxi_driver/widgets/ProgressDialog.dart';
import 'package:greentaxi_driver/widgets/TaxiButton.dart';
import 'package:url_launcher/url_launcher.dart';


class NewTripPage extends StatefulWidget {

  final TripDetails tripDetails;
  NewTripPage({this.tripDetails});
  @override
  _NewTripPageState createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  GoogleMapController rideMapController;
  Completer<GoogleMapController> _controller = Completer();
  double mapPaddingBottom = 0;

  Set<Marker> _markers = Set<Marker>();
  Set<Circle> _circles = Set<Circle>();
  Set<Polyline> _polyLines = Set<Polyline>();

  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  var geoLocator = Geolocator();
  var locationOptions =
      LocationOptions(accuracy: LocationAccuracy.bestForNavigation);

  BitmapDescriptor movingMarkerIcon;

  Position myPosition;

  String status = 'init';

  String durationString = '';

  bool isRequestingDirection = false;

  String buttonTitle = 'Drive to Customer';

  Color buttonColor = BrandColors.colorGreen;

  Timer timer;

  int durationCounter = 0;


  void getLocationUpdates() {
    /*
    * The technology behind this is that if the map kit will calculate the rotations according to the given lat langs . so if we give lat langs too far away
    * this calculation will not give us a correct heading direction. so fo that we use old position just before we been and set it in to
    *  -- oldPosition
    * Variable. so oldPosition always contain before position that we was and that was so short. so the heading will be calculated as the lat lng changes
    * */
    LatLng oldPosition = LatLng(0, 0);

    /*
    We use getPositionStream to get the location updates frequently. so every time the stream updated by the Firebase pos will be updated
    * */
    ridePositionStream = geoLocator
        .getPositionStream(locationOptions)
        .listen((Position position) {
      myPosition = position;
      currentPosition = position;

      LatLng pos = LatLng(position.latitude, position.longitude);

      var rotation = MapKitHelper.getMarkerRotation(oldPosition.latitude,
          oldPosition.longitude, pos.latitude, pos.longitude);

      print('my rotation = $rotation');

      Marker movingMaker = Marker(
        markerId: MarkerId('moving'),
        position: pos,
        icon: movingMarkerIcon,
        rotation: rotation,
        infoWindow: InfoWindow(title: 'Current Location'),
      );

      setState(() {
        CameraPosition cp = new CameraPosition(target: pos, zoom: 17);
        rideMapController.animateCamera(CameraUpdate.newCameraPosition(cp));

        _markers.removeWhere((marker) => marker.markerId.value == 'moving');
        _markers.add(movingMaker);
      });

      /*
      This will always update our current positions to old position so we can calculate the Rotation of the Marker
      * */
      oldPosition = pos;

      updateTripDetails();

      Map locationMap = {
        'myPosition latitude': myPosition.latitude.toString(),
        'myPosition longitude': myPosition.longitude.toString(),
      };

      rideRef.child('driver_location').set(locationMap);
    });
  }

  void createMarker() {
    if (movingMarkerIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration,
              (Platform.isIOS)
                  ? 'images/car_ios.png'
                  : 'images/car_android.png')
          .then((icon) {
        movingMarkerIcon = icon;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    acceptTrip();
  }

  @override
  Widget build(BuildContext context) {
    createMarker();

    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPaddingBottom),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            mapToolbarEnabled: true,
            trafficEnabled: true,
            mapType: MapType.normal,
            circles: _circles,
            markers: _markers,
            polylines: _polyLines,
            initialCameraPosition: googlePlex,
            onMapCreated: (GoogleMapController controller) async {
              _controller.complete(controller);
              rideMapController = controller;

              setState(() {
                mapPaddingBottom = (Platform.isIOS) ? 255 : 260;
              });

              var currentLatLng =
                  LatLng(currentPosition.latitude, currentPosition.longitude);
              var pickupLatLng = widget.tripDetails.pickup;
              await getDirection(currentLatLng, pickupLatLng);

              getLocationUpdates();
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15.0,
                    spreadRadius: 0.5,
                    offset: Offset(
                      0.7,
                      0.7,
                    ),
                  )
                ],
              ),
              height: Platform.isIOS ? 280 : 255,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Duration: " + durationString,
                      style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: BrandColors.colorAccentPurple),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "${widget.tripDetails.riderName} On ${widget.tripDetails.riderPhone}",
                          style:
                          GoogleFonts.roboto(fontSize: 22),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(Icons.call),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Row(
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
                              widget.tripDetails.pickupAddress,
                              style: GoogleFonts.roboto(fontSize: 18),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
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
                              widget.tripDetails.destinationAddress,
                              style: GoogleFonts.roboto(fontSize: 18),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    TaxiButton(
                      title: buttonTitle,
                      color: buttonColor,
                      onPress: () async {
                        if (status == 'init') {

                          status = 'accepted';
                          rideRef.child('status').set(('arrived'));

                          setState(() {
                            buttonTitle = 'ARRIVED';
                            buttonColor = BrandColors.colorAccentPurple;
                          });
                          print("LatLng pos.longitude ${currentPosition.longitude}");
                          print("LatLng pos.latitude ${currentPosition.latitude}");
                          var driverLocation =  LatLng(currentPosition.latitude,currentPosition.longitude);
                          _launchMapsUrl(driverLocation,widget.tripDetails.pickup);

                        }
                        else if (status == 'accepted') {

                          status = 'arrived';
                          rideRef.child('status').set(('arrived'));

                          setState(() {
                            buttonTitle = 'START TRIP';
                            buttonColor = BrandColors.colorAccentPurple;
                          });

                          //Becouse this async we show a progress dialog for user to wai
                          HelperMethods.showProgressDialog(context);

                          await getDirection(widget.tripDetails.pickup,
                              widget.tripDetails.destination);

                          Navigator.pop(context);



                        } else if (status == 'arrived') {

                          _launchMapsUrl(widget.tripDetails.pickup,widget.tripDetails.destination);

                          status = 'ontrip';
                          //Update the firebase status
                          rideRef.child('status').set('ontrip');

                          setState(() {
                            buttonTitle = 'END TRIP';
                            buttonColor = Colors.red[900];
                          });

                          //To count how many minutes spend on a trip
                          startTimer();
                        } else if (status == 'ontrip') {
                          endTrip();
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void acceptTrip() {
    String rideID = widget.tripDetails.rideID;
    rideRef =
        FirebaseDatabase.instance.reference().child('rideRequest/$rideID');

    rideRef.child('status').set('accepted');
    rideRef.child('driver_name').set(currentDriverInfo.fullName);
    rideRef
        .child('car_details')
        .set('${currentDriverInfo.carColor} - ${currentDriverInfo.carModel}');
    rideRef.child('driver_phone').set(currentDriverInfo.phone);
    rideRef.child('driver_id').set(currentDriverInfo.id);

    Map locationMap = {
      'latitude': currentPosition.latitude.toString(),
      'longitude': currentPosition.longitude.toString(),
    };

    rideRef.child('driver_location').set(locationMap);

    DatabaseReference historyRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebaseUser.uid}/history/$rideID');
    historyRef.set(true);


  }

  void updateTripDetails() async {
    print('Inside : updateTripDetails');

    //this if statement will track another trip reqest is on the line if so will skip this entire process
    if (!isRequestingDirection) {
      LatLng destinationLatLng;
      isRequestingDirection = true;

      if (myPosition == null) {
        return;
      }

      var positionLatLng = LatLng(myPosition.latitude, myPosition.longitude);

      if (status == 'accepted') {
        /*
        * This means we arrived the pickup location
        * */
        destinationLatLng = widget.tripDetails.pickup;
      } else {
        destinationLatLng = widget.tripDetails.destination;
      }

      //This is awaitable for to await till directiond details came back from firestore
      var directionDetails = await HelperMethods.getDirectionDetails(
          positionLatLng, destinationLatLng);

      if (directionDetails != null) {
        print(directionDetails.durationText);

        setState(() {
          //This will update the duration to go in the screen with direction details realtime
          durationString = 'you have to go: ${directionDetails.durationText}';
        });
      } else {
        print('Direction Details are empty');
      }
      isRequestingDirection = false;
    }
  }

  Future<void> getDirection(
      LatLng pickupLatLng, LatLng destinationLatLng) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              status: 'Please wait...',
            ));

    var thisDetails = await HelperMethods.getDirectionDetails(
        pickupLatLng, destinationLatLng);

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
        polylinePoints.decodePolyline(thisDetails.encodedPoints);

    polylineCoordinates.clear();
    if (results.isNotEmpty) {
      // loop through all PointLatLng points and convert them
      // to a list of LatLng, required by the Polyline
      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    _polyLines.clear();

    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyid'),
        color: Color.fromARGB(255, 95, 109, 237),
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      _polyLines.add(polyline);
    });

    // make polyline to fit into the map

    LatLngBounds bounds;

    if (pickupLatLng.latitude > destinationLatLng.latitude &&
        pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds =
          LatLngBounds(southwest: destinationLatLng, northeast: pickupLatLng);
    } else if (pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickupLatLng.latitude, destinationLatLng.longitude),
          northeast:
              LatLng(destinationLatLng.latitude, pickupLatLng.longitude));
    } else if (pickupLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, pickupLatLng.longitude),
        northeast: LatLng(pickupLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      bounds =
          LatLngBounds(southwest: pickupLatLng, northeast: destinationLatLng);
    }

    rideMapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickupLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      _markers.add(pickupMarker);
      _markers.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
      circleId: CircleId('pickup'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 12,
      center: pickupLatLng,
      fillColor: BrandColors.colorGreen,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId('destination'),
      strokeColor: BrandColors.colorAccentPurple,
      strokeWidth: 3,
      radius: 12,
      center: destinationLatLng,
      fillColor: BrandColors.colorAccentPurple,
    );

    setState(() {
      _circles.add(pickupCircle);
      _circles.add(destinationCircle);
    });
  }

  void startTimer() {
    const interval = Duration(seconds: 1);
    timer = Timer.periodic(interval, (timer) {
      durationCounter++;
    });
  }

  void endTrip() async {
    timer.cancel();

    HelperMethods.showProgressDialog(context);

    var currentLatLng = LatLng(myPosition.latitude, myPosition.longitude);

    var directionDetails = await HelperMethods.getDirectionDetails(
        widget.tripDetails.pickup, currentLatLng);

    Navigator.pop(context);

    int fares = HelperMethods.estimateFares(directionDetails, durationCounter);

    rideRef.child('fares').set(fares.toString());

    rideRef.child('status').set('ended');

    ridePositionStream.cancel();

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CollectPayment(
              paymentMethod: widget.tripDetails.paymentMethod,
              fares: fares,
            ));

    topUpEarnings(fares);
  }

  void topUpEarnings(int fares) {
    DatabaseReference earningsRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebaseUser.uid}/earnings');
    earningsRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        double oldEarnings = double.parse(snapshot.value.toString());

        double adjustedEarnings = (fares.toDouble() * 0.85) + oldEarnings;

        earningsRef.set(adjustedEarnings.toStringAsFixed(2));
      } else {
        double adjustedEarnings = (fares.toDouble() * 0.85);
        earningsRef.set(adjustedEarnings.toStringAsFixed(2));
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
