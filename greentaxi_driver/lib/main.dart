import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/screens/customerfunctions.dart';
import 'package:greentaxi_driver/screens/login.dart';
import 'package:greentaxi_driver/screens/mainpage.dart';
import 'package:greentaxi_driver/screens/newtripspage.dart';
import 'package:greentaxi_driver/screens/phoneverify.dart';
import 'package:greentaxi_driver/screens/registration.dart';
import 'package:greentaxi_driver/screens/restartscreen.dart';
import 'package:greentaxi_driver/screens/startup.dart';
import 'package:greentaxi_driver/screens/testing.dart';
import 'package:greentaxi_driver/screens/userstatusscreen.dart';
import 'package:greentaxi_driver/screens/vehicleinfo.dart';
import 'package:greentaxi_driver/screens/verificationcode.dart';
import 'package:greentaxi_driver/shared/repository/companyrepository.dart';
import 'package:greentaxi_driver/widgets/lifecyclemanager.dart';
import 'package:wakelock/wakelock.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseApp app;

  print("Firebase.apps.length ${Firebase.apps.isEmpty}");
  if(Firebase.apps.length<=0){
     app = await Firebase.initializeApp(
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
        appId: '1:347124843484:android:40f86d925cada1ec4c8519',
        apiKey: 'AIzaSyDyHdxItuvyksZDh6nmjMcRnZRNPt86ETk',
        messagingSenderId: '297855924061',
        projectId: 'greentaxi-48ad5',
        databaseURL: 'https://greentaxi-48ad5.firebaseio.com',
      ),
    );
  }else{
    app = Firebase.app();
  }


  currentFirebaseUser = FirebaseAuth.instance.currentUser;
  Wakelock.enable();


  /*
  * Logic : if this there is no default driver logged in then
  * Redirect to the login page
  * */
  systemSettings = await CompanyRepository().fetchSystemConfigurations();

  if (currentFirebaseUser != null) {
    dRoute =
        await CompanyRepository().getNewTripStatus(currentFirebaseUser.uid);
    print(
        "void main() $dRoute and currentFirebaseUser.uid = ${currentFirebaseUser.uid}");
    if (dRoute != null && dRoute.trim().length >10) {
      tripDetails = await CompanyRepository().getTripDetails(dRoute);
    } else {
      ///we need to check if the current FirebaseAuth.instance.currentUser
      /// is on the drivers node. if node we have to direct to register
      var hasAssociateDriverAccount = await CompanyRepository().getCheckUidHasDriverAccount(currentFirebaseUser.uid);
      print("hasAssociateDriverAccount $hasAssociateDriverAccount");
      print("hasAssociateDriverAccount Status ${hasAssociateDriverAccount["accountStatus"]}");
      if(hasAssociateDriverAccount!= null) {
        if(hasAssociateDriverAccount["accountStatus"] == "Banned"){
          dRoute = 'userstatus';
        }else {
          ///Check if user filled out the vehicle details
          vehicleInfoCompleteStatus =
          await CompanyRepository().getVehicleInfoCompleteStatus(
              currentFirebaseUser.uid);
          print("vehicleInfoCompleteStatus $vehicleInfoCompleteStatus");

          ///If vehicle details ok then go to main and if not go to vehicle details screen
          if (vehicleInfoCompleteStatus) {
            dRoute = 'main';
          } else {
            dRoute = 'VehicleInfoNotComplete';
          }
        }
      }else{
        ///sice this is false login or a login without driver account we log off the user
        ///and direct to login
        FirebaseAuth.instance.signOut();
        dRoute = 'NotLoggedIN';
      }
    }
  } else {
    dRoute = "NotLoggedIN";
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget with WidgetsBindingObserver {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // bool hasEngagedInARide = false;

  String getScreenToLoad() {
    print("getScreenToLoad $dRoute");
    String returnScreen = "";
    if (dRoute == "NotLoggedIN") {
      returnScreen = 'login';
    } else if (dRoute == "main") {
      returnScreen = 'main';
    } else if (dRoute == "VehicleInfoNotComplete") {
      returnScreen = 'vehicleinfo';
    } else if (dRoute.length < 10) {
      //Rider has no uncompleted ride
      returnScreen = 'main';
    }else if (dRoute == "userstatus") {
      //Rider has no uncompleted ride
      returnScreen = 'userstatus';
    } else {
      returnScreen = 'restartscreen';
    }
    print("getScreenToLoad -> dRoute $returnScreen");
    return returnScreen;
  }

  @override
  initState() {
    super.initState();
    //print("initState -> dRoute $dRoute"); // but here It's null!
    getScreenToLoad();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   switch (state) {
  //     case AppLifecycleState.paused:
  //       print('paused state');
  //       break;
  //     case AppLifecycleState.resumed:
  //       print('resumed state');
  //       break;
  //     case AppLifecycleState.inactive:
  //       print('inactive state');
  //       break;
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    return LifeCycleManager(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          textTheme: GoogleFonts.robotoMonoTextTheme(
            Theme.of(context).textTheme,
          ),
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        //initialRoute:(currentFirebaseUser == null)? LoginPage.Id : MainPage.Id,
        initialRoute: getScreenToLoad(),
        routes: {
          MainPage.Id: (context) => MainPage(),
          RiderRegister.Id: (context) => RiderRegister(),
          StartUpScr.Id: (context) => StartUpScr(),
          VehicleInfo.Id: (context) => VehicleInfo(),
          LoginPage.Id: (context) => LoginPage(),
          TestTheCode.Id: (context) => TestTheCode(),
          PhoneVerification.Id: (context) => PhoneVerification(),
          VerifyCode.Id: (context) => VerifyCode(),
          RestartScreen.Id: (context) => RestartScreen(),
          NewTripPage.Id: (context) => NewTripPage(),
          CustomerFunctions.Id: (context) => CustomerFunctions(),
          UserStatusScreen.Id: (context) => UserStatusScreen(),

        },
      ),
    );
  }
}
