import 'package:flutter/material.dart';
import 'model.dart';
import 'db.dart';

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
                    color: const Color.fromARGB(255, 174, 255, 177),
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
                            double.parse(_model.lat).toStringAsFixed(2),
                            style: const TextStyle(fontSize: 15, color: Colors.black),
                          ),
                          Text(
                            double.parse(_model.lon).toStringAsFixed(2),
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
