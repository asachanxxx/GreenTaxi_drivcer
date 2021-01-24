import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:greentaxi_driver/globalvariables.dart';

class LifeCycleManager extends StatefulWidget {
  final Widget child;
  LifeCycleManager({Key key, this.child}) : super(key: key);
  _LifeCycleManagerState createState() => _LifeCycleManagerState();
}
class _LifeCycleManagerState extends State<LifeCycleManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state managed= $state');
    if(state.toString() == "detached"){
      GoOffline();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.child,
    );
  }

  void GoOffline() {
    Geofire.removeLocation(currentFirebaseUser.uid);
    var tripRequestRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebaseUser.uid}/newtrip');

    tripRequestRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebaseUser.uid}/onlineStatus');
    tripRequestRef.set('offline');

    // tripRequestRef = FirebaseDatabase.instance
    //     .reference()
    //     .child('driversAvailable/${currentFirebaseUser.uid}');
    // tripRequestRef.remove();

    tripRequestRef.onDisconnect();
  }

}