import 'package:sqflite/sqflite.dart';

import '../models/user.dart';
import '../services/database_helper.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<User?> login(String username, String password) async {
    return await _dbHelper.getUser(username, password);
  }

  Future<bool> register(User user) async {
    final db = await DatabaseHelper().database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }
}
