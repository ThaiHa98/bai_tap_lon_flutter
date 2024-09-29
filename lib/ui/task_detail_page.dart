import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import 'todo_page.dart'; // Import TodoPage

class TaskDetailPage extends StatefulWidget {
  final Task? task;
  TaskDetailPage({this.task});

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final TaskService _taskService = TaskService();
  final TextEditingController _titleController = TextEditingController();
  DateTime _deadline = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _deadline = widget.task!.deadline;
    }
  }

  void _saveTask() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tiêu đề không được để trống')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Đang lưu...'),
          ],
        ),
      ),
    );

    try {
      if (widget.task != null) {
        // Update existing task
        widget.task!.title = _titleController.text;
        widget.task!.deadline = _deadline;
        await _taskService.updateTask(widget.task!);
      } else {
        // Add new task
        await _taskService.addTask(Task(title: _titleController.text, deadline: _deadline));
      }

      // Đóng dialog đang hiển thị
      Navigator.pop(context);

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lưu task thành công')),
      );

      // Load lại trang TodoPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TodoPage()),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu task: $e')),
      );
    }
  }

  void _deleteTask() async {
    if (widget.task != null) {
      final int? taskId = widget.task!.id; // Giả sử id là int?

      if (taskId != null) { // Kiểm tra null trước khi sử dụng
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Đang xóa...'),
              ],
            ),
          ),
        );

        try {
          await _taskService.deleteTask(taskId); // Gọi hàm xóa với id không null
          Navigator.pop(context);
          Navigator.of(context).popUntil((route) => route.isFirst);
        } catch (e) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi xóa task: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ID của task bị null')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task != null ? 'Chỉnh sửa Task' : 'Tạo Task mới'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TodoPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/pexels-tirachard-kumtanom-112571-733852.jpg'),
            fit: BoxFit.cover, // Thay đổi để phù hợp với kích thước màn hình
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Tiêu đề',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      OutlinedButton.icon(
                        icon: Icon(Icons.calendar_today),
                        label: Text('Chọn ngày hoàn thành: ${_deadline.toLocal()}'.split(' ')[0]),
                        onPressed: () {
                          _selectDeadline(context);
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saveTask,
                        child: Text('Lưu Task'),
                      ),
                      if (widget.task != null) ...[
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _deleteTask,
                          child: Text('Xóa Task'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _deadline) {
      setState(() {
        _deadline = picked;
      });
    }
  }
}
