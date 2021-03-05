import 'package:firebase_database/firebase_database.dart';
import 'package:greentaxi_driver/dataprovider/appdata.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/models/dateWiseSummary.dart';
import 'package:provider/provider.dart';

class SalesService{

  static Future<DateWiseSummary> getdateWiseSummary(context) async{
    var datestring = makeDateString();
    var snapShotx=  await FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/dateWiseSummary/$datestring').once();
    if(snapShotx.value == null){
      var summary = DateWiseSummary(0.0,0.0,0.0,0.0,0.0,0.0,0.0);
      await earningTryOut(summary);
      return Future.value(summary);
    }else{
      var dateWiseSummary = DateWiseSummary.fromShapShot(snapShotx);
      return dateWiseSummary;
    }
  }

  static Future<CashFlows> getCashDlows(context) async{
    var snapShotx=  await FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/cashFlows').once();
    if(snapShotx.value == null){
      var summary = CashFlows(0,0);
      await updateCashFlows(summary);
      return Future.value(summary);
    }else{
      var cashFlows = CashFlows.fromShapShot(snapShotx);
      print("getCashDlows YYYY ${snapShotx.value}");
      return cashFlows;
    }
  }



  static Future<bool> earningTryOut(DateWiseSummary summary) async{
    var datestring = makeDateString();
    print("earnignTryOut Firebase Path ${'drivers/${currentFirebaseUser.uid}/$datestring'}");
    var reg= FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/dateWiseSummary/$datestring');

    Map datramap= {
      "totalEarning":summary.totalEarning,
      "totalCommission":summary.totalCommission,
      "totalTime":summary.totalTime,
      "totalKMs":summary.totalKMs,
      "totalFare":summary.totalFare,
      "timePrice":summary.timePrice,
      "kmPrice":summary.kmPrice,
    };

    await reg.set(datramap);
    return Future.value(true);
  }

  static Future<bool> updatedateWiseSummary(DateWiseSummary summary) async{
    var datestring = makeDateString();
    DateWiseSummary exDateWiseSummary;
    var  exxistingValue = await FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/dateWiseSummary/$datestring').once();

    if(exxistingValue.value != null){
      exDateWiseSummary = DateWiseSummary.fromShapShot(exxistingValue);
    }else{
      exDateWiseSummary = DateWiseSummary(0,0,0,0,0,0,0);
    }

    var reg= FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/dateWiseSummary/$datestring');

    Map datramap= {
      "totalEarning":summary.totalEarning + exDateWiseSummary.totalEarning,
      "totalCommission":summary.totalCommission+ exDateWiseSummary.totalCommission,
      "totalTime":summary.totalTime+ exDateWiseSummary.totalTime,
      "totalKMs":summary.totalKMs+ exDateWiseSummary.totalKMs,
      "totalFare":summary.totalFare+ exDateWiseSummary.totalFare,
      "timePrice":summary.timePrice+ exDateWiseSummary.timePrice,
      "kmPrice":summary.kmPrice+ exDateWiseSummary.kmPrice,
    };

    await reg.set(datramap);
    return Future.value(true);
  }


  static String makeDateString(){
    var datestring = "${DateTime.now().year.toString()}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}";
    print("makeDateString -> $datestring");
    return datestring;
  }

  static Future<bool> updateEarningOnly(double earning) async{
    double exValue = 0;
    var datestring = makeDateString();
    print("updateEarningOnly Firebase Path ${'drivers/${currentFirebaseUser.uid}/dateWiseSummary/$datestring/totalEarning'}");

    var  exxistingValue = await FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/dateWiseSummary/$datestring/totalEarning').once();
    print("exxistingValue = ${exxistingValue.value}");

    if(exxistingValue.value == null){
      exValue = 0;
    }else{
      exValue = double.parse(exxistingValue.value.toString());
    }

    await FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/dateWiseSummary/$datestring/totalEarning').set(exValue + earning);
    return Future.value(true);
  }





  static Future<bool> updateCashFlows(CashFlows summary) async{
    CashFlows exDateWiseSummary;
    var  exxistingValue = await FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/cashFlows/').once();

    if(exxistingValue.value != null){
      exDateWiseSummary = CashFlows.fromShapShot(exxistingValue);
    }else{
      exDateWiseSummary = CashFlows(0,0);
    }

    var reg= FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/cashFlows/');

    Map datramap= {
      "debit":summary.debit + exDateWiseSummary.debit,
      "credit":summary.credit+ exDateWiseSummary.credit,
    };

    await reg.set(datramap);
    return Future.value(true);
  }








}