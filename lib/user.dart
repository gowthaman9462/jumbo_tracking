
import 'package:flutter/material.dart';
import 'db.dart';
import 'model.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _UserState createState() => _UserState();
}

class _UserState extends State<UserPage> {
  DbManager dbManager = DbManager();
  late Future<List<User>> userList = dbManager.getUserList();
  late List<User> user;
  TextEditingController _newUser = TextEditingController();

  deleteUser(name) async{
    dbManager.deleteUser(User(name: name));
    setState(() {
      userList = dbManager.getUserList();
    });
  }

  insertUser(name) async{
    var nameText = name.text;
    var check = await dbManager.checkUser(User(name: nameText));
    if(nameText != "" && (check[0]["count(id)"] != 1)){
      dbManager.insertUser(User(name: nameText));
      setState(() {
        userList = dbManager.getUserList();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: Container(
                      height: 180,
                      color: Colors.white,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                              child: TextField(
                                controller: _newUser,
                                keyboardType: const TextInputType.numberWithOptions(),
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'User Phone',
                                ),
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    child: const Text('Close', style:TextStyle(color: Colors.red),),
                                    onPressed: () => {
                                      Navigator.pop(context),
                                      _newUser.text = "",
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Add',style:TextStyle(color: Colors.black),),
                                    onPressed: () => {
                                      insertUser(_newUser),
                                      _newUser.text = "",
                                      Navigator.pop(context)
                                    },
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
        
      ),
      body: Center(
        child: Scaffold(
          body: FutureBuilder(
            future: userList,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                user = snapshot.data as List<User>;
                return ListView.builder(
                  itemCount: user.length,
                  itemBuilder: (context, index) {
                    User _model = user[index];
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
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  deleteUser(_model.name);
                                },
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
        )
      ),
    );
  }
}