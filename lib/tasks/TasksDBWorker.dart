import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../utils.dart' as utils;
import 'TasksModel.dart';

class TasksDBWorker {
  TasksDBWorker._();
  static final TasksDBWorker db = TasksDBWorker._();

  Database? _db;

  Future get database async {
    return _db ??= await init();
  }

  Future<Database> init() async {
    String path = join(utils.docDir!.path, "tasks.db");
    Database db = await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE IF NOT EXISTS tasks ("
          "id INTEGER PRIMARY KEY,"
          "description TEXT,"
          "dueDate TEXT,"
          "completed TEXT"
          ")");
    });

    return db;
  }

  Task taskFromMap(Map map) {
    return Task()
      ..id = map["id"]
      ..description = map["description"]
      ..dueDate = map["dueDate"]
      ..completed = map["completed"];
  }

  Map<String, dynamic> taskToMap(Task task) {
    return <String, dynamic>{
      "id": task.id,
      "description": task.description,
      "dueDate": task.dueDate,
      "completed": task.completed,
    };
  }

  Future create(Task task) async {
    Database db = await database;
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM tasks");
    int? id = val.first["id"] as int?;
    id ??= 1;

    return await db.rawInsert(
      "INSERT INTO tasks (id, description, dueDate, completed) "
      "VALUES (?, ?, ?, ?)",
      [id, task.description, task.dueDate, task.completed],
    );
  }

  Future<Task> get(int? id) async {
    Database db = await database;
    var rec = await db.query("tasks", where: "id = ?", whereArgs: [id]);

    return taskFromMap(rec.first);
  }

  Future<List> getAll() async {
    Database db = await database;
    var recs = await db.query("tasks");
    return recs.isNotEmpty ? recs.map((m) => taskFromMap(m)).toList() : [];
  }

  Future update(Task task) async {
    Database db = await database;
    return await db.update(
      "tasks",
      taskToMap(task),
      where: "id = ?",
      whereArgs: [task.id],
    );
  }

  Future delete(int? id) async {
    Database db = await database;
    return await db.delete(
      "tasks",
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
