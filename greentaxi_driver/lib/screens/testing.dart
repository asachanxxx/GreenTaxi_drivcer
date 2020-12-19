import 'package:flutter/material.dart';
import 'package:greentaxi_driver/dataprovider/SystemConfigs.dart';
import 'package:greentaxi_driver/shared/repository/companyrepository.dart';

class TestTheCode extends StatefulWidget {
  static const String Id = 'testing';
  @override
  _TestTheCodeState createState() => _TestTheCodeState();
}

class _TestTheCodeState extends State<TestTheCode> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget> [

        Row(
          children: <Widget> [
              RaisedButton(
                color: Colors.black26,
                textColor: Colors.white,
                child: Text("Data Repo Check"),
                onPressed: () async{


                },
              )

          ],
        )

      ],
    );
  }
}
