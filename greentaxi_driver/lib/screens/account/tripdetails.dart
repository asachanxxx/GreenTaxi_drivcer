import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/brand_colors.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/widgets/BrandDivider.dart';

class TripDetailsAcc extends StatefulWidget {
  @override
  _TripDetailsAccState createState() => _TripDetailsAccState();
}

class _TripDetailsAccState extends State<TripDetailsAcc> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

    var builderParam = StreamBuilder(
        stream: FirebaseDatabase.instance
            .reference()
            .child('drivers/${currentFirebaseUser.uid}/tripHistory')
            .limitToLast(10)
            .onValue, // async work
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          Widget newwidget;
          List<dynamic> list;
          if (snapshot != null) {
            if (snapshot.data != null) {
              if (snapshot.data.snapshot != null) {
                if (snapshot.data.snapshot.value != null) {
                  if (snapshot.hasData) {
                    print("snapshot Datax ${snapshot.data.snapshot
                        .value }");
                    newwidget = new Container(child: Text("Hello"),);

                    print("snapshot Last");
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        newwidget = Text("Loading......");
                        break;
                      default:
                        Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
                        list = map.values.toList();
                        print("snapshot list $list");
                        newwidget = ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (BuildContext context, int index) {
                            var date = DateTime.parse(list[index]["date"].toString());
                            var dateString = "${date.year}/${date.month}/${date.day}  ${date.hour}:${date.minute}:";
                            return Container(
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
                                            Row(
                                              //0097a7
                                              children:<Widget> [
                                                Text("From: ",overflow: TextOverflow.ellipsis,maxLines: 1, style: GoogleFonts.roboto(fontSize: 15,fontWeight: FontWeight.normal ,color: Color(0xFFff6f00)),),
                                                Text("${list[index]["pickupAddress"]}",overflow: TextOverflow.ellipsis,maxLines: 1, style: GoogleFonts.roboto(fontSize: 15,fontWeight: FontWeight.normal ,color: Color(0xFF212121)),),
                                              ],
                                            ),
                                            SizedBox(height: 5,),
                                            Row(
                                              children: <Widget>[
                                                Text("To     :",overflow: TextOverflow.ellipsis,maxLines: 1, style: GoogleFonts.roboto(fontSize: 15,fontWeight: FontWeight.normal ,color: Color(0xFF0097a7)),),
                                                Text("${list[index]["destinationAddress"]}",overflow: TextOverflow.ellipsis,maxLines: 1, style: GoogleFonts.roboto(fontSize: 15,fontWeight: FontWeight.normal ,color: Color(0xFF212121)),),
                                              ],
                                            ),
                                            SizedBox(height: 5,),
                                            Text("Date: $dateString",overflow: TextOverflow.ellipsis,maxLines: 1, style:GoogleFonts.roboto(fontSize: 12,fontWeight: FontWeight.normal))
                                          ],
                                        ),
                                      ),
                                      //Icon(Icons.arrow_forward_ios_outlined, size: 15 , color: BrandColors.colorDimText,)
                                    ],
                                  ),
                                  SizedBox(height: 8,),
                                  BrandDivider()
                                ],
                              ),
                            );
                          },
                        );
                        break;
                    }
                  } else {
                    newwidget = Text("Loading......");
                  }
                }else{
                  newwidget = Text("Loading......");
                }
              }else{
                newwidget = Text("Loading......");
              }
            }else{
              newwidget = Text("Loading......");
            }
          }
          else{
            newwidget = Text("Loading......");
          }
          return newwidget;
        }
    );

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
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                  Icons.arrow_back, color: Color(0xFFffffff))
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                  "Trip History(Last 10)",
                                  style: GoogleFonts.roboto(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFffffff))),

                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          height: 500,
                          decoration: BoxDecoration(
                            color: Color(0xFFeeeeee),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                width: 1.0, color: Color(0xFFe0e0e0)),
                          ),
                          child: builderParam),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Column menuColumn(IconData iconData, String headerText, String detailText, bool futherNav) {
    return Column(
      children: <Widget>[
        BrandDivider(),
        SizedBox(
          height: 10,
        ),
        Row(
          children: <Widget>[
            Icon(
              iconData,
              color: Color(0xFFe65100),
              size: 35.0,
              semanticLabel: 'Text to announce in accessibility modes',
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(headerText,
                      style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF102027))),
                  Text(detailText,
                      style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF102027))),
                ],
              ),
            ),
            SizedBox(
              width: 20,
            ),
            futherNav ?
            Icon(
              Icons.keyboard_arrow_right,
              color: Colors.black54,
              size: 30.0,
              semanticLabel: 'Text to announce in accessibility modes',
            ):Container(),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        //BrandDivider(),
      ],
    );
  }
}
