import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/brand_colors.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/screens/registration.dart';
import 'package:greentaxi_driver/styles/styles.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class StartUpScr extends StatefulWidget {
  static const String Id = 'startup';
  @override
  _StartUpScrState createState() => _StartUpScrState();
}

class _StartUpScrState extends State<StartUpScr> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Welcome to Flutter',
        home: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("images/backgrounds/pagemain.jpg"),
                  fit: BoxFit.cover)),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.all(0),
                children: <Widget>[
                  Container(
                    height: 160,
                    color: Colors.white,
                    child: DrawerHeader(
                      decoration: BoxDecoration(color: Colors.white),
                      child: Row(
                        children: <Widget>[
                          Image.asset(
                            'images/user_icon.png',
                            height: 60,
                            width: 60,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('Asanga Chan',
                                  //style: TextStyle( fontSize: 20, fontFamily: 'Brand-Bold')),
                                  style: f_profileHeaderStyle),
                              SizedBox(
                                height: 5,
                              ),
                              Text('View Profile',
                                style: f_profileSecondryStyle,)
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ListTile(
                    leading: Icon(OMIcons.cardGiftcard),
                    title: Text(
                      'Free Rides',
                      style: kDrawerItemStyle,
                    ),
                  ),
                  ListTile(
                    leading: Icon(OMIcons.departureBoard),
                    title: Text(
                      'Planned Trips',
                      style: kDrawerItemStyle,
                    ),
                  ),
                  ListTile(
                    leading: Icon(OMIcons.history),
                    title: Text(
                      'Ride History',
                      style: kDrawerItemStyle,
                    ),
                  ),
                  ListTile(
                    leading: Icon(OMIcons.contactSupport),
                    title: Text(
                      'Support',
                      style: kDrawerItemStyle,
                    ),
                  ),
                  ListTile(
                    leading: Icon(OMIcons.creditCard),
                    title: Text(
                      'Payments',
                      style: kDrawerItemStyle,
                    ),
                  ),
                  ListTile(
                    leading: Icon(OMIcons.info),
                    title: Text(
                      'About',
                      style: kDrawerItemStyle,
                    ),
                  ),
                ],
              ),
            ),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              centerTitle: true,
            ),
            body: Container(
              color: Colors.transparent,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget> [
                       Column(
                         children:<Widget> [
                           Padding(
                             padding: const EdgeInsets.only(left: 20,top: 20),
                             child: Text((currentDriverInfo != null) ? 'Welcome back ' + currentDriverInfo.fullName: "සුබ දවසක් වේවා!",style: GoogleFonts.roboto(fontSize: 30,color: Colors.white,fontWeight: FontWeight.bold),),
                           ),
                           SizedBox(height: 10,),
                           Padding(
                             padding: const EdgeInsets.only(left: 0,top: 0),
                             child: Text((currentDriverInfo != null) ? 'Welcome back ' + currentDriverInfo.fullName: "What can we do for you?",style: GoogleFonts.roboto(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),),
                           )
                         ],
                       )
                    ],
                  ),
                  SizedBox(height: 100,),
                  ///First row *********************************************************************************************************************
                  Row(
                    children: <Widget>[

                      ///Rides Button *********************************************************************************************************************
                      Padding(
                        padding: EdgeInsets.fromLTRB(60, 20, 20, 20),
                        child: Container(child:
                        Column(
                          children: <Widget>[
                            Container(
                                height: 70,
                                width: 70,
                                decoration: boxDecoLogin,
                                child: Center(
                                    widthFactor: 50.0,
                                    heightFactor: 50.0,
                                    child: new Image.asset(
                                        'images/icons/car2.png', width: 50.0,
                                        height: 40.0)
                                )

                            ),
                            SizedBox(height: 10,),
                            Text('Rides', style: f_font_main_button),
                          ],
                        )
                        ),
                      ),

                      SizedBox(width: 2,),

                      ///Book Later *********************************************************************************************************************
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 20, 20, 20),
                        child: GestureDetector(
                          onTap: (){
                            // Navigator.pushNamedAndRemoveUntil(
                            //     context, LoginPage.Id, (route) => false);
                          },
                          child: Container(child:
                          Column(
                            children: <Widget>[
                              Container(
                                  height: 70,
                                  width: 70,
                                  decoration: boxDecoLogin,
                                  child: Center(
                                      widthFactor: 50.0,
                                      heightFactor: 50.0,
                                      child: new Image.asset(
                                          'images/icons/booking.png', width: 50.0,
                                          height: 40.0)
                                  )

                              ),
                              SizedBox(height: 10,),
                              Text('Book Later', style: f_font_main_button),
                            ],
                          )
                          ),
                        ),
                      ),

                      SizedBox(width: 2,),

                      ///Log IN *********************************************************************************************************************
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 20, 20, 20),
                        child: GestureDetector(
                          onTap: (){
                            Navigator.pushNamedAndRemoveUntil(
                                context, RiderRegister.Id, (route) => false);
                          },
                          child: Container(child:
                          Column(
                            children: <Widget>[
                              Container(
                                  height: 70,
                                  width: 70,
                                  decoration: boxDecoLogin,
                                  child: Center(
                                      widthFactor: 50.0,
                                      heightFactor: 50.0,
                                      child: new Image.asset(
                                          'images/icons/booking.png', width: 50.0,
                                          height: 40.0)
                                  )

                              ),
                              SizedBox(height: 10,),
                              Text('Register', style: f_font_main_button),
                            ],
                          )
                          ),
                        ),
                      ),
                    ],
                  ),
                  ///First row *********************************************************************************************************************
                  Row(
                    children: <Widget>[

                      ///Rides Button *********************************************************************************************************************
                      Padding(
                        padding: EdgeInsets.fromLTRB(60, 20, 20, 20),
                        child: Container(child:
                        Column(
                          children: <Widget>[
                            Container(
                                height: 70,
                                width: 70,
                                decoration: boxDecoLogin,
                                child: Center(
                                    widthFactor: 50.0,
                                    heightFactor: 50.0,
                                    child: new Image.asset(
                                        'images/icons/car2.png', width: 50.0,
                                        height: 40.0)
                                )

                            ),
                            SizedBox(height: 10,),
                            Text('No Press', style: f_font_main_button),
                          ],
                        )
                        ),
                      ),

                      SizedBox(width: 2,),

                      ///Book Later *********************************************************************************************************************
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 20, 20, 20),
                        child: GestureDetector(
                          onTap: (){
                            // Navigator.pushNamedAndRemoveUntil(
                            //     context, LoginPage.Id, (route) => false);
                          },
                          child: Container(child:
                          Column(
                            children: <Widget>[
                              Container(
                                  height: 70,
                                  width: 70,
                                  decoration: boxDecoLogin,
                                  child: Center(
                                      widthFactor: 50.0,
                                      heightFactor: 50.0,
                                      child: new Image.asset(
                                          'images/icons/booking.png', width: 50.0,
                                          height: 40.0)
                                  )

                              ),
                              SizedBox(height: 10,),
                              Text('No Press', style: f_font_main_button),
                            ],
                          )
                          ),
                        ),
                      ),

                      SizedBox(width: 2,),

                      ///Log IN *********************************************************************************************************************
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 20, 20, 20),
                        child: GestureDetector(
                          onTap: (){
                            Navigator.pushNamedAndRemoveUntil(
                                context, RiderRegister.Id, (route) => false);
                          },
                          child: Container(child:
                          Column(
                            children: <Widget>[
                              Container(
                                  height: 70,
                                  width: 70,
                                  decoration: boxDecoLogin,
                                  child: Center(
                                      widthFactor: 50.0,
                                      heightFactor: 50.0,
                                      child: new Image.asset(
                                          'images/icons/booking.png', width: 50.0,
                                          height: 40.0)
                                  )

                              ),
                              SizedBox(height: 10,),
                              Text('No Press', style: f_font_main_button),
                            ],
                          )
                          ),
                        ),
                      ),
                    ],
                  )

                ],
              ),
            ),
          ),
        )
    );
  }
}
