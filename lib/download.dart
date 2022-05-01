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

  exportCSV(value_,startDate,stopDate) async{
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
    print(timeString(startDate));
    print(timeString(stopDate));
    transList = await dbManager.getList(timeString(startDate), timeString(stopDate));
    print(transList.length);
    transList.insert(0, ["Name","Latitude","Longitude","Updated at"]);
    String csv = const ListToCsvConverter().convert(transList);
    createFolder("globus", csv);
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
      final file = await File('/storage/emulated/0/$folderName/${timeString(DateTime.now(),true)}.csv').create();
      file.writeAsString(csv);
      Navigator.pop(context);
    }
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
          ),
          date(),
          ElevatedButton(
            onPressed: () {
              exportCSV(value_, startDate, stopDate);
            },
            child: const Text(
              'Download',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          
        ],
      )
    );
  }
}

