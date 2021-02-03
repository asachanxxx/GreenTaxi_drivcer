# greentaxi_driver

A new Flutter application.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Firebase
========
https://stackoverflow.com/questions/46958832/how-to-set-push-key-when-pushing-to-firebase-database
If you want to loop through all messages:

var ref = firebase.database().ref("messages");
ref.once("value", function(snapshot) {
  snapshot.forEach(function(message) {
    console.log(message.key+": "+message.val().original);
  });
});
If you want to find specific messages, use a query:

var ref = firebase.database().ref("messages");
var query = ref.orderByChild("original").equalTo("aaaa");
query.once("value", function(snapshot) {
  snapshot.forEach(function(message) {
    console.log(message.key+": "+message.val().original);
  });
});


  return StreamBuilder(
        stream: FirebaseDatabase.instance
            .reference()
            .child('node')
            .orderByChild('userid')
            .equalTo(userId)
            .onValue,
        builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.snapshot.value != null) {
              Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
              List<dynamic> list = map.values.toList();


              return ListView.builder(
                itemCount: list.length,
                padding: EdgeInsets.all(4.0),
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Container(
                          decoration:
                              BoxDecoration(color: Colors.blueGrey[100]),
                          child: ListTile(
                            title: Text(list[index]["title"]),
                            subtitle: Text(list[index]["text"]),
),


  Map usermap = {
            'fullName': fullnamecontoller.text,
            'email': email,
            'phoneNumber': phonecontoller.text,
            'pass': "123456",
            'datetime': DateTime.now().toString(),
            'driverID': currentFirebaseUser.uid,
            'isSystemOwned': true,
            'rating': 5,
          };

AccountStatus
=============
DataEntity: accountStatus:
"NoVehicleDet"
"NoImageDet"
"Pending"
"Active"
"Banned"

Inquiry Types
=============
DataEntity:type
"AccActivation"

cupertino_icons: ^0.1.3
  firebase_core: ^0.5.0+1
  firebase_auth: ^0.18.1+2
  firebase_database: ^4.1.1
  connectivity: ^2.0.0
  google_maps_flutter: ^1.0.5
  outline_material_icons: ^0.1.1
  geolocator: ^6.1.13
  http: ^0.12.2
  provider: ^4.3.2+2
  flutter_polyline_points: ^0.2.4
  google_fonts: ^1.1.1
  font_awesome_flutter: ^8.10.0
  animated_text_kit: ^2.5.4
  flutter_geofire: ^1.0.3
  firebase_messaging: ^6.0.16
  assets_audio_player: ^2.0.1+7
  toast: ^0.1.5
  maps_toolkit: ^1.1.0+1
  url_launcher: ^5.7.10
  wakelock: ^0.2.1+1
  sms_autofill: ^1.2.6

