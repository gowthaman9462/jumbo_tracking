import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

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
        primarySwatch: Colors.blue,
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
  late Future<List<Model>> list;
  
  void initState(){
    getIncomingMessage();
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
        })
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
      ),
      body:Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
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
          Expanded(child: UserList(list: dbManager.getModelList()))
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
                    color: const Color.fromARGB(255, 189, 232, 252),
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