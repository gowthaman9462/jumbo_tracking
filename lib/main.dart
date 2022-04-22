import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'model.dart';
import 'db.dart';

void main() => runApp(MyApp());
var user_list = ['6382185320', '9942999966','6379090933','8270680417'];

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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
    receiver.onSmsReceived.listen((SmsMessage msg) async => {
      if (user_list.contains(msg.body.split(",")[0])){
        model = Model(
          name: msg.body.split(",")[0], 
          lat:msg.body.split(",")[1] , 
          lon:msg.body.split(",")[2], 
          time:DateFormat('yyyy-MM-dd\nHH:mm').format(msg.date)
        ),
        dbManager.insertModel(
          model
        ),
        print(msg.address),
        print(msg.body.split(",")),
        print(msg.date),
        print("\n\n\n"),
        setState(() {
          list = dbManager.getModelList();
        }),
      },
      setmarker()
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
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = LatLng(11.496057859832861, 77.27676158022257);
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  late Set<Marker> _markers1 = {};
  setmarker() async{
    List<Model> list = await dbManager.getModelList();
    for(int i = 0; i< list.length; i++)
    {
      print("         ");
      print(list[i].name);
      print("          ");
      _markers1.add(
        Marker(
          markerId: MarkerId(list[i].name), 
          position: LatLng(double.parse(list[i].lat),double.parse(list[i].lon)),
          icon: BitmapDescriptor.defaultMarker,
        )
      );
    }
    getCurrentMessage();
  }
  


  @override
  Widget build(BuildContext context) {
    print("\n\n\n\n");
    print(_markers1);
    print("\n\n\n\n");
    return Scaffold(
      body:Column(
        children: <Widget>[
          Container(
            width: 400,
            height: 400,
            child:GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: _center,
                zoom: 8.0,
              ),
              markers: _markers1
            )
          ),
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