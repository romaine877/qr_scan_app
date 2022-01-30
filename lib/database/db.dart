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
    List<QrData> qrList = dbResponse.isNotEmpty ? dbResponse.map((item) => QrData.fromMap(item)).toList() : [];
    return qrList;
  }

  Future<int> insertQrData(QrData qrData) async {
    Database db = await instance.database;
    return await db.insert('qrdata', qrData.toMap());
    
  }

  Future<int> deleteQrData(QrData qrData) async {
    Database db = await instance.database;
    return await db.delete('qrdata', where: 'id = ?', whereArgs: [qrData.id]);
  }

  Future<void> deleteAllQrData() async {
    Database db = await instance.database;
    await db.delete('qrdata');
  }

  
}
