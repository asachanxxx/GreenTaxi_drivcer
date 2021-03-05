import 'package:firebase_database/firebase_database.dart';

class SearchHistory{
  String placeId;
  String name;
  String displayName;
  double lat;
  double lng;

  SearchHistory(
      this.placeId,
      this.name,
      this.displayName,
      this.lat,
      this.lng,
      );

  SearchHistory.fromShapShot(DataSnapshot snapshot){
    this.name = snapshot.value['name'];
    this.displayName = snapshot.value['displayName'];
    this.lat =snapshot.value['lat'];
    this.lng = snapshot.value['lng'];
    this.placeId = snapshot.value['placeId'];
  }
}