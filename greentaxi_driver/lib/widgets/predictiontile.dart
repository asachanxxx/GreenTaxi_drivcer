import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:greentaxi_driver/brand_colors.dart';
import 'package:greentaxi_driver/dataprovider/appdata.dart';
import 'package:greentaxi_driver/helpers/requestHelper.dart';
import 'package:greentaxi_driver/models/address.dart';
import 'package:greentaxi_driver/models/predictions.dart';
import 'package:greentaxi_driver/styles/styles.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

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