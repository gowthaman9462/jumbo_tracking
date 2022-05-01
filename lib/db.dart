import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'model.dart';

class DbManager {
  late Database _database;

  Future openDb() async {
    _database = await openDatabase("globus_bd_v1.db",
        version: 1, onCreate: (Database db, int version) async {
      await db.execute(
        'CREATE TABLE Trans (id INTEGER PRIMARY KEY autoincrement, name TEXT, lat TEXT, lon TEXT, time TEXT);'
      );
      await db.execute(
        'CREATE TABLE User (id INTEGER PRIMARY KEY autoincrement, name TEXT);'
      );

    });
    return _database;
  }

  Future insertModel(Model model) async {
    await openDb();
    return await _database.insert('Trans', model.toJson());
  }


  Future<List<Model>> getModelList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.rawQuery("SELECT name, lat, lon, time FROM Trans where id in (select max(id) from Trans GROUP BY name) order by id DESC");

    return List.generate(maps.length, (i) {
      return Model(
        name: maps[i]['name'],
        lat: maps[i]['lat'],
        lon: maps[i]['lon'],
        time: maps[i]['time']
      );
    });
  }
  Future<List<Model>> getAllModelList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.rawQuery("SELECT name, lat, lon, time FROM Trans order by id DESC");
    return List.generate(maps.length, (i) {
      return Model(
        name: maps[i]['name'],
        lat: maps[i]['lat'],
        lon: maps[i]['lon'],
        time: maps[i]['time']
      );
    });
  }

  Future<List<List>> getList(startDate, stopDate) async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.rawQuery("SELECT name, lat, lon, time FROM Trans WHERE time between date('"+startDate+"') and date('"+stopDate+"');");
    return List.generate(maps.length, (i) {
      return[maps[i]['name'],maps[i]['lat'],maps[i]['lon'],maps[i]['time']]; 
    });
  }

  Future insertUser(User user) async {
    await openDb();
    return await _database.insert('User', user.toJson());
  }

  Future deleteUser(User user) async {
    await openDb();
    return await _database.delete("User",where: "name = "+user.name);
  }

  Future<List<User>> getUserList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.rawQuery("SELECT name FROM User");
    return List.generate(maps.length, (i) {
      return User(name: maps[i]["name"]);
    });
  }

  Future<List> checkUser(User user) async{
    await openDb();
    var query = "SELECT count(id) FROM User WHERE name = '"+ user.name+"'";
    final List result = await _database.rawQuery(query);
    return result;
  }
  
}