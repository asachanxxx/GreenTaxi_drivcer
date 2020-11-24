import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/models/drivers.dart';
import 'package:greentaxi_driver/screens/login.dart';
import 'package:greentaxi_driver/screens/mainpage.dart';
import 'package:greentaxi_driver/screens/registration.dart';
import 'package:greentaxi_driver/screens/startup.dart';
import 'package:greentaxi_driver/screens/vehicleinfo.dart';
import 'package:greentaxi_driver/shared/auth/userrepo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp(
    name: 'db2',
    options: Platform.isIOS || Platform.isMacOS
        ? FirebaseOptions(
      appId: '1:297855924061:ios:c6de2b69b03a5be8',
      apiKey: 'AIzaSyD_shO5mfO9lhy2TVWhfo1VUmARKlG4suk',
      projectId: 'flutter-firebase-plugins',
      messagingSenderId: '297855924061',
      databaseURL: 'https://flutterfire-cd2f7.firebaseio.com',
    )
        : FirebaseOptions(
      appId: '1:347124843484:android:92940c53a1f32f1f4c8519',
      apiKey: 'AIzaSyAq18NGeM5Gs4VKmVhY4vrNLIJ8u8zqHV4',
      messagingSenderId: '297855924061',
      projectId: 'flutter-firebase-plugins',
      databaseURL: 'https://greentaxi-48ad5.firebaseio.com',
    ),
  );


  currentFirebaseUser = FirebaseAuth.instance.currentUser;

  /*
  * Logic : if this there is no default driver logged in then
  * Redirect to the login page
  * */

  //Remove this when in production

  //Login Default User
  //UserRepository.logInUser(usr);


  runApp(MyApp());
}



class MyApp extends StatelessWidget {


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.robotoMonoTextTheme(
          Theme.of(context).textTheme,
        ),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
     initialRoute: (currentFirebaseUser == null)? LoginPage.Id : MainPage.Id,
     routes: {
       MainPage.Id:(context)=>MainPage(),
       RiderRegister.Id:(context)=>RiderRegister(),
       StartUpScr.Id:(context)=>StartUpScr(),
       VehicleInfo.Id:(context)=>VehicleInfo(),
       LoginPage.Id:(context)=>LoginPage()
     },
    );
  }
}
