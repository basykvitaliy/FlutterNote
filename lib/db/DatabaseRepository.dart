import 'dart:async';
import 'dart:io';

import 'package:flutter_note/model/NoteModel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseRepository{
  static final DatabaseRepository instance = DatabaseRepository._instance();
  static Database _db;
  DatabaseRepository._instance();

  String noteTable = "note_table";
  String colId = "id";
  String colTitle = "title";
  String colPriority = "priority";
  String colStatus = "status";
  String colDate = "date";

  Future<Database> get db async{
    if(_db == null){
      _db = await _initDB();
    }
    return _db;
  }

  Future<Database> _initDB()async{
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + "db";
    final table = await openDatabase(path, version: 1, onCreate: _onCreate);
    return table;
  }

  void _onCreate(Database db, int version)async {
    await db.execute("CREATE TABLE $noteTable("
        "$colId INTEGER PRIMARY KEY AUTOINCREMENT, "
        "$colTitle TEXT, "
        "$colDate TEXT, "
        "$colPriority TEXT, "
        "$colStatus INTEGER)");
  }

  Future<List<Map<String, dynamic>>> getNoteMapList()async{
    Database db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(noteTable);
    return result;
  }


  Future<List<Note>> getNoteList()async{
    final List<Map<String, dynamic>> noteMapList = await getNoteMapList();
    final List<Note> noteList = [];
    noteMapList.forEach((element) {
      noteList.add(Note.fromMap(element));
    });
    noteList.sort((noteA, noteB) => noteA.date.compareTo(noteB.date));
    return noteList;
  }


  Future<int> insert(Note note)async{
    Database db = await this.db;
    final result = await db.insert(noteTable, note.toMap());
    print("Save");
    return result;
  }

  Future<int> update(Note note)async{
    Database db = await this.db;
    final result = await db.update(noteTable, note.toMap(), where: "$colId = ?", whereArgs: [note.id]);
    return result;
  }

  Future<int> delete(int id)async{
    Database db = await this.db;
    final result = await db.delete(noteTable, where: "$colId = ?", whereArgs: [id]);
    return result;
  }
}