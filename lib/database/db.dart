import 'package:qr_scan_app/models/qr_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._initialize();
  static final DatabaseHelper instance = DatabaseHelper._initialize();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'qr.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int ver) async {
    await db.execute('''CREATE TABLE qrdata (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      date TEXT,
      isUrl BOOLEAN
    )''');
  }

  Future<List<QrData>> getQrDataList() async {
    Database db = await instance.database;
    var dbResponse = await db.query('qrdata', orderBy: 'date');
    List<QrData> qrList = dbResponse.isNotEmpty ? dbResponse.map((e) => QrData.fromMap(e)).toList() : [];
    return qrList;
  }
}
