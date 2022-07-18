import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:telephony/telephony.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'home.dart';
import 'model.dart';
import 'db.dart';
import 'map.dart';
import 'user.dart';
import 'download.dart';

void main() async {
  runApp(MyApp());
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
var iOS = const IOSInitializationSettings();
var initSetttings = InitializationSettings(android: android, iOS: iOS);

onBackgroundMessage(SmsMessage msg) async {
  final DbManager dbManager = DbManager();
  List check;
  var name;
  Model model;
  name = msg.address!.replaceAll("+91", "");
  check = await dbManager.checkUser(User(name: name));
  if (check[0]["count(id)"] == 1 &&
      msg.body!.split(",")[0].trim().toLowerCase() == "detection") {
    model = Model(
      name: msg.address!.replaceAll("+91", ""),
      lat: msg.body!.split(",")[2],
      lon: msg.body!.split(",")[3],
      time: DateFormat('yyyy-MM-dd\nHH:mm').format(DateTime.now()),
    );
    dbManager.insertModel(model);
    showNotification(model.name);
  }
}

showNotification(String number) async {
  flutterLocalNotificationsPlugin.initialize(
    initSetttings,
    onSelectNotification: (payload) => {main()},
  );
  var android = const AndroidNotificationDetails('channel id', 'channel NAME',
      channelDescription: 'CHANNEL DESCRIPTION',
      priority: Priority.high,
      importance: Importance.max);
  var iOS = const IOSNotificationDetails();
  var platform = NotificationDetails(android: android, iOS: iOS);
  await flutterLocalNotificationsPlugin.show(
      0, 'Jumbo Tracking', 'New Update from $number', platform,
      payload: '');
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jumbo Tracking',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const MyHomePage(title: 'Jumbo Tracking'),
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
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final DbManager dbManager = DbManager();
  late Model model;
  late List<Model> modelList;
  late Future<List<Model>> list = dbManager.getModelList();
  final telephony = Telephony.instance;
  void initState() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = const IOSInitializationSettings();
    var initSetttings = InitializationSettings(android: android, iOS: iOS);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: selectNotification);
    getIncomingMessage();
    setmarker();
    super.initState();
  }

  void selectNotification(String? payload) {
    main();
    setState(() {
      _selectedIndex = 1;
    });
  }

  getIncomingMessage() async {
    telephony.listenIncomingSms(
      onNewMessage: onMessage,
      onBackgroundMessage: onBackgroundMessage,
    );
  }

  onMessage(SmsMessage msg) async {
    List check;
    var name;
    name = msg.address!.replaceAll("+91", "");
    check = await dbManager.checkUser(User(name: name));
    if (check[0]["count(id)"] == 1 &&
        msg.body!.split(",")[0].trim().toLowerCase() == "detection") {
      model = Model(
        name: msg.address!.replaceAll("+91", ""),
        lat: msg.body!.split(",")[2],
        lon: msg.body!.split(",")[3],
        time: DateFormat('yyyy-MM-dd\nHH:mm').format(DateTime.now()),
      );
      dbManager.insertModel(model);
      setState(() {
        list = dbManager.getModelList();
        _selectedIndex = _selectedIndex;
      });
      setmarker();
      showNotification(model.name);
    }
  }

  // getIncomingMessage() async {
  //   SmsReceiver receiver = SmsReceiver();
  //   List check;
  //   var name;
  //   receiver.onSmsReceived.listen((SmsMessage msg) async => {
  //         name = msg.address.replaceAll("+91", ""),
  //         check = await dbManager.checkUser(User(name: name)),
  //         print(name),
  //         print(check[0]["count(id)"]),
  //         print(msg.body.split(",")[0].trim()),
  //         if (check[0]["count(id)"] == 1 &&
  //             msg.body.split(",")[0].trim().toLowerCase() == "jt")
  //           {
  //             model = Model(
  //                 name: msg.address.replaceAll("+91", ""),
  //                 lat: msg.body.split(",")[1],
  //                 lon: msg.body.split(",")[2],
  //                 time: DateFormat('yyyy-MM-dd\nHH:mm').format(msg.date)),
  //             dbManager.insertModel(model),
  //             print(msg.address),
  //             print(msg.body.split(",")[0].trim().toLowerCase()),
  //             print(msg.body.split(",")),
  //             print(msg.date),
  //             setState(() {
  //               list = dbManager.getModelList();
  //               _selectedIndex = _selectedIndex;
  //             }),
  //             setmarker(),
  //             showNotification(model.name)
  //           }
  //       });
  // }

  showNotification(String number) async {
    var android = const AndroidNotificationDetails('channel id', 'channel NAME',
        channelDescription: 'CHANNEL DESCRIPTION',
        priority: Priority.high,
        importance: Importance.max);
    var iOS = const IOSNotificationDetails();
    var platform = NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(
        0, 'Jumbo Tracking', 'New Update from $number', platform,
        payload: '');
  }

  late Set<Marker> _markers1 = {};

  setmarker() async {
    List<Model> list = await dbManager.getModelList();
    print(list.length);
    Set<Marker> marker_list = {};
    for (int i = 0; i < list.length; i++) {
      marker_list.add(Marker(
        markerId: MarkerId(list[i].name),
        position: LatLng(double.parse(list[i].lat), double.parse(list[i].lon)),
        infoWindow: InfoWindow(title: list[i].name),
        icon: BitmapDescriptor.defaultMarker,
      ));
      setState(() {
        _markers1 = marker_list;
      });
    }
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setmarker();
    setState(() {
      list = dbManager.getModelList();
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    StatefulWidget widget_;
    if (_selectedIndex == 0) {
      widget_ = HomePage(title: "Home", list: list);
    } else if (_selectedIndex == 1) {
      widget_ = MapPage(list: _markers1);
    } else if (_selectedIndex == 2) {
      widget_ = const UserPage(title: "Users");
    } else {
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
