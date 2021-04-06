import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/styles/styles.dart';
import 'package:greentaxi_driver/widgets/BrandDivider.dart';
import 'package:greentaxi_driver/widgets/ProgressDialog.dart';
import 'package:greentaxi_driver/widgets/TaxiButton.dart';
import 'package:greentaxi_driver/widgets/TaxiButtonSmall.dart';

class RatingsTab extends StatefulWidget {
  @override
  _RatingsTabState createState() => _RatingsTabState();
}

class _RatingsTabState extends State<RatingsTab> {
  final fullnamecontoller = TextEditingController();

  final phonecontoller = TextEditingController();

  final mainMessageController = TextEditingController();

  final passwordcontoller = TextEditingController();

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  @override
  void initState() {
    print("Init Driver Details  ${currentDriverInfo.SCR} ODR = ${currentDriverInfo.ODR}");
    super.initState();
  }

  void sendMessage(String type,String customerId , String tripId) async {

    // showDialog(
    //   barrierDismissible: false,
    //   context: context,
    //   builder: (BuildContext context) => ProgressDialog(
    //     status: 'Creating customer.....',
    //   ),
    // );
    try {
      var refx = FirebaseDatabase.instance
          .reference()
          .child('drivers/${currentFirebaseUser.uid}/messages').push();

      Map usermap = {
        'uId': refx.key,
        'message': mainMessageController.text,
        'type':type,
        'customerId':customerId,
        'tripId':tripId,
        'requestTime':"rtime",
        'timeStamp': "time",
      };
      refx.set(usermap);
      //Navigator.pop(context);
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

    //Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    Widget returnControlMessage(
        String message1, String message2, bool isError) {
      return Container(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                new Text(
                  message1,
                  style: GoogleFonts.roboto(
                      fontSize: 15,
                      color: isError ? Color(0xFFd32f2f) : Color(0xFFff6f00),
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                BrandDivider(),
                SizedBox(
                  height: 10,
                ),
                new Text(
                  message2,
                  style: GoogleFonts.roboto(fontSize: 15),
                ),
              ],
            ),
          ));
    }

