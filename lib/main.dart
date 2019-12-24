import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:flutter_sms/flutter_sms.dart';

//TO-DO 1)get the owner phone number 2)save it localy  3)change the resipions with the real number 4)maybe do a check number part

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mocca Mobile Tracer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Mocca Mobile Tracer'), 
      // Test1(),  
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool active =false;
  int duration = 5;
  int counti = 0;
  final durationNum = TextEditingController();


  gps(bool isActive) async{
    String status = 'GeolocationStatus.granted';
    int count = 0; //
    GeolocationStatus geolocationStatus  = await Geolocator().checkGeolocationPermissionStatus();
    //                           check if you have allowed GPS permision or not
    // print(geolocationStatus); //

    if(geolocationStatus.toString() == status){
      if(active == false && isActive == true){
        active = true;

       Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
       while(active){
         Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
         double latitude = position.latitude;
         double longitude = position.longitude;
         //                 this three prints are meant for progress check
         print(position); //
        //  print(count);//
         print(duration);//
        //  count++;//        

        if(await handleConnection()){ //the SMS part
        String url = 'http://159.89.225.231:7770/api/sms';// please type your server url here
        Map<String, String> headers = {"GPS_Coordinanet": "Mocca_Tracer_app/json"}; // this is the message header, i picked it but you can change it
        String json = '{latitude: $latitude and longitude: $longitude }'; //ya yo get it
        Response response = await post(url, headers: headers , body: json );//as it looks like
        print(response.statusCode);
        }else{
          if(counti<3){
          counti++;
          print(counti);
          }else{
                    //the SMS part, you can change the message here
                 String _result = await FlutterSms
                   .sendSMS(message: "you dont have internet connection", recipients: ['05237369797'])
                   .catchError((onError) {
                 print(onError);
               });
                 print(_result);
                 exit(0);
               }
          }
        //                                         again progras check and post status
        // int statusCode = response.statusCode; //
        // print("jason file $json and statuscode $statusCode"); //
        
        //wait an set amount of time for your picking.  you can change it to minutes or hours by switching the seconds with......(ctrl + space)
         await Future.delayed(Duration(seconds: duration), );
                    }
       }
       else{
         if(active == true && isActive == false){
           setState(() {
                      active=false;
           });
         }
       }
    }
    else{
      //                         if you dont have GPS then an alart dialog pops
      return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Unable to use location'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('You havent given permission to this app to use your location'),
              Text('please go to your settings and do it manually'),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
    }
  }


  Future<bool> handleConnection() async{
    try{
    final result = await InternetAddress.lookup('google.com');
    if(result.isNotEmpty && result[0].rawAddress.isNotEmpty){
    print("connected");
    counti=0;
    return true;
    } else 
    return false;
    }
    on SocketException catch(_){
      return false;
      }
  }

  setDuration(){
    setState(() {
      duration = int.parse(durationNum.text);
    });
  }
   
  @override
  Widget build(BuildContext context) {
return Scaffold(
  appBar: AppBar(
    title: Text("Mocca Tracer App"),
  ) ,
  body: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 260,
          width: 10,
        ),
        RaisedButton(
          onPressed: () => gps(true),
          child: Text('Turn on'),
        ),
        SizedBox(
          height: 15,
          width: 12,
        ),
        RaisedButton(
          onPressed: () => gps(false),
          child: Text('Turn off'),
        ),
        SizedBox(
              height: 15,
              width: 10,
            ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 15,
              width: 10,
            ),
            Container(
              width: 207,
              child: TextField(
                decoration: InputDecoration(
                  labelText: "   Enter amount of seconds",    //right now its on secs, you can change it
                  alignLabelWithHint: true,

                  ),
                                      //max numbers that you can enter = (maxLength: 3,)
                maxLength: 3,
                maxLengthEnforced: true,
                controller: durationNum,
                onEditingComplete: () => setDuration(),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly
                  ],
                ),
            ),
          ],
        ),
      ],
    ),
  ),
);
  }
}
