import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBManager {
  Database _database;

  Future openDb() async {
    if (_database == null) {
      _database = await openDatabase(
        join(await getDatabasesPath(), "socket.db"),
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
            "CREATE TABLE socket(id INTEGER PRIMARY KEY, message STRING, timeStamp STRING, status STRING)",
          );
        },
      );
    }
  }

  Future<int> insertForm(SocketData socketData) async {
    await openDb();

    int res = await _database.insert(
      'socket',
      socketData.toMap(),
    );
    return res;
  }

  Future<List> getRowCount() async {
    await openDb();
    final List maps = await _database.query(
      'socket',
    );
    maps.forEach((row) => print(row));
    return maps;
  }

  Future<List<SocketData>> getAllRows() async {
    await openDb();
    List<Map> list = await _database.rawQuery('SELECT * FROM socket ');
    List<SocketData> maps = new List();
    for (int i = 0; i < list.length; i++) {
      maps.add(new SocketData(
        id: list[i]['id'],
        status: list[i]['status'],
        message: list[i]['message'],
        timeStamp: list[i]['timeStamp'],
      ));
    }
    print(maps);
    return maps;
  }

  Future<int> updateSocketData(
      int id, String message, var status, var timeStamp) async {
    await openDb();
    int updateCount = await _database.rawUpdate('''
    UPDATE socket 
    SET message = ?, status = ?, timeStamp = ?
    WHERE id = ?
    ''', ["$message", "$status", "$timeStamp", "$id"]);
    print(updateCount);
    return updateCount;
  }

  Future<int> updateForm(SocketData socketData) async {
    await openDb();
    int res = await _database.update('socket', socketData.toMap(),
        where: "id = ?", whereArgs: [socketData.id]);

    return res;
  }

  Future<void> deleteForm(int id) async {
    await openDb();
    await _database.delete('socket', where: "id = ?", whereArgs: [id]);
  }
}

class SocketData {
  int id;
  String status;
  String message;
  String timeStamp;

  SocketData({
    this.id,
    this.status,
    this.message,
    this.timeStamp,
  });
  SocketData.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    message = map['message'];
    status = map['status'];
    timeStamp = map['timeStamp'];
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status,
      'message': message,
      'timeStamp': timeStamp,
    };
  }
}
