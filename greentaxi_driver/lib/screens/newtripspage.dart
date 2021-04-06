import 'dart:async';
import 'dart:math';
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
import 'package:greentaxi_driver/models/dateWiseSummary.dart';
import 'package:greentaxi_driver/models/directionDetails.dart';
import 'package:greentaxi_driver/models/paymenthistory.dart';
import 'package:greentaxi_driver/models/tripdetails.dart';
import 'package:greentaxi_driver/shared/repository/sales_service.dart';
import 'package:greentaxi_driver/widgets/BrandDivider.dart';
import 'package:greentaxi_driver/widgets/CollectPaymentDialog.dart';
import 'package:greentaxi_driver/widgets/ProgressDialog.dart';
import 'package:greentaxi_driver/widgets/TaxiButton.dart';
import 'package:url_launcher/url_launcher.dart';

class NewTripPage extends StatefulWidget {
  static const String Id = 'newtrippage';
  final TripDetails tripDetails;
  final bool restartRide;
  NewTripPage({this.tripDetails, this.restartRide});
  @override
  _NewTripPageState createState() => _NewTripPageState();
}

enum DistanceType { Miles, Kilometers }

class _NewTripPageState extends State<NewTripPage> {
  GoogleMapController rideMapController;
  Completer<GoogleMapController> _controller = Completer();
  double mapPaddingBottom = 0;

  Set<Marker> _markers = Set<Marker>();
  Set<Circle> _circles = Set<Circle>();
  Set<Polyline> _polyLines = Set<Polyline>();

  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  bool serviceEnabled;
  LocationPermission permission;

  var geoLocator = Geolocator();
  var locationOptions = LocationOptions(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 1,
      timeInterval: 1);

  BitmapDescriptor movingMarkerIcon;
  Position myPosition;
  String status = 'init';
  String durationString = '0';
  String DistanceString = '0';
  bool isRequestingDirection = false;
  String buttonTitle = 'Drive to Customer';
  Color buttonColor = Color(0xFFff7043);
  Timer timer;
  int durationCounter = 0;
  var timeBaseDistance = 0.0;
  String TimeSpent = "0:0";

  double cumDistance = 0;
  double cumDistanceGro = 0;
  var latitudex = "";
  var longitudex = "";
  var speedx = "";
  var timestampx = "";
  var accuracyx = "0";
  var distancex = "";
  var oldPositionLatlng;
  var oldTime;

  String GetTimeString(DateTime dateTime) {
    return dateTime.hour.toString() +
        ":" +
        dateTime.minute.toString() +
        ":" +
        dateTime.second.toString() +
        ":" +
        dateTime.microsecond.toString();
  }

  double CalDistance(Position pos1, Position pos2, DistanceType type) {
    double R = (type == DistanceType.Miles) ? 3960 : 6371;
    double dLat = this.toRadian(pos2.latitude - pos1.latitude);
    double dLon = this.toRadian(pos2.longitude - pos1.longitude);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(this.toRadian(pos1.latitude)) *
            cos(this.toRadian(pos2.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * asin(min(1, sqrt(a)));
    double d = R * c;
    return d;
  }

  double toRadian(double val) {
    return (pi / 180) * val;
  }

  /*
    * The technology behind this is that if the map kit will calculate the rotations according to the given lat langs . so if we give lat langs too far away
    * this calculation will not give us a correct heading direction. so fo that we use old position just before we been and set it in to
    *  -- oldPosition
    * Variable. so oldPosition always contain before position that we was and that was so short. so the heading will be calculated as the lat lng changes
    * */
  void getLocationUpdates() {
    LatLng oldPosition = LatLng(0, 0);

    ridePositionStream = Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.best, distanceFilter: 1)
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

        var loc = position;
        latitudex = loc.latitude.toString();
        longitudex = loc.longitude.toString();
        speedx = loc.speed.toString();
        timestampx = GetTimeString(loc.timestamp);
        accuracyx = loc.accuracy.toString();
      });

