import '../models/task.dart';
import '../services/database_helper.dart';

class TaskService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Task>> getAllTasks() async {
    return await _dbHelper.getAllTasks();
  }

  Future<void> addTask(Task task) async {
    await _dbHelper.insertTask(task);
  }

  Future<void> updateTask(Task task) async {
    await _dbHelper.updateTask(task);
  }

  Future<void> deleteTask(int id) async {
    await _dbHelper.deleteTask(id);
  }
}
