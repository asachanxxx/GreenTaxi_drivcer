import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:greentaxi_driver/brand_colors.dart';
import 'package:greentaxi_driver/styles/styles.dart';
import 'package:greentaxi_driver/tabs/earningstab.dart';
import 'package:greentaxi_driver/tabs/hometab.dart';
import 'package:greentaxi_driver/tabs/profiletab.dart';
import 'package:greentaxi_driver/tabs/ratingstab.dart';

class MainPage extends StatefulWidget {
  static const String Id = 'main';
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin{

  TabController tabController;
  int selecetdIndex = 0;

  void onItemClicked(int index){
    setState(() {
      selecetdIndex = index;
      tabController.index = selecetdIndex;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 4, vsync: this);
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
          RatingsTab(),
          ProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home,color: Colors.black),
            title: Text('Home', style: f_font_tabtitleColor,),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card,color: Colors.black),
            title: Text('Earnings', style: f_font_tabtitleColor),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star,color: Colors.black,),
            title: Text('Ratings', style: f_font_tabtitleColor),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person,color: Colors.black),
            title: Text('Account', style: f_font_tabtitleColor),
          ),
        ],
        currentIndex: selecetdIndex,
        unselectedItemColor: BrandColors.colorPink,
        selectedItemColor: BrandColors.colorOrange,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        onTap: onItemClicked,
      ),
    );
  }
}