      ///Mechanical GPS Calculations
      if (oldPositionLatlng != null) {
        var distance =
            CalDistance(position, oldPositionLatlng, DistanceType.Kilometers);
        cumDistance += distance;
        distancex = distance.toStringAsFixed(2);
        var geoLocatorDistance = Geolocator.distanceBetween(
            oldPosition.latitude,
            oldPosition.longitude,
            position.latitude,
            position.longitude);
        geoLocatorDistance = geoLocatorDistance / 1000;
        cumDistanceGro += geoLocatorDistance;
        print(
            "Stats: ${position.latitude.toString()} |${position.longitude.toString()} |${oldPosition.latitude.toString()} |${oldPosition.longitude.toString()}|    $distancex | ${cumDistance.toStringAsFixed(4)} | ${geoLocatorDistance.toStringAsFixed(4)}| $accuracyx| $timestampx ");
      }

      /*
      This will always update our current positions to old position so we can calculate the Rotation of the Marker
      * */
      oldTime = position.timestamp;
      oldPositionLatlng = position;
      oldPosition = pos;
      updateTripDetails();
      Map locationMap = {
        'latitude': myPosition.latitude.toString(),
        'longitude': myPosition.longitude.toString(),
      };
      print("Updating driver_location $locationMap");

      rideRef = FirebaseDatabase.instance
          .reference()
          .child("rideRequest/${widget.tripDetails.rideID}");
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
    //print("NewTripPage  tripDetails ${tripDetails.rideID}");
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
                mapPaddingBottom = (Platform.isIOS) ? 255 : 290;
              });

              var currentLatLng =
                  LatLng(currentPosition.latitude, currentPosition.longitude);
              var pickupLatLng = widget.tripDetails.pickup;
              await getDirection(currentLatLng, pickupLatLng);
              print('my rotation getLocationUpdates()');
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
              height: Platform.isIOS ? 280 : 300,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "${widget.tripDetails.riderName.toUpperCase()}",
                          style: GoogleFonts.roboto(
                              fontSize: 20,
                              color: Color(0xFFe65100),
                              fontWeight: FontWeight.bold),
                        ),

                      ],
                    ),
                    Text(
                      "${widget.tripDetails.riderPhone}",
                      style: GoogleFonts.roboto(fontSize: 15,color: Color(0xAAe65100)),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    BrandDivider(),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Icon(
                              Icons.circle,
                              color: Color(0xfff57f17),
                            ),
                            SizedBox(
                              height: 7,
                            ),
                            Icon(
                              Icons.circle,
                              color: Color(0xff0277bd),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              '${widget.tripDetails.pickupAddress}',
                              style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF00001f)),
                            ),
                            new SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              '${widget.tripDetails.destinationAddress}',
                              style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF00001f)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    BrandDivider(),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              launch("tel://${widget.tripDetails.riderPhone}");
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular((25))),
                                    border: Border.all(
                                        width: 2.0, color: Color(0xFFef6c00)),
                                  ),
                                  child: Icon(Icons.call,
                                      color: Color(0xFFef6c00)),
                                ),
                                Text(
                                  "Call",
                                  style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: Color(0xFFef6c00),
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if(status == 'init' || status == 'init'){
                                var driverLocation = LatLng(currentPosition.latitude,
                                    currentPosition.longitude);
                                _launchMapsUrl(
                                    driverLocation, widget.tripDetails.pickup);
                              }
                              if(status == 'arrived' || status == 'ontrip'){
                                _launchMapsUrl(widget.tripDetails.pickup,
                                    widget.tripDetails.destination);
                              }
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular((25))),
                                    border: Border.all(
                                        width: 2.0, color: Color(0xFFef6c00)),
                                  ),
                                  child: Icon(Icons.navigation_outlined,
                                      color: Color(0xFFef6c00)),
                                ),
                                Text(
                                  "Navigation",
                                  style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: Color(0xFFef6c00),
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              launch("tel://${widget.tripDetails.riderPhone}");
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular((25))),
                                    border: Border.all(
                                        width: 2.0, color: Color(0xFFef6c00)),
                                  ),
                                  child: Icon(Icons.chat,
                                      color: Color(0xFFef6c00)),
                                ),
                                Text(
                                  "Chat",
                                  style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: Color(0xFFef6c00),
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              launch("tel://${widget.tripDetails.riderPhone}");
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular((25))),
                                    border: Border.all(
                                        width: 2.0, color: Color(0xFFef6c00)),
                                  ),
                                  child: Icon(Icons.report_gmailerrorred_outlined,
                                      color: Color(0xFFef6c00)),
                                ),
                                Text(
                                  "Report",
                                  style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: Color(0xFFef6c00),
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    BrandDivider(),
                    SizedBox(
                      height: 10,
                    ),
                    TaxiButton(
                      title: buttonTitle,
                      color: buttonColor,
                      onPress: () async {
                        rideRef = FirebaseDatabase.instance
                            .reference()
                            .child("rideRequest/${widget.tripDetails.rideID}");
                        print(
                            "onPress status $status");

                        if (status == 'init') {
                          status = 'accepted';
                          rideRef.child('status').set(('accepted'));

                          setState(() {
                            buttonTitle = 'ARRIVED';
                            buttonColor = Color(0xFFf4511e);
                          });
                          print(
                              "LatLng pos.longitude ${currentPosition.longitude}");
                          print(
                              "LatLng pos.latitude ${currentPosition.latitude}");
                          var driverLocation = LatLng(currentPosition.latitude,
                              currentPosition.longitude);
                          _launchMapsUrl(
                              driverLocation, widget.tripDetails.pickup);
                        }

                        else if (status == 'accepted') {
                          status = 'arrived';
                          rideRef.child('status').set(('arrived'));

                          setState(() {
                            buttonTitle = 'START TRIP';
                            buttonColor = Color(0xFF263238);
                          });
                          HelperMethods.showProgressDialog(context);
                          await getDirection(widget.tripDetails.pickup,
                              widget.tripDetails.destination);
                          Navigator.pop(context);
                        }

                        else if (status == 'arrived') {
                          _launchMapsUrl(widget.tripDetails.pickup,
                              widget.tripDetails.destination);

                          status = 'ontrip';
                          //Update the firebase status
                          rideRef.child('status').set('ontrip');
                          TimeSpent = "0.00";

                          setState(() {
                            cumDistance = 0.0;
                            distancex = "0.00";
                            cumDistanceGro = 0.0;
                            buttonTitle = 'END TRIP';
                            buttonColor = Color(0xFF263238);
                          });

                          //To count how many minutes spend on a trip
                          startTimer();
                        }
                        else if (status == 'ontrip') {
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

  static void showToast(BuildContext context, String text) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text("Contact administrator ERR:  $text"),
        action: SnackBarAction(
            label: 'Hide', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  void acceptTrip() async {
    print("Inside acceptTrip");
    paymentDetails = PaymentDetails();
    if (widget.tripDetails != null) {
      if (currentDriverInfo != null) {
        print("Inside acceptTrip");
        String rideID = widget.tripDetails.rideID;
        rideRef =
            FirebaseDatabase.instance.reference().child('rideRequest/$rideID');

        ///Setting variables that not setted when ride request created
        rideRef.child('driver_phone').set(currentDriverInfo.phone);

        ///Drivers location may change now so we update drivers current to riderequest obejct
        Map locationMap = {
          'latitude': currentPosition.latitude.toString(),
          'longitude': currentPosition.longitude.toString(),
        };
        rideRef.child('driver_location').set(locationMap);

        //rideRef.child('status').set('accepted');
       // rideRef.child('driver_name').set(currentDriverInfo.fullName);
        //rideRef.child('car_details').set(
            //${currentDriverInfo.carColor} - ${currentDriverInfo.carModel}');
        //rideRef.child('driver_id').set(currentDriverInfo.id);
        //  need to maintain NewTrip field so we can track what is the user status at
        // 	a given time
        // rideRef = FirebaseDatabase.instance
        //     .reference()
        //     .child('drivers/${currentDriverInfo.id}/profile');
        // rideRef.child("rideId").set(rideID);
        //Setting payment Details
        // paymentDetails.pickupAddress = widget.tripDetails.pickupAddress;
        // paymentDetails.destinationAddress =
        //     widget.tripDetails.destinationAddress;
        // paymentDetails.rideID = widget.tripDetails.rideID;

        if (widget.restartRide) {
          print("widget.tripDetails.status  ${widget.tripDetails.status}");
          status = widget.tripDetails.status;
          if (status == 'accepted') {
            rideRef.child('status').set(('accepted'));
            setState(() {
              buttonTitle = 'ARRIVED';
              buttonColor = BrandColors.colorAccentPurple;
            });
            print(
                "LatLng pos.longitude ${currentPosition.longitude}");
            print(
                "LatLng pos.latitude ${currentPosition.latitude}");
            var driverLocation = LatLng(currentPosition.latitude,
                currentPosition.longitude);
            _launchMapsUrl(
                driverLocation, widget.tripDetails.pickup);
          }
          else if (status == 'arrived') {
            _launchMapsUrl(widget.tripDetails.pickup,
                widget.tripDetails.destination);

            status = 'arrived';
            TimeSpent = "0.00";

            setState(() {
              cumDistance = 0.0;
              distancex = "0.00";
              cumDistanceGro = 0.0;

              buttonTitle = 'ARRIVED';
              buttonColor = Colors.red[900];
            });

            //To count how many minutes spend on a trip
            startTimer();
          }
          else if (status == 'ontrip') {
            _launchMapsUrl(widget.tripDetails.pickup,
                widget.tripDetails.destination);

            status = 'ontrip';
            TimeSpent = "0.00";

            setState(() {
              cumDistance = 0.0;
              distancex = "0.00";
              cumDistanceGro = 0.0;
              buttonTitle = 'END TRIP';
              buttonColor = Colors.red[900];
            });

            //To count how many minutes spend on a trip
            startTimer();
          }

          //startTimer();
        }



      } else {
        showToast(context, "ERR_DR_002");
      }
    } else {
      showToast(context, "ERR_DR_001");
    }


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
          durationString = directionDetails.durationText;
          DistanceString = directionDetails.distanceText;
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
      setState(() {
        durationCounter++;
        //TimeSpent = ReturnTimeString(durationCounter);
      });
    });
  }

  String ReturnTimeString(int dimespent) {
    int seconds = dimespent % 60;
    double minutes = dimespent / 60;
    String time = minutes.round().toString() + ":" + seconds.toString();
    return time;
  }

  void endTrip() async {
    if (timer != null) {
      timer.cancel();
    }

    if (widget.tripDetails != null) {
      HelperMethods.showProgressDialog(context);

      if(myPosition == null){
        myPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      }


      var currentLatLng = LatLng(myPosition.latitude, myPosition.longitude);

      var directionDetails = await HelperMethods.getDirectionDetails(
          widget.tripDetails.pickup, currentLatLng);

      Navigator.pop(context);


      int fares = HelperMethods.estimateFares(
          directionDetails, VtypeConverter(currentVehicleInfomation.vehicleType), widget.tripDetails);

      rideRef.child('fares').set(fares.toString());

      rideRef.child('status').set('ended');

      ridePositionStream.cancel();

      /// after ending ride the drivers newtrip status must set to waiting
      rideRef = FirebaseDatabase.instance
          .reference()
          .child('drivers/${currentDriverInfo.id}/profile');
      rideRef.child("newtrip").set("waiting");

      rideRef = FirebaseDatabase.instance
          .reference()
          .child('drivers/${currentDriverInfo.id}/profile');
      rideRef.child("rideId").set("");

      rideRef = FirebaseDatabase.instance
          .reference()
          .child('drivers/${currentDriverInfo.id}/profile');
      rideRef.child("inMiddleOfTrip").set("false");

      ///This will cumilatly increment the earnings of the driver
      topUpEarnings(fares);

      ///Saving the Trip history
      driverTripHistory(widget.tripDetails, fares, directionDetails);

      ///Saving the Payment Details
      driverPaymentHistory(widget.tripDetails, directionDetails);

      // ///Update Cash Flows
      // updateCashFlows(widget.tripDetails);

      print("Came point 1");

      
      

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => CollectPayment(
                paymentMethod: widget.tripDetails.paymentMethod,
                fares: fares,
              ));
    } else {
      showToast(context, "ERR_DR_005");
    }
  }

  void updateCashFlows(TripDetails tripDetailsx) {
    DatabaseReference earningsRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebaseUser.uid}/cashflows/cr');
    earningsRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        ///Top up credit value is one avaiblable
        double oldEarnings = double.parse(snapshot.value.toString());
        double adjustedEarnings =
            (paymentDetails.companyPayable.toDouble()) + oldEarnings;
        earningsRef.set(adjustedEarnings.toStringAsFixed(2));
      } else {
        ///Create new value if not available
        double adjustedEarnings = (paymentDetails.companyPayable.toDouble());
        earningsRef.set(adjustedEarnings.toStringAsFixed(2));
      }
    });
  }

  void driverTripHistory(
  
      TripDetails tripDetails, int fare, DirectionDetails directionDetails) {
    if (tripDetails != null) {
      print("inside driverTripHistory $currentFirebaseUser.uid");
      DatabaseReference earningsRef = FirebaseDatabase.instance.reference().child(
          'drivers/${currentFirebaseUser.uid}/tripHistory/${tripDetails.rideID}');

      Map pickupMap = {
        'latitude': tripDetails.pickup.latitude.toString(),
        'longitude': tripDetails.pickup.longitude.toString(),
      };
      Map destinationMap = {
        'latitude': tripDetails.destination.latitude.toString(),
        'longitude': tripDetails.destination.longitude.toString(),
      };

      Map directionMap = {
        'distanceText': directionDetails.distanceText.toString(),
        'distanceValue': directionDetails.distanceValue.toString(),
        'durationValue': directionDetails.durationValue.toString(),
        'durationText': directionDetails.durationText.toString(),
      };

      Map historyMap = {
        "rideID": tripDetails.rideID,
        "pickup": pickupMap,
        "destination": destinationMap,
        "directionDetails": directionMap,
        "pickupAddress": tripDetails.pickupAddress,
        "destinationAddress": tripDetails.destinationAddress,
        "fare": fare,
        "date": DateTime.now().toString()
      };
      earningsRef.set(historyMap);
    } else {
      showToast(context, "ERR_DR_004");
    }
  }

  void driverPaymentHistory(
      TripDetails tripDetailsx, DirectionDetails directionDetails) async {
    print("inside driverTripHistory $currentFirebaseUser.uid");
    DatabaseReference earningsRef = FirebaseDatabase.instance.reference().child(
        'drivers/${currentFirebaseUser.uid}/paymentHistory/${tripDetailsx.rideID}');
    
    Map directionMap = {
      'distanceText': directionDetails.distanceText.toString(),
      'distanceValue': directionDetails.distanceValue.toString(),
      'durationValue': directionDetails.durationValue.toString(),
      'durationText': directionDetails.durationText.toString(),
    };

    Map paymentHistoryMap = {
      "rideID": paymentDetails.rideID,
      "commission": paymentDetails.commission,
      "commissionApplicable": paymentDetails.commissionApplicable,
      "companyPayable": paymentDetails.companyPayable,
      "totalFare": paymentDetails.totalFare,
      "appPrice": paymentDetails.appPrice,
      "kmPrice": paymentDetails.kmPrice,
      "timePrice": paymentDetails.timePrice,
      "destinationAddress": paymentDetails.destinationAddress,
      "pickupAddress": paymentDetails.pickupAddress,
      "date": DateTime.now().toString(),
      "directionDetails": directionMap
    };
    earningsRef.set(paymentHistoryMap);

    var summary = DateWiseSummary(paymentDetails.commission,
        paymentDetails.kmPrice + paymentDetails.timePrice,
        directionDetails.distanceValue/1000,
        0,
        paymentDetails.kmPrice,
        paymentDetails.totalFare,
        paymentDetails.timePrice
        );
    await SalesService.updatedateWiseSummary(summary);

    var cf = CashFlows( paymentDetails.companyPayable, 0);
    await SalesService.updateCashFlows(cf);

    // await SalesService.updateEarningOnly(paymentDetails.kmPrice + paymentDetails.timePrice);
    // if(paymentDetails.commissionApplicable){
    //   await SalesService.updateCommissionOnly(paymentDetails.commission);
    // }
    // await SalesService.updateKMs(directionDetails.distanceValue/1000);
    // await SalesService.updateKMs(directionDetails.durationValue/60);


  }

  void topUpEarnings(int fares) {
    DatabaseReference earningsRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebaseUser.uid}/profile/earnings');
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

  void _launchMapsUrl(LatLng _originLatLng, LatLng _destinationLatLng) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&origin=${_originLatLng.latitude},${_originLatLng.longitude}&destination=${_destinationLatLng.latitude},${_destinationLatLng.longitude}&travelmode=driving';
    if (await canLaunch(url)) {
      print("Launching map.... $url");
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
