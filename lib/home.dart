
import 'package:flutter/material.dart';
import 'db.dart';
import 'model.dart';
import 'main.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title, required this.list}) : super(key: key);
  final String title;
  Future<List<Model>> list;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  DbManager dbManager = DbManager();
  getCurrentMessage(){
    setState(() {
      widget.list = dbManager.getModelList();
    });
  }
  getAllMessage(){
    setState(() {
      widget.list = dbManager.getAllModelList();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
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
          Expanded(child: UserList(list: widget.list)),
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
        ]
      ),
    );
  }
}