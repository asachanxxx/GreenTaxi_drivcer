import 'package:firebase_database/firebase_database.dart';
import 'package:greentaxi_driver/globalvariables.dart';

class DateWiseSummary {
  double totalCommission;
  double totalEarning;
  double totalKMs;
  double totalTime;
  double kmPrice;
  double timePrice;
  double totalFare;

  DateWiseSummary(this.totalCommission, this.totalEarning, this.totalKMs, this.totalTime,
      this.kmPrice,this.totalFare,this.timePrice
      );

  DateWiseSummary.consturct(
      this.totalCommission,
      this.totalEarning,
      this.totalTime,
      this.totalKMs,
      this.kmPrice,
      this.timePrice,
      this.totalFare,
      );

  DateWiseSummary.fromShapShot(DataSnapshot snapshot) {
    this.totalCommission = roundUp(double.parse(snapshot.value['totalCommission'].toString()));
    this.totalEarning = roundUp(double.parse(snapshot.value['totalEarning'].toString()));
    this.totalTime = roundUp(double.parse(snapshot.value['totalTime'].toString()));
    this.totalKMs = roundUp(double.parse(snapshot.value['totalKMs'].toString()));
    this.kmPrice = roundUp(double.parse(snapshot.value['kmPrice'].toString()));
    this.timePrice = roundUp(double.parse(snapshot.value['timePrice'].toString()));
    this.totalFare = roundUp(double.parse(snapshot.value['totalFare'].toString()));

  }


}

class CashFlows {
  double debit;
  double credit;

  CashFlows(this.debit, this.credit);

  CashFlows.consturct(
      this.debit,
      this.credit,
      );

  CashFlows.fromShapShot(DataSnapshot snapshot) {
    this.debit = roundUp(double.parse(snapshot.value['debit'].toString()));
    this.credit = roundUp(double.parse(snapshot.value['credit'].toString()));
  }



}
