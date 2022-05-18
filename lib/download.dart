import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'db.dart'; 

class DownloadPage extends StatefulWidget {
  const DownloadPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _DownloadState createState() => _DownloadState();
}

class _DownloadState extends State<DownloadPage> {
  DbManager dbManager = DbManager();
  late String start = "Start Date";
  late String stop = "End Date";
  List<String> type_ = [ "day", "week", "month", "date"];
  late List<List> transList;
  String value_ = "day";
  DateTime startDate = DateTime.utc(1989, 11, 9);
  DateTime stopDate = DateTime.utc(1989, 11, 9);
  date(){
    if (value_ == "date"){
      return Form(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(9.0),
                child:OutlinedButton(
                  onPressed: () {
                      DatePicker.showDatePicker(context,
                        showTitleActions: true,
                        minTime: DateTime(2000, 1, 1),
                        maxTime: DateTime.now(), 
                        onChanged: (date) {
                          setState(() {
                            start = timeString(date);
                            startDate = date;
                          });
                        }, 
                        onConfirm: (date) {
                          setState(() {
                            start = timeString(date);
                            startDate = date;
                          });
                        }, 
                        currentTime: DateTime.now(), 
                        locale: LocaleType.en);
                  },
                  child: Text(
                      start.split(" ")[0],
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  )
                )
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: OutlinedButton(
                  
                  onPressed: () {
                      DatePicker.showDatePicker(context,
                        showTitleActions: true,
                        minTime: startDate,
                        maxTime: DateTime.now(), 
                        onChanged: (date) {
                          setState(() {
                            stop = timeString(date);
                            stopDate = date;
                          });
                        }, 
                        onConfirm: (date) {
                          setState(() {
                            stop = timeString(date);
                            stopDate = date;
                          });
                        }, 
                        currentTime: DateTime.now(), 
                        locale: LocaleType.en);
                  },
                  child: Text(
                    stop.split(" ")[0],
                    style: const TextStyle(fontWeight: FontWeight.bold,
                    color: Colors.black),
                  )
                )
              ),
            )
          ]
        ),
      );
    }
    return Container(
      width: 400
    );
  }

  timeString(now,[type_ = false]){
    String convertedDateTime;
    if (type_){
      convertedDateTime = "${now.year.toString()}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}_${now.hour.toString().padLeft(2,'0')}.${now.minute.toString().padLeft(2,'0')}";
    }
    else{
      convertedDateTime = "${now.year.toString()}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')} ${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}";
    }
    return convertedDateTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title)
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: const Text('Today'),
            leading: Radio<String>(
              value: type_[0],
              groupValue: value_,
              onChanged: (value) {
                setState(() {
                  value_ = value!;
                });
                print(value_);
              },
            ),
            onTap: (){
              setState(() {
                value_ = "day";
              });
              print(value_);
            },
          ),
          ListTile(
            title: const Text('Last Week'),
            leading: Radio<String>(
              value: type_[1],
              groupValue: value_,
              onChanged: (value) {
                setState(() {
                  value_ = value!;
                });
                print(value_);
              },
            ),
            onTap: (){
              setState(() {
                value_ = "week";
              });
              print(value_);
            },
          ),
          ListTile(
            title: const Text('Last Month'),
            leading: Radio<String>(
              value: type_[2],
              groupValue: value_,
              onChanged: (value) {
                setState(() {
                  value_ = value!;
                });
                print(value_);
              },
            ),
            onTap: (){
              setState(() {
                value_ = "month";
              });
              print(value_);
            },
          ),
          ListTile(
            title: const Text('Date'),
            leading: Radio<String>(
              value: type_[3],
              groupValue: value_,
              onChanged: (value) {
                setState(() {
                  value_ = value!;
                });
                print(value_);
              },
            ),
            onTap: (){
              setState(() {
                value_ = "date";
              });
              print(value_);
            },
          ),
          date(),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DownloadView(value_: value_,startDate: startDate,stopDate: stopDate,))
              );
              // exportCSV(value_, startDate, stopDate);
            },
            child: const Text(
              'View',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          
        ],
      )
    );
  }
}


