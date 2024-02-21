import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../utils.dart' as utils;
import 'AppointmentsModel.dart';

class AppointmentsDBWorker {
  AppointmentsDBWorker._();
  static final AppointmentsDBWorker db = AppointmentsDBWorker._();

  Database? _db;

  Future get database async {
    return _db ??= await init();
  }

  Future<Database> init() async {
    String path = join(utils.docDir!.path, "appointments.db");
    Database db = await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute("CREATE TABLE IF NOT EXISTS appointments ("
              "id INTEGER PRIMARY KEY,"
              "title TEXT,"
              "description TEXT,"
              "apptDate TEXT,"
              "apptTime TEXT"
              ")");
        });

    return db;
  }

  Appointment appointmentFromMap(Map map) {
    return Appointment()
      ..id = map["id"]
      ..title = map["title"]
      ..description = map["description"]
      ..apptDate = map["apptDate"]
      ..apptTime = map["apptTime"];
  }

  Map<String, dynamic> appointmentToMap(Appointment appointment) {
    return <String, dynamic>{
      "id": appointment.id,
      "title": appointment.title,
      "description": appointment.description,
      "apptDate": appointment.apptDate,
      "apptTime": appointment.apptTime,
    };
  }

  Future create(Appointment appointment) async {
    Database db = await database;
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM appointments");
    int? id = val.first["id"] as int?;
    id ??= 1;

    return await db.rawInsert(
      "INSERT INTO appointments (id, title, content, color) "
          "VALUES (?, ?, ?, ?)",
      [
        id,
        appointment.title,
        appointment.description,
        appointment.apptDate,
        appointment.apptTime],
    );
  }

  Future<Appointment> get(int? id) async {
    Database db = await database;
    var rec = await db.query("appointments", where: "id = ?", whereArgs: [id]);

    return appointmentFromMap(rec.first);
  }

  Future<List> getAll() async {
    Database db = await database;
    var recs = await db.query("appointments");
    return recs.isNotEmpty ? recs.map((m) => appointmentFromMap(m)).toList() : [];
  }

  Future update(Appointment appointment) async {
    Database db = await database;
    return await db.update(
      "appointments",
      appointmentToMap(appointment),
      where: "id = ?",
      whereArgs: [appointment.id],
    );
  }

  Future delete(int? id) async {
    Database db = await database;
    return await db.delete(
      "appointments",
      where: "id = ?",
      whereArgs: [id],
    );
  }
}