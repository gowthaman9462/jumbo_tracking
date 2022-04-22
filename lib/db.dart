import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'model.dart';

class DbManager {
  late Database _database;

  Future openDb() async {
    _database = await openDatabase("db_v1.db",
        version: 1, onCreate: (Database db, int version) async {
      await db.execute(
        'CREATE TABLE Test (id INTEGER PRIMARY KEY autoincrement, name TEXT, lat TEXT, lon TEXT, time TEXT)'
      );
    });
    return _database;
  }

  Future insertModel(Model model) async {
    await openDb();
    return await _database.insert('Test', model.toJson());
  }

  Future<List<Model>> getModelList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.rawQuery("SELECT name, lat, lon, time FROM Test where id in (select max(id) from Test GROUP BY name) order by id DESC");

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
    final List<Map<String, dynamic>> maps = await _database.rawQuery("SELECT name, lat, lon, time FROM Test order by id DESC");
    return List.generate(maps.length, (i) {
      return Model(
        name: maps[i]['name'],
        lat: maps[i]['lat'],
        lon: maps[i]['lon'],
        time: maps[i]['time']
      );
    });
  }
  
}