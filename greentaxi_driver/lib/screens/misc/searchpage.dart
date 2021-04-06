import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/brand_colors.dart';
import 'package:greentaxi_driver/dataprovider/appdata.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/helpers/requestHelper.dart';
import 'package:greentaxi_driver/models/address.dart';
import 'package:greentaxi_driver/models/predictions.dart';
import 'package:greentaxi_driver/models/searchmodels.dart';
import 'package:greentaxi_driver/screens/misc/selectlocationonmap.dart';
import 'package:greentaxi_driver/shared/repository/firebase_service.dart';
import 'package:greentaxi_driver/styles/styles.dart';
import 'package:greentaxi_driver/widgets/BrandDivider.dart';
import 'package:greentaxi_driver/widgets/ProgressDialog.dart';
import 'package:greentaxi_driver/widgets/predictiontile.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:greentaxi_driver/globalvariables.dart' as globalsx;

class SearchPage extends StatefulWidget {
  static const String Id = 'SearchPage';
  final bool isPickUpSearch;
  final String customerID;
  //SearchPage({Key key},) : super(key: key);
  SearchPage(this.isPickUpSearch,this.customerID);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  var pickupCOntroller = TextEditingController();
  var destinationCOntroller = TextEditingController();

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  FocusNode myFocusNode;
  var focusDestination = FocusNode();
  bool focused = false;
  Address pickupAddress = Address();
  Address dropAddress = Address();
  List<Prediction> destinationPredictionList = [];

  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }


  void registerUser() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Creating customer.....',
      ),
    );

    var pickup =  Provider.of<AppData>(context, listen: false).pickupAdrress;
    var destin =  Provider.of<AppData>(context,listen: false).destinationAdrress;

    try {
      Map pickupMap = {
        'placeName': pickup.placeName,
        'placeFormatAddress': pickup.placeFormatAddress,
        'placeId': pickup.placeId,
        'latitude': pickup.latitude,
        'logitude': pickup.logitude,
        'datetime': DateTime.now().toString(),
      };

    Map destinMap = {
    'placeName': destin.placeName,
    'placeFormatAddress': destin.placeFormatAddress,
    'placeId': destin.placeId,
    'latitude': destin.latitude,
    'logitude': destin.logitude,
    'datetime': DateTime.now().toString(),
    };

    Map fullMap = {
    'customerID': widget.customerID,
    'pickupDetails': pickupMap,
    'destinDetails': destinMap,
    };


      DatabaseReference listUsers = FirebaseDatabase.instance
          .reference()
          .child('listTree/tripList/${widget.customerID}').push();
      listUsers.set(fullMap);
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      //Navigator.pop(context);
      if (e.code == 'weak-password') {
        showSnackBar('Oops! The password provided is too weak.');
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showSnackBar('Oops! The account already exists for that email.');
        print('The account already exists for that email.');
      }
    } catch (e) {
      //Navigator.pop(context);
      print(e);
      showSnackBar('Oops! There is a problem! Try again later.');
    }

    Navigator.pop(context);
  }

  void setFocus() {
    if (!focused) {
      FocusScope.of(context).requestFocus(focusDestination);
      focused = true;
    }
  }


  void searchPlaces(String placeName) async {
    if (placeName == null) {
      return;
    }
    if (placeName.length > 1) {
      String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=${globalsx.ApiKey}&sessiontoken=123254251&components=country:' +
              operatingCountry;
      var response = await RequestHelper.getRequest(url);
      if (response == 'failed') {
        return;
      }

      if (response['status'] == 'OK') {
        var predictionJson = response['predictions'];
        var thisList = (predictionJson as List)
            .map((e) => Prediction.fromJson(e))
            .toList();
        setState(() {
          destinationPredictionList = thisList;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
    myFocusNode.requestFocus();


  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    setFocus();


    return Scaffold(
      key: scaffoldKey,
      body: Column(
        children: <Widget>[
          Container(
            height: 220,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFcffffff),
                    Color(0xFFffffff),
                    Color(0xFFffffff),
                    Color(0xFFffffff),
                  ],
                  stops: [0.1, 0.4, 0.7, 0.9],
                ),
                boxShadow: [
                  BoxShadow(
                      color: Color(0xFFfbc02d),
                      blurRadius: 4.0,
                      spreadRadius: 0,
                      offset: Offset(0.4, 0.4))
                ]),
            child: Padding(
              padding:
                  EdgeInsets.only(left: 25, top: 20, right: 25, bottom: 5),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 2),
                  Row(
                    children: <Widget>[
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.arrow_back)
                      ),
                      SizedBox(width: 20,),
                      Expanded(
                        child:Text(
                          'Add Trips',
                          style: f_font_20_Bold_Black100,
                        ),
                      ),
                      ButtonTheme(
                        minWidth: 30,
                        height: 30.0,
                        child: RaisedButton(
                          color: Color(0xfff57f17),
                          textColor: Colors.white,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(15)
                          ),
                          child: Container(height: 18, child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.add,size: 20,),
                              Text("Add Trips", style: GoogleFonts.roboto(fontSize: 15 , fontWeight: FontWeight.bold),),
                            ],
                          )),
                          onPressed: () async{
                            registerUser();
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  BrandDivider(),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Icon(
                              Icons.circle,
                              color: Color(0xfff57f17),
                            ),
                            SizedBox(
                              height: 12,
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
                            SizedBox(
                              width: 300.0,
                              child: Text(
                                Provider.of<AppData>(context).pickupAdrress != null ? Provider.of<AppData>(context).pickupAdrress.placeName : 'Pickup Location',
                                style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFF00001f)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                              ),
                            ),
                            new SizedBox(
                              height: 19.0,
                            ),
                            SizedBox(
                              width: 300.0,
                              child: Text(
                                Provider.of<AppData>(context).destinationAdrress != null ? Provider.of<AppData>(context).destinationAdrress.placeName : 'Drop Location',
                                style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFF00001f)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                              ),
                            ),

                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children:<Widget> [
                      Expanded(child: _buildDropTF()),
                      SizedBox(width: 6,),
                      ButtonTheme(
                        minWidth: 30,
                        height: 30.0,
                        child: RaisedButton(
                          color: Color(0xfff57f17),
                          textColor: Colors.white,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(15)
                          ),
                          child: Container(height: 18, child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.location_on_outlined,size: 20,),
                              Text("Point on Map", style: GoogleFonts.roboto(fontSize: 15 , fontWeight: FontWeight.bold),),
                            ],
                          )),
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SelectLocationOnMap(isPickUpSearch: widget.isPickUpSearch,)),
                            );
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          (destinationPredictionList.length > 0)
              ? Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 22),
                  child: SingleChildScrollView(
                    child: ListView.separated(
                      padding: EdgeInsets.all(0),
                      itemBuilder: (context, index) {
                        return LocationPredictionTile(
                          prediction: destinationPredictionList[index],isPickUpSearch: widget.isPickUpSearch ,
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          BrandDivider(),
                      itemCount: destinationPredictionList.length,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                    ),
                  ),
                )
              : Container(
                ),
        ],
      ),
    );
  }




 //#region ************ Widget _buildDropTF() ***************
  Widget _buildDropTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 4.0),
          Container(
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: Color(0xfff57f17),
              borderRadius: BorderRadius.circular(10.0),
              border:Border.all(color: Colors.white,width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 6.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            height: 40.0,
            child: TextField(
              autofocus: true,
              focusNode: myFocusNode,
              onChanged: (value) {
                searchPlaces(value);
              },
              style: GoogleFonts.roboto(
                color: Colors.white,
                  fontWeight: FontWeight.bold
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 4.0),
                prefixIcon: Icon(
                  Icons.pin_drop,
                  color: Colors.white,
                ),
                hintText: 'Where to.',
                hintStyle: GoogleFonts.roboto(
                  color: Colors.white54,
                ),
              ),
            ),
          ),
      ],
    );
  }
//#endregion

}
