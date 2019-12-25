import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mocca_tracer/main.dart';

class PhonePage  extends StatefulWidget {
  PhonePage();

  @override
  _PhonePageState createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {
  TextEditingController phoneNum = new TextEditingController();

  void popWindow(){
    Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => MyHomePage(phoneNum: phoneNum.text, title: 'Mocca Mobile Tracer')));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
              title: Text("Mocca Tracer App"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 350.0,
              ),
              Container(
                width: 270.0,
                 child: TextField(
                decoration: InputDecoration(
                  labelText: "   enter your phone number",
                  alignLabelWithHint: true,
                  ),
                maxLength: 10,
                maxLengthEnforced: true,
                controller: phoneNum,
                onEditingComplete: () => popWindow(),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}