import 'package:flutter/material.dart';
import '../services/task_service.dart';
import '../models/task.dart';
import 'task_detail_page.dart';

class TodoPage extends StatefulWidget {
  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    var tasks = await _taskService.getAllTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  void _showCommentDialog(Task task) {
    TextEditingController _commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Nhập bình luận cho "${task.title}"'),
          content: TextField(
            controller: _commentController,
            decoration: InputDecoration(hintText: 'Nhập bình luận của bạn...'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                String comment = _commentController.text;
                print('Bình luận: $comment');
                setState(() {
                  _taskService.updateTask(task); // Cập nhật task
                });
                Navigator.of(context).pop();
              },
              child: Text('Gửi'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/pexels-tirachard-kumtanom-112571-733852.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView.builder(
          itemCount: _tasks.length,
          itemBuilder: (context, index) {
            Task task = _tasks[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              elevation: 4,
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: IconButton(
                  icon: Icon(
                    task.done ? Icons.check_circle : Icons.circle,
                    color: task.done ? Colors.green : null,
                  ),
                  onPressed: () {
                    setState(() {
                      task.done = !task.done;
                      _taskService.updateTask(task);
                    });
                  },
                ),
                title: Text(
                  '${index + 1}. ${task.title}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deadline: ${task.deadline.toLocal().toString().split(' ')[0]}', // Hiển thị ngày đến hạn
                      style: TextStyle(
                        color: task.deadline.isBefore(DateTime.now()) ? Colors.red : Colors.grey, // Đổi màu nếu quá hạn
                      ),
                    ),
                    SizedBox(height: 4), // Khoảng cách giữa các hàng
                    Row(
                      children: [
                        Icon(Icons.message, size: 16, color: Colors.grey),
                        SizedBox(width: 4)
                      ],
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.comment),
                      onPressed: () {
                        _showCommentDialog(task);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskDetailPage(task: task),
                          ),
                        ).then((value) => _loadTasks());
                      },
                    ),
                  ],
                ),
                onLongPress: () {
                  _taskService.deleteTask(task.id!);
                  setState(() {
                    _tasks.removeAt(index);
                  });
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskDetailPage()),
          ).then((value) => _loadTasks());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
