
import 'dart:async';
import 'package:Globus/home.dart';
import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'model.dart';
import 'db.dart';
import 'map.dart';
import 'user.dart';
import 'download.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jumbo Tracking',
      theme: ThemeData(
        primarySwatch: Colors.green
      ),
      home: const MyHomePage(title:'Jumbo Tracking'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();

}


class _MyHomePageState extends State<MyHomePage> {
  final DbManager dbManager = DbManager();
  late Model model;
  late List<Model> modelList;
  late Future<List<Model>> list = dbManager.getModelList();
  void initState(){
    getIncomingMessage();
    setmarker();
    super.initState();
  }

  getIncomingMessage() async{
    SmsReceiver receiver = SmsReceiver();
    List check;
    var name;
    receiver.onSmsReceived.listen((SmsMessage msg) async => {
      name = msg.address.replaceAll("+91", ""),
      check = await dbManager.checkUser(User(name: name)),
      print(name),
      print(check[0]["count(id)"]),
      print(msg.body.split(",")[0].trim()),
      if (check[0]["count(id)"] == 1 && msg.body.split(",")[0].trim().toLowerCase() == "jt"){
        model = Model(
          name: msg.address.replaceAll("+91", ""),
          lat:msg.body.split(",")[1] , 
          lon:msg.body.split(",")[2], 
          time:DateFormat('yyyy-MM-dd\nHH:mm').format(msg.date)
        ),
        dbManager.insertModel(model),
        print(msg.address),
        print(msg.body.split(",")[0].trim().toLowerCase()),
        print(msg.body.split(",")),
        print(msg.date),
        setState(() {
          list = dbManager.getModelList();
          _selectedIndex = _selectedIndex;
        }),
        setmarker()
      }
    });
  }

  late Set<Marker> _markers1 = {};
  
  setmarker() async{
    List<Model> list = await dbManager.getModelList();
    Set<Marker> marker_list = {};
    for(int i = 0; i< list.length; i++)
    {
      print("         ");
      print(list[i].name);
      print("          ");
      marker_list.add(
        Marker(
          markerId: MarkerId(list[i].name), 
          position: LatLng(double.parse(list[i].lat),double.parse(list[i].lon)),
          infoWindow: InfoWindow(
            title: list[i].name
          ),
          icon: BitmapDescriptor.defaultMarker,
        )
      );
      setState(() {
        _markers1 = marker_list;
      });
    }
  }

  int _selectedIndex = 0;
  
  void _onItemTapped(int index) {
    
    setState(() {
      _selectedIndex = index;
    });
  }
  


  @override
  Widget build(BuildContext context) {
    var widget_;
    if(_selectedIndex == 0){
      widget_ = HomePage(title: "Home", list: list);
    }
    else if(_selectedIndex == 1){
      widget_ = MapPage(list: _markers1);
    }
    else if(_selectedIndex == 2){
      widget_ = const UserPage(title: "Users");
    }
    else{
      widget_ = const DownloadPage(title: "Report");
    }
    return Scaffold(
      body: widget_,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notes),
            label: 'Report',
            backgroundColor: Colors.green,
          ),
        ],
        backgroundColor: Colors.green,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Color.fromARGB(255, 58, 58, 58),
        onTap: _onItemTapped,
      ),
    );
  }
}

// flutter run --no-sound-null-safety