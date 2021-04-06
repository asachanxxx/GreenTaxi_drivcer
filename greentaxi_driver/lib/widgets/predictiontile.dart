import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/brand_colors.dart';
import 'package:greentaxi_driver/dataprovider/appdata.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/helpers/requestHelper.dart';
import 'package:greentaxi_driver/models/address.dart';
import 'package:greentaxi_driver/models/customer.dart';
import 'package:greentaxi_driver/models/predictions.dart';
import 'package:greentaxi_driver/models/searchmodels.dart';
import 'package:greentaxi_driver/screens/misc/customertrips.dart';
import 'package:greentaxi_driver/shared/repository/firebase_service.dart';
import 'file:///I:/TaxiApp/GIT/GreenTaxi_Driver/GreenTaxi_drivcer/greentaxi_driver/lib/screens/misc/customerfunctions.dart';
import 'package:greentaxi_driver/styles/styles.dart';
import 'package:greentaxi_driver/widgets/ProgressDialog.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';


class LocationSearchTile extends StatelessWidget {

  final SearchHistory searchHistory;
  final bool isPickUpSearch;
  LocationSearchTile({this.searchHistory,this.isPickUpSearch});

  void getPlaceDetails(String placeId , context) async {
    print('PredictionTile->getPlaceDetails-> placeId :' + placeId);
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      return;
    }
    var url = 'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=$ApiKey';
    var response = await RequestHelper.getRequest(url);
    if (response == null) {
      return;
    }
    if (response['status'] == 'OK') {
      Address thisplace = Address();
      thisplace.placeId = placeId;
      thisplace.placeName = response['result']['name'];
      thisplace.placeFormatAddress = response['result']['formatted_address'];
      thisplace.latitude = response['result']['geometry']['location']['lat'];
      thisplace.logitude = response['result']['geometry']['location']['lng'];

      Provider.of<AppData>(context, listen: false).updateDestinationAdrress(
          thisplace);
      print('thisplace.placeFormatAddress ,latitude:- ' +
          thisplace.placeFormatAddress + " latitude " +
          thisplace.latitude.toString() + "  logitude  " +
          thisplace.logitude.toString());
      print('PredictionTile -> getPlaceDetails ${isPickUpSearch.toString()}');

      if (isPickUpSearch) {
        Navigator.pop(context, thisplace);
      } else {
        Navigator.pop(context, 'getDirection');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(0),
      onPressed: (){
        getPlaceDetails(searchHistory.placeId, context);
      },
      child: Container(
        child: Column(
          children: <Widget>[
            SizedBox(height: 8,),
            Row(
              children:<Widget> [
                Icon(OMIcons.accessTime,color: BrandColors.colorDimText,),
                SizedBox(width:12 ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:<Widget> [
                      Text(searchHistory.name,overflow: TextOverflow.ellipsis,maxLines: 1, style: f_font_15_Normal_Black100,),
                      SizedBox(height: 2,),
                      Text(searchHistory.displayName,overflow: TextOverflow.ellipsis,maxLines: 1, style:f_font_12_Bold_Dim)
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 8,),
          ],
        ),
      ),
    );
  }
}

class LocationPredictionTile extends StatelessWidget {

  final Prediction prediction;
  final bool isPickUpSearch;
  LocationPredictionTile({this.prediction,this.isPickUpSearch});

  Future<Address> getPlaceDetails(String placeId , context) async {
    Address thisplace = Address();

    showDialog(context: context, barrierDismissible: false,
        builder: (BuildContext context) =>
            ProgressDialog(status: "Please wait...",)
    );

    print('PredictionTile->getPlaceDetails-> placeId :' + placeId);
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      return Future.value(null);
    }
    var url = 'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=$ApiKey';
    var response = await RequestHelper.getRequest(url);

    Navigator.pop(context);

    if (response == null) {
      return Future.value(null);
    }
    if (response['status'] == 'OK') {

      thisplace.placeId = placeId;
      thisplace.placeName = response['result']['name'];
      thisplace.placeFormatAddress = response['result']['formatted_address'];
      thisplace.latitude = response['result']['geometry']['location']['lat'];
      thisplace.logitude = response['result']['geometry']['location']['lng'];
    }

    return  thisplace;
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(0),
      onPressed: (){
        getPlaceDetails(prediction.placeId, context);
      },
      child: Container(
        child: Column(
          children: <Widget>[
            SizedBox(height: 2,),
            Row(
              children:<Widget> [
                Icon(OMIcons.locationOn,color: BrandColors.colorDimText,),
                SizedBox(width:12 ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:<Widget> [
                      Text(prediction.mainText,overflow: TextOverflow.ellipsis,maxLines: 1, style: f_font_15_Bold_Black100,),
                      SizedBox(height: 2,),
                      Text(prediction.secondaryText,overflow: TextOverflow.ellipsis,maxLines: 1, style:f_font_12_Bold_Dim),
                      Row(
                        children:<Widget> [
                          Expanded(
                            child: ButtonTheme(
                              minWidth: 100,
                              height: 25.0,
                              child: RaisedButton(
                                color: Color(0xfff5f5f5),
                                textColor:Color(0xfff57f17) ,
                                shape: new RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(15)
                                ),
                                child: Container(height: 12, child: Center(child: Text("Add to Pickup", style: GoogleFonts.roboto(fontSize: 12 , fontWeight: FontWeight.bold),))),
                                onPressed: () async{
                                  Address thisPlace = Address();
                                  thisPlace = await getPlaceDetails(prediction.placeId, context);
                                  Provider.of<AppData>(context, listen: false).updatePickupAddress(
                                      thisPlace);
                                  print('On Pickup  ${thisPlace.placeName}');
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 5,),
                          Expanded(
                            child: ButtonTheme(
                              minWidth: 100,
                              height: 25.0,
                              child: RaisedButton(
                                color: Color(0xfff5f5f5),
                                textColor: Color(0xff0277bd),
                                shape: new RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(15)
                                ),
                                child: Container(height: 12, child: Center(child: Text("Add to Drop", style: GoogleFonts.roboto(fontSize: 12 , fontWeight: FontWeight.bold),))),
                                onPressed: () async{
                                  Address thisPlace = Address();
                                  thisPlace = await getPlaceDetails(prediction.placeId, context);
                                  Provider.of<AppData>(context, listen: false).updateDestinationAdrress(
                                      thisPlace);
                                  print('On Pickup  ${thisPlace.placeName}');
                                },
                              ),
                            ),

                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 4,),
          ],
        ),
      ),
    );
  }
}


class PredictionTile extends StatelessWidget {

  final Prediction prediction;
  PredictionTile({this.prediction});

  void getPlaceDetails(String placeId , context) async{
    print('PredictionTile->getPlaceDetails-> placeId :' + placeId);
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      return;
    }
    var url ='https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=AIzaSyBSixR5_gpaPVfXXIXV-bdDKW624mBrRqQ';

    var response = await RequestHelper.getRequest(url);

    //Navigator.pop(context);

    if(response == null){
      return;
    }

    if(response['status'] =='OK'){
      Address thisplace = Address();
      thisplace.placeId = placeId;
      thisplace.placeName = response['result']['name'];
      thisplace.placeFormatAddress = response['result']['formatted_address'];
      thisplace.latitude = response['result']['geometry']['location']['lat'];
      thisplace.logitude = response['result']['geometry']['location']['lng'];

      Provider.of<AppData>(context , listen: false).updateDestinationAdrress(thisplace);
      print('thisplace.placeFormatAddress ,latitude:- ' + thisplace.placeFormatAddress + " latitude " + thisplace.latitude.toString() + "  logitude  " + thisplace.logitude.toString() );
      Navigator.pop(context, 'getDirection');
    }

  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(0),
      onPressed: (){
        getPlaceDetails(prediction.placeId, context);
      },
      child: Container(
        child: Column(
          children: <Widget>[
            SizedBox(height: 8,),
            Row(
              children:<Widget> [
                Icon(OMIcons.locationOn,color: BrandColors.colorDimText,),
                SizedBox(width:12 ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:<Widget> [
                      Text(prediction.mainText,overflow: TextOverflow.ellipsis,maxLines: 1, style: f_font_15_Bold_Black100,),
                      SizedBox(height: 2,),
                      Text(prediction.secondaryText,overflow: TextOverflow.ellipsis,maxLines: 1, style:f_font_12_Bold_Dim)
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 8,),
          ],
        ),
      ),
    );
  }
}

class SearchTile extends StatelessWidget {

  final Customer searchHistory;
  final bool isPickUpSearch;
  SearchTile({this.searchHistory,this.isPickUpSearch});

  void getPlaceDetails(Customer customer , context) async {
    print('PredictionTile->customer : ${customer.CustomerID}');
    Navigator.pushNamedAndRemoveUntil(context, CustomerTrips.Id, (route) => false,arguments: customer );
  }


  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(0),
      onPressed: (){
        print("Customer on SearchTile $searchHistory");
        getPlaceDetails(searchHistory, context);
      },
      child: Container(
        color: Color(0xFFfafafa),
        child: Column(
          children: <Widget>[
            SizedBox(height: 8,),
            Row(
              children:<Widget> [
                SizedBox(width:12 ),
                Icon(Icons.account_circle_rounded,color: Color(0xFFff6f00),),
                SizedBox(width:12 ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:<Widget> [
                      Text(searchHistory.fullName,overflow: TextOverflow.ellipsis,maxLines: 1, style: GoogleFonts.roboto(fontSize: 15,fontWeight: FontWeight.normal ,color: Color(0xFF212121)),),
                      SizedBox(height: 5,),
                      Text(searchHistory.phoneNumber,overflow: TextOverflow.ellipsis,maxLines: 1, style:GoogleFonts.roboto(fontSize: 12,fontWeight: FontWeight.normal))
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_outlined, size: 15 , color: BrandColors.colorDimText,)
              ],
            ),
            SizedBox(height: 8,),
          ],
        ),
      ),
    );
  }
}


class SearchTile2 extends StatelessWidget {

  final Customer custommerObj;
  final bool isPickUpSearch;
  SearchTile2({this.custommerObj,this.isPickUpSearch});

  void getPlaceDetails(Customer customer , context) async {
    print('PredictionTile ${customer.CustomerID}');
    //print('PredictionTile->getPlaceDetails-> CustomerID : ${customer.CustomerID}');
    //Navigator.pushNamedAndRemoveUntil(context, CustomerTrips.Id, (route) => false, arguments: : customer.CustomerID );

    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => CustomerTrips(customerId:customer.CustomerID)
        )
    );
  }


  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(0),
      onPressed: (){
        getPlaceDetails(custommerObj, context);
      },
      child: Container(
        color: Color(0xFFfafafa),
        child: Column(
          children: <Widget>[
            SizedBox(height: 8,),
            Row(
              children:<Widget> [
                SizedBox(width:12 ),
                Icon(Icons.account_circle_rounded,color: Color(0xFFff6f00),),
                SizedBox(width:12 ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:<Widget> [
                      Text(custommerObj.fullName,overflow: TextOverflow.ellipsis,maxLines: 1, style: GoogleFonts.roboto(fontSize: 15,fontWeight: FontWeight.normal ,color: Color(0xFF212121)),),
                      SizedBox(height: 5,),
                      Text(custommerObj.phoneNumber,overflow: TextOverflow.ellipsis,maxLines: 1, style:GoogleFonts.roboto(fontSize: 12,fontWeight: FontWeight.normal))
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_outlined, size: 15 , color: BrandColors.colorDimText,)
              ],
            ),
            SizedBox(height: 8,),
          ],
        ),
      ),
    );
  }
}


class TripTile2 extends StatelessWidget {

  final Address pickupAdd;
  final Address dropAdd;
  TripTile2({this.pickupAdd,this.dropAdd});

  void getPlaceDetails(Address pickupAddPass , context) async {
    print('PredictionTile ${pickupAdd.placeFormatAddress}');
    //print('PredictionTile->getPlaceDetails-> CustomerID : ${customer.CustomerID}');
    //Navigator.pushNamedAndRemoveUntil(context, CustomerTrips.Id, (route) => false, arguments: : customer.CustomerID );

    // Navigator.push(context,
    //     MaterialPageRoute(
    //         builder: (context) => CustomerTrips(customerId:customer.CustomerID)
    //     )
    // );
  }


  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(0),
      onPressed: (){
        getPlaceDetails(pickupAdd, context);
      },
      child: Container(
        color: Color(0xFFfafafa),
        child: Column(
          children: <Widget>[
            SizedBox(height: 8,),
            Row(
              children:<Widget> [
                SizedBox(width:12 ),
                Icon(Icons.account_circle_rounded,color: Color(0xFFff6f00),),
                SizedBox(width:12 ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:<Widget> [
                      Text('${pickupAdd.placeName} To ${dropAdd.placeName}',overflow: TextOverflow.ellipsis,maxLines: 1, style: GoogleFonts.roboto(fontSize: 15,fontWeight: FontWeight.normal ,color: Color(0xFF212121)),),
                      SizedBox(height: 5,),
                      Text("Pickup: ${pickupAdd.placeFormatAddress} ,  Drop:  ${dropAdd.placeFormatAddress} ",overflow: TextOverflow.ellipsis,maxLines: 1, style:GoogleFonts.roboto(fontSize: 12,fontWeight: FontWeight.normal))
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_outlined, size: 15 , color: BrandColors.colorDimText,)
              ],
            ),
            SizedBox(height: 8,),
          ],
        ),
      ),
    );
  }
}

class TripTile3 extends StatelessWidget {

  final String  rideId;
  final String datetime;
  TripTile3({this.rideId,this.datetime});

  void getPlaceDetails(Address pickupAddPass , context) async {
    print('rideId ${rideId}');
    //print('PredictionTile->getPlaceDetails-> CustomerID : ${customer.CustomerID}');
    //Navigator.pushNamedAndRemoveUntil(context, CustomerTrips.Id, (route) => false, arguments: : customer.CustomerID );

    // Navigator.push(context,
    //     MaterialPageRoute(
    //         builder: (context) => CustomerTrips(customerId:customer.CustomerID)
    //     )
    // );
  }


  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(0),
      onPressed: (){
        //getPlaceDetails(pickupAdd, context);
      },
      child: Container(
        color: Color(0xFFfafafa),
        child: Column(
          children: <Widget>[
            SizedBox(height: 8,),
            Row(
              children:<Widget> [
                SizedBox(width:12 ),
                Icon(Icons.account_circle_rounded,color: Color(0xFFff6f00),),
                SizedBox(width:12 ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:<Widget> [
                      Text('$rideId',overflow: TextOverflow.ellipsis,maxLines: 1, style: GoogleFonts.roboto(fontSize: 15,fontWeight: FontWeight.normal ,color: Color(0xFF212121)),),
                      SizedBox(height: 5,),
                      Text("$datetime",overflow: TextOverflow.ellipsis,maxLines: 1, style:GoogleFonts.roboto(fontSize: 12,fontWeight: FontWeight.normal))
                    ],
                  ),
                ),
                FloatingActionButton(
                  heroTag: "btn2",
                  onPressed: () {


                  },
                  child:Icon(Icons.play_arrow) ,
                  backgroundColor:true ? Color(0xFFff6f00): Color(0xFF616161),
                ),
                SizedBox(width: 20,),

                Icon(Icons.arrow_forward_ios_outlined, size: 15 , color: BrandColors.colorDimText,)
              ],
            ),
            SizedBox(height: 8,),
          ],
        ),
      ),
    );
  }
}