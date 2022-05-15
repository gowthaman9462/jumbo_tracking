
import 'package:flutter/material.dart';
import 'db.dart';
import 'model.dart';
import 'userlist.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title, required this.list}) : super(key: key);
  final String title;
  Future<List<Model>> list;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  DbManager dbManager = DbManager();
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if(index==0){
      setState(() {
        widget.list = dbManager.getModelList();
      });
    }
    else{
      setState(() {
        widget.list = dbManager.getAllModelList();
      });
    }
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
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
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
        ]
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: "Current",
            backgroundColor: Colors.yellow, 
            icon: Container(
              height: 0.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Container(
              height: 0.0,
            ),
            label: "History",
            backgroundColor: Colors.yellow,
          ),
        ],
        backgroundColor: Color.fromARGB(255, 216, 216, 216),
        selectedIconTheme: IconThemeData(opacity: 0.0, size: 0),
        unselectedIconTheme: IconThemeData(opacity: 0.0, size: 0),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Color.fromARGB(255, 74, 74, 74),
        selectedLabelStyle: const TextStyle(decoration: TextDecoration.underline, fontSize: 20, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        onTap: _onItemTapped,
      ),
    );
  }
}