class DownloadView extends StatefulWidget {
  DownloadView({Key? key,required this.value_, required this.startDate, required this.stopDate}) : super(key: key);
  late String value_;
  late DateTime startDate;
  late DateTime stopDate;
  List<List> reportList = [];
  @override
  _DownloadViewState createState() => _DownloadViewState();
}

class _DownloadViewState extends State<DownloadView> {
  DbManager dbManager = DbManager();
  timeString(now,[type_ = false]){
    String convertedDateTime;
    if (type_){
      convertedDateTime = "${now.year.toString()}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}_${now.hour.toString().padLeft(2,'0')}.${now.minute.toString().padLeft(2,'0')}";
    }
    else{
      convertedDateTime = "${now.year.toString()}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')} ${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}";
    }
    return convertedDateTime;
  }

  exportList(value_,startDate,stopDate) async{
    List<List> transList = [];
    if(value_ == "day"){
      startDate = DateTime.now().subtract(const Duration(days:1));
      stopDate = DateTime.now();
    }
    else if(value_ == "week") {
      startDate = DateTime.now().subtract(const Duration(days:7));
      stopDate = DateTime.now();
    }
    else if(value_ == "month") {
      startDate = DateTime.now().subtract(const Duration(days:30));
      stopDate = DateTime.now();
    }
    stopDate = stopDate.add(const Duration(days:1));
    transList = await dbManager.getList(timeString(startDate), timeString(stopDate));
    setState((){
      widget.reportList = transList;  
    });
  }

  exportCSV() async{
    print(widget.reportList.length);
    widget.reportList.insert(0, ["Name","Latitude","Longitude","Updated at"]);
    String csv = const ListToCsvConverter().convert(widget.reportList);
    createFolder("Jumbo_Tracking", csv);
  }

  createFolder(String folderName, String csv) async {
    var status = await Permission.manageExternalStorage.status;
    if (status.isDenied) {
      await Permission.manageExternalStorage.request();
    }
    if (await Permission.storage.isRestricted) {
      await Permission.manageExternalStorage.request();
    }
    if (status.isGranted) {
      Directory('/storage/emulated/0/$folderName').create(recursive: true);
      var pathCount = "";
      var count = 0;
      var filePath = '/storage/emulated/0/$folderName/${timeString(DateTime.now(),true)}$pathCount.csv';
      while(File(filePath).existsSync()) {
        count += 1;
        pathCount = "($count)";
        filePath = '/storage/emulated/0/$folderName/${timeString(DateTime.now(),true)}$pathCount.csv';
      }
      final file = await File(filePath).create();
      file.writeAsString(csv);
      Navigator.pop(context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    exportList(widget.value_, widget.startDate, widget.stopDate);
    late Widget widget_;
    if(widget.reportList.length > 0){
      widget_ = Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
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
          Expanded(
            child: ListView.builder(
              itemCount: widget.reportList.length,
              itemBuilder:(context, index) {
                return ListTile(
                  title: Card(
                    color: const Color.fromARGB(255, 174, 255, 177),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            widget.reportList[index][0],
                            style: const TextStyle(fontSize: 15, color: Colors.black,fontWeight: FontWeight.bold),
                          ),
                          Text(
                            double. parse(widget.reportList[index][1]).toStringAsFixed(2),
                            style: const TextStyle(fontSize: 15, color: Colors.black),
                          ),
                          Text(
                            double. parse(widget.reportList[index][2]).toStringAsFixed(2),
                            style: const TextStyle(fontSize: 15, color: Colors.black),
                          ),
                          Text(
                            widget.reportList[index][3],
                            style: const TextStyle(fontSize: 15, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  )
                );
              }
            ),
          ),
        ]
      );
    }
    else{
      widget_ = const Padding(
        padding: EdgeInsets.all(26.0),
        child: SizedBox(
          height: 800,
          width: 400,
          child: Text(
            "No data found",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,

          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Report",
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              exportCSV();
            }
          )
        ],
      ),
      body: widget_
    );
  }
}