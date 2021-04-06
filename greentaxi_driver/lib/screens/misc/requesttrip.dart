/*
 * Copyright 2018, 2019, 2020 Dooboolab.
 *
 * This file is part of Flutter-Sound.
 *
 * Flutter-Sound is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License version 3 (LGPL-V3), as published by
 * the Free Software Foundation.
 *
 * Flutter-Sound is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Flutter-Sound.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greentaxi_driver/globalvariables.dart';
import 'package:greentaxi_driver/models/address.dart';
import 'package:greentaxi_driver/models/customer.dart';
import 'package:greentaxi_driver/shared/repository/firebase_service.dart';
import 'package:greentaxi_driver/widgets/BrandDivider.dart';
import 'package:greentaxi_driver/widgets/ProgressDialog.dart';
import 'package:greentaxi_driver/widgets/predictiontile.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

/*
 * This is an example showing how to record to a Dart Stream.
 * It writes all the recorded data from a Stream to a File, which is completely stupid:
 * if an App wants to record something to a File, it must not use Streams.
 *
 * The real interest of recording to a Stream is for example to feed a
 * Speech-to-Text engine, or for processing the Live data in Dart in real time.
 *
 */

///
typedef _Fn = void Function();

/// Example app.
class SimpleRecorder extends StatefulWidget {

  static const String Id = 'soundrecxx';

  @override
  _SimpleRecorderState createState() => _SimpleRecorderState();
}

class _SimpleRecorderState extends State<SimpleRecorder> {
  FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;
  String _mPath;
  bool recordStarted = false;
  IconData recorderIcon = Icons.mic;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  @override
  void initState() {
    // Be careful : openAudioSession return a Future.
    // Do not access your FlutterSoundPlayer or FlutterSoundRecorder before the completion of the Future
    print("initState()");
    _mPlayer.openAudioSession().then((value) {
      print("openAudioSession()");
      setState(() {
        _mPlayerIsInited = true;
      });
    });
    openTheRecorder().then((value) {
      print("openTheRecorder()");
      setState(() {
        _mRecorderIsInited = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    stopPlayer();
    _mPlayer.closeAudioSession();
    _mPlayer = null;

    stopRecorder();
    _mRecorder.closeAudioSession();
    _mRecorder = null;
    if (_mPath != null) {
      var outputFile = File(_mPath);
      if (outputFile.existsSync()) {
        outputFile.delete();
      }
    }
    super.dispose();
  }



  Future<void> openTheRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }

    var tempDir = await getTemporaryDirectory();
    _mPath = '${tempDir.path}/flutter_sound_example.aac';
    var outputFile = File(_mPath);
    if (outputFile.existsSync()) {
      await outputFile.delete();
    }
    await _mRecorder.openAudioSession();
    _mRecorderIsInited = true;
  }

  // ----------------------  Here is the code for recording and playback -------

  Future<void> record() async {
    assert(_mRecorderIsInited && _mPlayer.isStopped);
    await _mRecorder.startRecorder(
      toFile: _mPath,
      codec: Codec.aacADTS,
    );
    setState(() {});
  }

  Future<void> stopRecorder() async {
    await _mRecorder.stopRecorder();
    _mplaybackReady = true;
  }

  void play() async {
    assert(_mPlayerIsInited &&
        _mplaybackReady &&
        _mRecorder.isStopped &&
        _mPlayer.isStopped);
    await _mPlayer.startPlayer(
        fromURI: _mPath,
        codec: Codec.aacADTS,
        whenFinished: () {
          setState(() {});
        });
    setState(() {});
  }

  Future<void> stopPlayer() async {
    await _mPlayer.stopPlayer();
  }

// ----------------------------- UI --------------------------------------------

  _Fn getRecorderFn() {
    if (!_mRecorderIsInited || !_mPlayer.isStopped) {
      return null;
    }
    return _mRecorder.isStopped
        ? record
        : () {
      stopRecorder().then((value) => setState(() {}));
    };
  }

  _Fn getPlaybackFn() {
    if (!_mPlayerIsInited || !_mplaybackReady || !_mRecorder.isStopped) {
      return null;
    }
    return _mPlayer.isStopped
        ? play
        : () {
      stopPlayer().then((value) => setState(() {}));
    };
  }

@override
Widget build(BuildContext context) {

  Widget returnControlMessage(String message1 , String message2 , bool isError){
    return Container(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              new Text(message1 , style: GoogleFonts.roboto(fontSize: 15,color: isError ? Color(0xFFd32f2f) :Color(0xFFff6f00) , fontWeight: FontWeight.bold),),
              SizedBox(height: 10,),
              BrandDivider(),
              SizedBox(height: 10,),
              new Text(message2 , style: GoogleFonts.roboto(fontSize: 15),),
            ],
          ),
        )
    );
  }

