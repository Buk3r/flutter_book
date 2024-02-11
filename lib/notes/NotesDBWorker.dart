import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../utils.dart' as utils;
import 'NotesModel.dart';

class NotesDBWorker {
  NotesDBWorker._();
  static final NotesDBWorker db = NotesDBWorker._();

  Database? _db;

  Future get database async {
    return _db ??= await init();
  }

  Future<Database> init() async {
    String path = join(utils.docDir!.path, "notes.db");
    Database db = await openDatabase(
        path,
        version: 1,
        onOpen: (db) { },
        onCreate: (Database db, int version) async {
          await db.execute(
            "CREATE TABLE IF NOT EXISTS notes ("
                "id INTEGER PRIMARY KEY,"
                "title TEXT,"
                "content TEXT,"
                "color TEXT"
            ")"
          );
        }
    );

    return db;
  }

  Note noteFromMap(Map map){
    return Note()
        ..id = map["id"]
        ..title = map["title"]
        ..content = map["content"]
        ..color = map["color"];
  }

  Map<String, dynamic> noteToMap(Note note){
    return <String, dynamic>{
      "id": note.id,
      "title": note.title,
      "content": note.content,
      "color": note.color,
    };
  }

  Future create(Note note) async {
    Database db = await database;
    var val = await db.rawQuery(
      "SELECT MAX(id) + 1 AS id FROM notes"
    );
    int? id = val.first["id"] as int?;
    id ??= 1;

    return await db.rawInsert(
      "INSERT INTO notes (id, title, content, color) "
      "VALUES (?, ?, ?, ?)",
      [id, note.title, note.content, note.color],
    );
  }

  Future<Note> get(int? id) async {
    Database db = await database;
    var rec = await db.query(
      "notes", where: "id = ?", whereArgs: [id]
    );

    return noteFromMap(rec.first);
  }

  Future<List> getAll() async {
    Database db = await database;
    var recs = await db.query("notes");
    return recs.isNotEmpty
        ? recs.map((m) => noteFromMap(m)).toList()
        : [];
  }

  Future update(Note note) async {
    Database db = await database;
    return await db.update(
      "notes",
      noteToMap(note),
      where: "id = ?",
      whereArgs: [note.id],
    );
  }

  Future delete(int? id) async {
    Database db = await database;
    return await db.delete(
      "notes",
      where: "id = ?",
      whereArgs: [id],
    );
  }
}