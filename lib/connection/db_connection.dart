import 'package:mongo_dart/mongo_dart.dart';

class DBConnection {
  static DBConnection? _instance;
  static Db? _db;

  DBConnection._internal() {
    _instance = this;
  }

  factory DBConnection.getInstance() {
    _instance ??= DBConnection._internal();
    return _instance!;
  }

  Future<Db> getConnection() async {
    if (_db == null || !_db!.isConnected) {
      _db = await Db.create(
          'mongodb+srv://omarellwaty788:@cluster0.5srzo.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0/dyslexia_app'); // Replace with your MongoDB URI
      await _db!.open();
      print('Connected to MongoDB');
    }
    return _db!;
  }

  void closeConnection() {
    if (_db != null && _db!.isConnected) {
      _db!.close();
      print('MongoDB connection closed');
    }
  }
}