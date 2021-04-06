import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greentaxi_driver/brand_colors.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/helpers/helpermethods.dart';
import 'package:greentaxi_driver/shared/repository/companyrepository.dart';
import 'package:greentaxi_driver/shared/repository/firebase_service.dart';
import 'package:greentaxi_driver/styles/styles.dart';
import 'package:greentaxi_driver/tabs/customertab.dart';
import 'package:greentaxi_driver/tabs/earningstab.dart';
import 'package:greentaxi_driver/tabs/hometab.dart';
import 'package:greentaxi_driver/tabs/profiletab.dart';
import 'package:greentaxi_driver/tabs/ratingstab.dart';

class MainPage extends StatefulWidget {
  static const String Id = 'main';
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  TabController tabController;
  int selecetdIndex = 0;

  void onItemClicked(int index) {
    setState(() {
      print("onItemClicked $index");
      selecetdIndex = index;
      tabController.index = selecetdIndex;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    posError = LatLng(6.877133555388284, 79.98983549839619);
    tabController = TabController(length: 5, vsync: this);
    CompanyRepository().getVehicleTypeInfo().then((value) {
      setState(() {
        globalVTypes = value;
        print("getVehicleTypeInfo  ${value.length}");
      });
    });

    HelperMethods.determinePosition().then((value) {
      print("currentpossitionCheck $value");
    });

    if(currentFirebaseUser.uid != null){
      FirebaseService.handleOnlineStatus(currentFirebaseUser.uid);
    }



  }

  @override
  void dispose() {
    // TODO: implement dispose
    tabController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: <Widget>[
          HomeTab(),
          EarningsTab(),
          CustomerTab(),
          ProfileTab(),
          RatingsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(


        // items: <BottomNavigationBarItem>[
        //   BottomNavigationBarItem(
        //     icon: Icon(Icons.home, color: Colors.black54),
        //     title: Text(
        //       'Home',
        //       style: f_font_tabtitleColor,
        //     ),
        //   ),
        //   BottomNavigationBarItem(
        //     icon: Icon(Icons.credit_card, color: Colors.black54),
        //     title: Text('Earnings', style: f_font_tabtitleColor),
        //   ),
        //   BottomNavigationBarItem(
        //     icon: Icon(
        //       Icons.star,
        //       color: Colors.black54,
        //     ),
        //     title: Text('Customers', style: f_font_tabtitleColor),
        //   ),
        //   BottomNavigationBarItem(
        //     icon: Icon(Icons.person, color: Colors.black54),
        //     title: Text('Account', style: f_font_tabtitleColor),
        //   ),
        //   BottomNavigationBarItem(
        //     icon: Icon(Icons.person, color: Colors.black54),
        //     title: Text('Messaging', style: f_font_tabtitleColor),
        //   ),
        // ],
        //

        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black54),
            label: 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card, color: Colors.black54),
            label: 'Earnings'

          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.star,
              color: Colors.black54,
            ),
            label: 'Customers'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black54),
            label: 'Account'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message, color: Colors.black54),
            label: 'Messages'
          ),
        ],


        unselectedLabelStyle: f_font_tabtitleColor,
        selectedLabelStyle: f_font_tabtitleColorSelected,
        currentIndex: selecetdIndex,
        selectedItemColor: Color(0xfff57f17),
        selectedIconTheme: IconThemeData(color: Color(0xfff57f17)) ,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: onItemClicked,
      ),
    );
  }
}