    var builderParam = StreamBuilder(
        stream: FirebaseDatabase.instance
            .reference()
            .child('drivers/${currentFirebaseUser.uid}/messages')
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
                             var mType = list[index]["type"] != null ? list[index]["type"] :"Message";
                            // var dateString = "${date.year}/${date.month}/${date.day}  ${date.hour}:${date.minute}:";
                            return mType == "Message" ? Card(
                              color: Color(0xFFfafafa),
                              child: Column(
                                children: <Widget>[
                                  SizedBox(height: 8,),
                                  Row(
                                    children:<Widget> [
                                      SizedBox(width:12 ),
                                      Icon(Icons.message,color: Color(0xFFff6f00),),
                                      SizedBox(width:12 ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children:<Widget> [
                                            Text("${list[index]["message"]}",overflow: TextOverflow.ellipsis,maxLines: 1, style: GoogleFonts.roboto(fontSize: 15,fontWeight: FontWeight.normal ,color: Color(0xFF212121)),),
                                            SizedBox(height: 5,),
                                                                                    ],
                                        ),
                                      ),
                                      //Icon(Icons.arrow_forward_ios_outlined, size: 15 , color: BrandColors.colorDimText,)
                                    ],
                                  ),
                                  SizedBox(height: 8,),
                                  //BrandDivider()
                                ],
                              ),
                            ) :
                            Card(
                              color: Color(0xFFfafafa),
                              child: Column(
                                children: <Widget>[
                                  SizedBox(height: 8,),
                                  Row(
                                    children:<Widget> [
                                      SizedBox(width:12 ),
                                      Icon(Icons.emoji_transportation,color: Color(0xFFc2185b),),
                                      SizedBox(width:12 ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children:<Widget> [
                                            Text("${list[index]["message"]}",overflow: TextOverflow.ellipsis,maxLines: 1, style: GoogleFonts.roboto(fontSize: 15,fontWeight: FontWeight.normal ,color: Color(0xFF212121)),),
                                            SizedBox(height: 5,),
                                            Row(
                                              children:<Widget> [
                                                Text("From", style: GoogleFonts.roboto(color: Color(0xFF0097a7)),),
                                                SizedBox(width: 5,),
                                                Text("Athurugiriya InterChange", style: GoogleFonts.roboto(),)
                                              ],
                                            ),
                                            Row(
                                              children:<Widget> [
                                                Text("To     ", style: GoogleFonts.roboto(color: Color(0xFF0097a7)),),
                                                SizedBox(width: 5,),
                                                Text("Kaduwela Bus Stop", style: GoogleFonts.roboto(),)
                                              ],
                                            ),
                                            Row(
                                              children:<Widget> [
                                                Text("Time ", style: GoogleFonts.roboto(color: Color(0xFF0097a7)),),
                                                SizedBox(width: 5,),
                                                Text("2021/3/7 12:58 PM", style: GoogleFonts.roboto(),)
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      //Icon(Icons.arrow_forward_ios_outlined, size: 15 , color: BrandColors.colorDimText,)
                                    ],
                                  ),
                                  SizedBox(height: 8,),
                                  //BrandDivider()
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
                  newwidget= returnControlMessage("No Messages","No messages Found.", false);
                }
              }else{
                newwidget= returnControlMessage("No Messages","No messages Found.", false);
              }
            }else{
              newwidget= returnControlMessage("No Messages","No messages Found.", false);
            }
          }else{
            newwidget= returnControlMessage("No Messages","No messages Found.", false);
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
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    children: [
                      Text("Messaging",
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
              SizedBox(height: 5,),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          height: 380,
                          decoration: BoxDecoration(
                            color: Color(0xFFeeeeee),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                width: 1.0, color: Color(0xFFe0e0e0)),
                          ),
                          child: builderParam),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                width: 1.0, color: Color(0xFFFFFFFF)),
                          ),
                          child:Column (
                            children:<Widget> [
                              Card(
                                color:Color(0xFFffe0b2) ,
                               margin:EdgeInsets.only(left: 2,right: 2, bottom: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),

                                ),
                                child: TextFormField(
                                  controller:mainMessageController ,
                                  textAlignVertical: TextAlignVertical.center,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 1,
                                  minLines: 1,
                                  style: GoogleFonts.roboto(fontSize: 15),
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                    hintText: "type a message",
                                    prefixIcon: IconButton(
                                      onPressed: (){},
                                      icon: Icon(Icons.emoji_events_rounded),
                                    ),
                                    contentPadding: EdgeInsets.all(5)
                                  ),
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: TaxiButtonSmallWithSize(
                                      title: "Send",
                                      color:Color(0xFFff6f00),
                                      fontSize: 14,
                                      onPress: () async {
                                        //var now = DateTime.now();
                                        sendMessage("Message","","");
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Expanded(
                                    child: TaxiButtonSmallWithSize(
                                      title: "Trip Request",
                                      color:Color(0xFFff6f00),
                                      fontSize: 14,
                                      onPress: () async {
                                        sendMessage("RideRequest","P7ezz68RtbdPduF6TBhrCCwjdcF2","-MTxOE_LgCpMY_ekub6H");
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                      ),


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

  void showAlertGlobal(BuildContext context, String title) {
    showDialog(
        useSafeArea: true,
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) => AlertDialog(
          title: Center(
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.supervised_user_circle_rounded,
                    color: Color(0xFFff6f00),
                    size: 60,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    title,
                    style: GoogleFonts.roboto(
                        fontSize: 20, color: Color(0xFFff6f00)),
                  ),
                ],
              )),
          contentPadding: EdgeInsets.all(10.0),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              //position
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 20, bottom: 20, left: 5, right: 5),
                    child: Column(
                      children: [
                        TextField(
                          controller: fullnamecontoller,
                          keyboardType: TextInputType.text,
                          decoration: getInputDecorationRegister(
                              'Full Name', Icon(Icons.keyboard)),
                          style: GoogleFonts.roboto(
                              color: Colors.black87,
                              fontSize: 15,
                              height: 1),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: phonecontoller,
                          keyboardType: TextInputType.phone,
                          decoration: getInputDecorationRegister(
                              'Mobile No', Icon(Icons.phone)),
                          style: GoogleFonts.roboto(
                              color: Colors.black87, fontSize: 15),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TaxiButton(
                          title: "Add Customer",
                          color: Color(0xFFff6f00),
                          onPress: () async {

                            var connectivity =
                            await Connectivity().checkConnectivity();
                            if (connectivity != ConnectivityResult.mobile &&
                                connectivity != ConnectivityResult.wifi) {
                              showSnackBar('Oops! seems you are offline.');
                              return;
                            }
                            if (fullnamecontoller.text.length < 3) {
                              showSnackBar(
                                  'Oops! full name must be more than 3 characters.');
                              return;
                            }
                            if (phonecontoller.text.length != 10) {
                              showSnackBar(
                                  'Oops! Phone number must be 10 characters.');
                              return;
                            }
                            //registerUser();
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
