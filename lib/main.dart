
import 'dart:async';
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
      title: 'Project V1',
      theme: ThemeData(
        primarySwatch: Colors.yellow
      ),
      home: const MyHomePage(title: 'Project'),
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
      if (check[0]["count(id)"] == 1 && msg.body.split(",")[0].trim() == "globus"){
        model = Model(
          name: msg.address.replaceAll("+91", ""),
          lat:msg.body.split(",")[1] , 
          lon:msg.body.split(",")[2], 
          time:DateFormat('yyyy-MM-dd\nHH:mm').format(msg.date)
        ),
        dbManager.insertModel(model),
        print(msg.address),
        print(msg.body.split(",")),
        print(msg.date),
        setState(() {
          list = dbManager.getModelList();
        }),
        setmarker()
      }
    });
  }

  getCurrentMessage(){
    setState(() {
      list = dbManager.getModelList();
    });
  }
  getAllMessage(){
    setState(() {
      list = dbManager.getAllModelList();
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
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Globus'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return const UserPage(title: 'Users');
                },
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return const DownloadPage(title: "Download",);
                },
              ));
            },
          ),
        ],
      ),
      body:Column(
        children: <Widget>[
          MapPage(list: _markers1),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:<Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.black,
                  ),
                  onPressed: (){ 
                    getCurrentMessage();
                  },
                  child: const Text('Current',style: TextStyle(fontSize: 18, color: Colors.black,fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.black,
                  ),
                  onPressed: (){ 
                    getAllMessage();
                  },
                  child: const Text('All',style: TextStyle(fontSize: 18, color: Colors.black,fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const <Widget>[
                    Text(
                      " User  ID ",
                      style: TextStyle(fontSize: 18, color: Colors.black,fontWeight: FontWeight.bold),
                    ),
                    Center(
                      child: Text(
                        " Lat",
                        style: TextStyle(fontSize: 18, color: Colors.black,fontWeight: FontWeight.bold ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "Lon",
                        style: TextStyle(fontSize: 18, color: Colors.black,fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      "Updated at",
                      style: TextStyle(fontSize: 18, color: Colors.black,fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: UserList(list: list))
        ]
      )
    );
  }
}

class UserList extends StatefulWidget {
  const UserList({Key? key, required this.list}) : super(key: key);
  final Future<List<Model>> list;
  @override
  _UserList createState() => _UserList();
}

class _UserList extends State<UserList> {
  final DbManager dbManager = DbManager();

  late Model model;
  late List<Model> modelList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: widget.list,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            modelList = snapshot.data as List<Model>;
            return ListView.builder(
              itemCount: modelList.length,
              itemBuilder: (context, index) {
                Model _model = modelList[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: const Color.fromARGB(255, 248, 255, 151),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            _model.name,
                            style: const TextStyle(fontSize: 15, color: Colors.black,fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _model.lat,
                            style: const TextStyle(fontSize: 15, color: Colors.black),
                          ),
                          Text(
                            _model.lon,
                            style: const TextStyle(fontSize: 15, color: Colors.black),
                          ),
                          Text(
                            _model.time,
                            style: const TextStyle(fontSize: 15, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}



// flutter run --no-sound-null-safety