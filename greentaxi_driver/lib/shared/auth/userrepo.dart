import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/models/drivers.dart';


class UserRepository {

  // static void registerUser(Driver newUser) async {
  //   try {
  //     UserCredential userCredential = await FirebaseAuth.instance
  //         .createUserWithEmailAndPassword(
  //         email: newUser.email,
  //         password: newUser.pass
  //     );
  //
  //     if (userCredential != null) {
  //       print("EMAIL: " + userCredential.user.email);
  //       print("Password: " + newUser.pass);
  //       DatabaseReference newuser = FirebaseDatabase.instance.reference().child(
  //           'drivers/${userCredential.user.uid}');
  //
  //       Map usermap = {
  //         'fullName': newUser.fullName,
  //         'email': newUser.email,
  //         'phoneNumber': newUser.phone,
  //         'pass': newUser.pass,
  //         'datetime': DateTime.now().toString()
  //       };
  //       newuser.set(usermap);
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'weak-password') {
  //       print('The password provided is too weak.');
  //     } else if (e.code == 'email-already-in-use') {
  //       print('The account already exists for that email.');
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }
  //
  // static void logInUser(Driver newUser) async {
  //   try {
  //     UserCredential userCredential = await FirebaseAuth.instance
  //         .signInWithEmailAndPassword(
  //         email: newUser.email,
  //         password: newUser.pass
  //     );
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'user-not-found') {
  //       print('No user found for that email.');
  //     } else if (e.code == 'wrong-password') {
  //       print('Wrong password provided for that user.');
  //     }
  //   }
  // }
  //
  // static User getCurrentUser() {
  //   FirebaseAuth currentFireBaseUser = FirebaseAuth.instance;
  //   return currentFireBaseUser.currentUser;
  // }

  static void getCurrentUserInfo() async{
    FirebaseAuth currentFireBaseUser = FirebaseAuth.instance;
    String uId = currentFireBaseUser.currentUser.uid;
    print('User ID : ' + uId);
    print('User Email : ' + currentFireBaseUser.currentUser.email);


    DatabaseReference userRef = FirebaseDatabase.instance.reference().child('drivers/${currentFireBaseUser.currentUser.uid}');
    print('currentFireBaseUser.currentUser.uid :' + currentFireBaseUser.currentUser.uid);
    userRef.once().then((DataSnapshot snapshot){
      if(snapshot != null) {
        currentDriverInfo = Driver.fromSnapshot(snapshot);
        print('getCurrentUserInfo -> User ID : ' + currentDriverInfo.fullName);
      }else{
        print('snapshot is null');
      }
    });
  }

  static Future<Driver> getCurrentUserInfoRet() async{
    Driver returnRef = new Driver();
    FirebaseAuth currentFireBaseUser = FirebaseAuth.instance;
    String uId = currentFireBaseUser.currentUser.uid;
    print('User ID : ' + uId);
    print('User Email : ' + currentFireBaseUser.currentUser.email);


    DatabaseReference userRef = FirebaseDatabase.instance.reference().child('drivers/${currentFireBaseUser.currentUser.uid}');
    print('currentFireBaseUser.currentUser.uid :' + currentFireBaseUser.currentUser.uid);
     await userRef.once().then((DataSnapshot snapshot){
      if(snapshot != null) {
        returnRef=   Driver.fromSnapshot(snapshot);
       // print('getCurrentUserInfo -> User ID : ' + currentUser.fullName);
      }else{
        print('snapshot is null');
      }
    });

     return returnRef;
  }
  //
  // static bool isLoggedIn() {
  //   var loggedInstate = false;
  //   FirebaseAuth.instance
  //       .authStateChanges()
  //       .listen((User user) {
  //     if (user != null) {
  //       loggedInstate = true;
  //     }
  //   });
  //   return loggedInstate;
  // }
  //
  // static Future<bool> signOut() async{
  //   try {
  //     await FirebaseAuth.instance.signOut();
  //     return true;
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'user-not-found') {
  //       print('No user found for that email.');
  //     } else if (e.code == 'wrong-password') {
  //       print('Wrong password provided for that user.');
  //     }
  //     return false;
  //   }
  //
  // }
}