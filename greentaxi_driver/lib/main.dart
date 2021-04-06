import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/dataprovider/appdata.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'file:///I:/TaxiApp/GIT/GreenTaxi_Driver/GreenTaxi_drivcer/greentaxi_driver/lib/screens/misc/customerfunctions.dart';
import 'package:greentaxi_driver/screens/driverimagedetails.dart';
import 'package:greentaxi_driver/screens/login.dart';
import 'package:greentaxi_driver/screens/mainpage.dart';
import 'package:greentaxi_driver/screens/misc/customertrips.dart';
import 'package:greentaxi_driver/screens/misc/requesttrip.dart';
import 'package:greentaxi_driver/screens/misc/selectlocationonmap.dart';
import 'package:greentaxi_driver/screens/newtripspage.dart';
import 'package:greentaxi_driver/screens/phoneverify.dart';
import 'package:greentaxi_driver/screens/registration.dart';
import 'package:greentaxi_driver/screens/restartscreen.dart';
import 'package:greentaxi_driver/screens/startup.dart';
import 'package:greentaxi_driver/screens/testing.dart';
import 'package:greentaxi_driver/screens/uploadimage.dart';
import 'package:greentaxi_driver/screens/userstatusscreen.dart';
import 'package:greentaxi_driver/screens/userstatusscreenpending.dart';
import 'package:greentaxi_driver/screens/vehicleinfo.dart';
import 'package:greentaxi_driver/screens/verificationcode.dart';
import 'package:greentaxi_driver/shared/repository/companyrepository.dart';
import 'package:greentaxi_driver/shared/repository/serial_service.dart';
import 'package:greentaxi_driver/widgets/lifecyclemanager.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

void main() async {
  print("App starting........");
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
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
  } catch (e) {
    logger.e(
        "Firebase Error==========================================> ${e.toString()}");
  }

  currentFirebaseUser = FirebaseAuth.instance.currentUser;

  if (currentFirebaseUser != null) {
    try {
      ///we need to check if the current FirebaseAuth.instance.currentUser
      /// is on the drivers node. if node we have to direct to register
      var hasAssociateDriverAccount = await CompanyRepository()
          .getCheckUidHasDriverAccount(currentFirebaseUser.uid);
      logger.i(
          "main Method hasAssociateDriverAccount==========================================> $hasAssociateDriverAccount");
      if (hasAssociateDriverAccount != null) {
        ///Get the status
        var accStatus = hasAssociateDriverAccount["accountStatus"];

        ///Handling the driver status
        if (accStatus == "NoVehicleDet") {
          dRoute = 'vehicleinfo';
        } else if (accStatus == "NoImageDet") {
          dRoute = 'driverMoreInfo';
        } else if (accStatus == "Banned") {
          dRoute = 'userstatus';
        } else if (accStatus == "Pending") {
          dRoute = 'userstatuspending';
        } else {
          dRoute = 'main';
        }
      } else {
        ///sice this is false login or a login without driver account we log off the user
        ///and direct to login
        FirebaseAuth.instance.signOut();
        dRoute = 'login';
      }
    }catch (e) {
      logger.e("Firebase Error on main==========================================> ${e.toString()}");
      dRoute = "login";
    }

  } else {
    ///This means the user is not logged in
    dRoute = "login";
  }

  ///Loading system settings
  systemSettings = await CompanyRepository().fetchSystemConfigurations();
  SerialService.initSerials();


  Wakelock.enable();
  runApp(MyApp());
}

class MyApp extends StatefulWidget with WidgetsBindingObserver {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  /*
     Set default `_initialized` and `_error` state to false
    * */

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
  initState() {
    logger.d("Came to the initState");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    logger.d("dRoute =============> $dRoute");

    /*
    * App widget tree building here.
    * Added only the route configs. not changes need to be done unless there is a extreme need
    * */
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: LifeCycleManager(
        child: MaterialApp(
          key: scaffoldKey,
          title: 'Go2Go Driver',
          theme: ThemeData(
            textTheme: GoogleFonts.robotoMonoTextTheme(
              Theme.of(context).textTheme,
            ),
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          //initialRoute:(currentFirebaseUser == null)? LoginPage.Id : MainPage.Id,
          initialRoute: dRoute,
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
            UploadingImageToFirebaseStorage.Id: (context) =>
                UploadingImageToFirebaseStorage(),
            DriverMoreInfo.Id: (context) => DriverMoreInfo(),
            UserStatusScreenPending.Id: (context) => UserStatusScreenPending(),
            CustomerTrips.Id: (context) => CustomerTrips(),
            SimpleRecorder.Id: (context) => SimpleRecorder(),
            SelectLocationOnMap.Id: (context) => SelectLocationOnMap(),
          },
        ),
      ),
    );
  }
}