  var futureBuilder = new StreamBuilder(
    stream: FirebaseDatabase.instance
        .reference()
        .child('listTree/requestListVoice/')
        .orderByChild('requestedDriverId')
        .equalTo(currentFirebaseUser.uid)
        .onValue,
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      Widget newwidget;

      // if(widget != null)
      // {
      //   newwidget = returnControlMessage(
      //       "Problem with customer List (පාරිභෝගික ලැයිස්තුව)",
      //       "The customer list cannot be shown at the moment. please try later(පාරිභෝගික ලැයිස්තුව මේ මොහොතේ පෙන්විය නොහැක. කරුණාකර පසුව උත්සාහ කරන්න)",
      //       true);
      // }else {


        List<dynamic> list;
        if (snapshot != null) {
          if (snapshot.data != null) {
            if (snapshot.data.snapshot != null) {
              if (snapshot.data.snapshot.value != null) {
                print("point 1");
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    newwidget = returnControlMessage(
                        "Please wait until loading the data (කරුණාකර දත්ත පූරණය වන තෙක් රැඳී සිටින්න)",
                        "", true);
                    break;
                  case ConnectionState.waiting:
                    print("Waiting .........");
                    newwidget = returnControlMessage(
                        "Please wait until loading the data (කරුණාකර දත්ත පූරණය වන තෙක් රැඳී සිටින්න)",
                        "", true);
                    break;
                  default:
                    if (snapshot.hasError)
                      newwidget = returnControlMessage(
                          "Problem when loading saved trip details(ඇතුලත් කරන ලද  චාරිකා ව්ස්තර ලබාගැනීමේ ගැටළුවක් ඇත )",
                          "The customer list cannot be shown at the moment. please try later( චාරිකා ව්ස්තර මේ මොහොතේ පෙන්විය නොහැක. කරුණාකර පසුව උත්සාහ කරන්න)",
                          true);
                    else
                      print("Point 2 Value ${snapshot.data.snapshot.value}");
                    Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
                    list = map.values.toList();
                    print("Key : ${snapshot.data.snapshot.value}");
                    newwidget = ListView.builder(
                      itemCount: list.length, //snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                      print("list[index][phoneNumber] ${list[index]}");

                        return TripTile3(
                        rideId: list[index]['key'],
                          datetime: list[index]['time'],
                        );
                      },
                    );
                }
              } else {
                print("No Customers .........");
                newwidget = returnControlMessage(
                    'No Trips Found(කිසිඳු චාරිකාවක්  හමු නොවීය)',
                    'Please Use plus signed button to add your trip(ඔබේ චාරිකාව ඇතුලත් කිරීමට කරුණාකර පහත බොත්තම භාවිතා කරන්න)',
                    false);
              }
            } else {
              print("No Customers .........");
              newwidget = returnControlMessage(
                  'No Trips Found(කිසිඳු චාරිකාවක් හමු නොවීය)',
                  'Please Use plus signed button to add your trip(ඔබේ චාරිකාව ඇතුලත් කිරීමට කරුණාකර පහත බොත්තම භාවිතා කරන්න)',
                  false);
            }
          } else {
            print("No Customers .........");
            newwidget = returnControlMessage(
                'No Trips Found(කිසිඳු චාරිකාවක්  හමු නොවීය)',
                'Please Use plus signed button to add your trip(ඔබේ චාරිකාව ඇතුලත් කිරීමට කරුණාකර පහත බොත්තම භාවිතා කරන්න)',
                false);

          }
        } else {
          print("No Customers .........");
          newwidget = returnControlMessage(
              'No Trips Found(කිසිඳු චාරිකාවක්  හමු නොවීය)',
              'Please Use plus signed button to add your trip(ඔබේ චාරිකාව ඇතුලත් කිරීමට කරුණාකර පහත බොත්තම භාවිතා කරන්න)',
              false);

        // }
      }
      return newwidget;
    },
  );

  return Scaffold(
    key: scaffoldKey,
    body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              color: Color(0xFFff6f00),
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    SizedBox(width: 10,),
                    GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back, color: Color(0xFFffffff))
                    ),
                    SizedBox(width: 60,),
                    Expanded(
                      child: Text("Voice trip requests",
                          style: GoogleFonts.roboto(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFffffff))
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 5,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      height: 500,
                      decoration: BoxDecoration(
                        color: Color(0xFFeeeeee),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            width: 1.0, color: Color(0xFFe0e0e0)),
                      ),
                      child: futureBuilder
                  ),
                ],
              ),
            ),
            SizedBox(height: 10,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:<Widget> [
                  FloatingActionButton(
                    heroTag: "btn1",
                    onPressed: () {
                      if (!_mRecorderIsInited || !_mPlayer.isStopped) {

                      } else {
                        if (_mRecorder.isStopped) {
                          record();
                        } else {
                          stopRecorder().then((value) => setState(() {}));
                        }
                      }
                      //Text(_mRecorder.isRecording ? 'Stop' : 'Record'),

                    },
                    child:_mRecorder.isRecording? Icon(Icons.pause): Icon(Icons.mic),
                    backgroundColor: Color(0xFFff6f00),
                  ),
                  SizedBox(width: 20,),
                  FloatingActionButton(
                    heroTag: "btn2",
                    onPressed: () {
                      if (!_mPlayerIsInited || !_mplaybackReady ||
                          !_mRecorder.isStopped) {

                      } else {
                        if (_mPlayer.isStopped) {
                          play();
                        } else {
                          stopPlayer().then((value) => setState(() {}));
                        }
                      }

                    },
                    child:_mPlayer.isPlaying ? Icon(Icons.stop) :Icon(Icons.play_arrow),
                    backgroundColor:_mPlayer.isPlaying ? Color(0xFFff6f00): Color(0xFF616161),
                  ),
                  SizedBox(width: 20,),
                FloatingActionButton(
                  heroTag: "btn3",
                  onPressed: () {
                    if (!_mPlayerIsInited || !_mplaybackReady ||
                        !_mRecorder.isStopped) {

                    } else {
                     ///Audio is ready to be uploaded in this point

                      // if (outputFile.existsSync()) {
                      //   outputFile.delete();
                      // }
                      insertRequestVoice();
                    }

                  },
                  child:Icon(Icons.send),
                  backgroundColor: _mplaybackReady? Color(0xFFff6f00):Color(0xFF616161),
                ),
              ],
            ),

          ],
        ),
      ),
    ),
  );
}


  void insertRequestVoice() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Creating customer.....',
      ),
    );
    try {

      print("Driver name :${currentDriverInfo.fullName}");

      DatabaseReference listUsers = FirebaseDatabase.instance
          .reference()
          .child('listTree/requestListVoice/').push();


      var outputFile = File(_mPath);
      print("Audio File is = ${outputFile.path}" );
      uploadFile(outputFile,listUsers.key);


      Map fullMap = {
        'key':listUsers.key,
        'requestedDriverId': currentFirebaseUser.uid,
        'requestedDriver': currentDriverInfo.fullName,
        'attended': false,
        'completed': false,
        'time': DateTime.now().toString(),
      };


      listUsers.set(fullMap);
    } on FirebaseAuthException catch (e) {
      //Navigator.pop(context);
      if (e.code == 'weak-password') {
        showSnackBar('Oops! The password provided is too weak.');
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showSnackBar('Oops! The account already exists for that email.');
        print('The account already exists for that email.');
      }
    } catch (e) {
      //Navigator.pop(context);
      print(e);
      showSnackBar('Oops! There is a problem! Try again later.');
    }

    Navigator.pop(context);
  }

  void uploadFile(File autioFile,String reqId) async {
    String ImageFileName = reqId+ ".acc";
    try {
      await firebase_storage.FirebaseStorage.instance
          .ref()
          .child('$userAudioPath/$ImageFileName')
          .putFile(autioFile);
      print(
          "Image Upload Done To $userAudioPath/$ImageFileName");
      print("Getting image from web");
      //Navigator.pop(context);
      //getImage();
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print("FirebaseException : ${e.code}");
    }
  }

}
