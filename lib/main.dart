import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:mocca_tracer/phonePage.dart';

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
      home: PhonePage(),
      // MyHomePage(title: 'Mocca Mobile Tracer'), 
      // Test1(),  
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title,this.phoneNum}) : super(key: key);
  final String title;
  final String phoneNum;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool active =false;
  int duration = 5;
  int counti = 0;
  double longitude;
  double latitude;
  int statusCode;
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
         setState(() {
           latitude = position.latitude;
           longitude = position.longitude;
         });

         //                 this three prints are meant for progress check
         print(position); //
        //  print(count);//
         print(duration);//
        //  count++;//        

        var now = DateTime.now().toIso8601String();
        String num = widget.phoneNum;
        String url = 'http://159.89.225.231:7770/api/sms';// please type your server url here and thats a test server https://jsonplaceholder.typicode.com/posts
        Map<String, String> headers = {"Content-Type": "application/json"}; // this is the message header, i picked it but you can change it
        String json = '{trackingTime: "$now", clientId: 1, sender: 972549434350, alt:0,  lon: $longitude, lat: $latitude, azimuthDeg: 0.8 }'; //ya yo get it
        Response response = await post(url, headers: headers , body: json );//as it looks like
        //                                         again progras check and post status
        print(now);
        print(num);
        print(response.statusCode);
         setState(() {
           statusCode = response.statusCode;
         });
        print("json file $json and statuscode $statusCode");
        if(statusCode<300){
        counti=0;
        }else{
          if(counti<3){
          counti++;
          print(counti);
          }else{
                    //the SMS part, you can change the message here
                 String _result = await FlutterSms
                   .sendSMS(message: "where sorry but the server is down", recipients: ['0547551536'])
                   .catchError((onError) {
                 print(onError);
               });
                 print(_result);
                 exit(0);
               }
          }
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


  // Future<bool> handleConnection() async{
  //   try{
  //   final result = await InternetAddress.lookup('google.com');
  //   if(result.isNotEmpty && result[0].rawAddress.isNotEmpty){
  //   print("connected");
  //   return true;
  //   } else 
  //   return false;
  //   }
  //   on SocketException catch(_){
  //     return false;
  //     }
  // }

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
          height: 170,
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
               SizedBox(
              height: 100,
              width: 160,
              child: Center(
                child: Text('longitude: $longitude   latitude: $latitude   status code: $statusCode'),
              ),
             ),
      ],
    ),
  ),
);
  }
}
