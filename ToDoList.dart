import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListPage(),
    );
  }
}

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Map<String, dynamic>> _tasks = [];
  late SharedPreferences _prefs;
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _tasks = (_prefs.getStringList('tasks') ?? []).map((item) {
        return Map<String, dynamic>.from(jsonDecode(item));
      }).toList();
    });
  }

  Future<void> _saveTasks() async {
    await _prefs.setStringList(
      'tasks',
      _tasks.map((item) => jsonEncode(item)).toList(),
    );
  }

  void _addTask(String task) {
    setState(() {
      _tasks.add({'task': task, 'completed': false});
      _saveTasks();
    });
    _taskController.clear();
  }

  void _editTask(int index, String newTask) {
    setState(() {
      _tasks[index]['task'] = newTask;
      _saveTasks();
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
      _saveTasks();
    });
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index]['completed'] = !_tasks[index]['completed'];
      _saveTasks();
    });
  }

  Future<void> _showEditDialog(int index) async {
    final TextEditingController _editController =
    TextEditingController(text: _tasks[index]['task']);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: TextField(
            controller: _editController,
            decoration: InputDecoration(
              hintText: 'Edit task',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                _editTask(index, _editController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int tasksLeft = _tasks.where((task) => !task['completed']).length;

    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff667eea), Color(0xff330867)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: Padding(
                  padding: const EdgeInsets.only(left: 30, top: 55, right: 15),
                  child: Row(
                    children: [
                      CircleAvatar(
                        child: Icon(
                          Icons.list,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      Text(
                        'Make Your Tasks',
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 35, left: 15, right: 15),
                child: Container(
                  height: 585,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18)),
                  child:
                  ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: ListTile(
                          leading: Checkbox(
                            value: _tasks[index]['completed'],
                            onChanged: (bool? value) {
                              _toggleTaskCompletion(index);
                            },
                          ),
                          title: Text(
                            _tasks[index]['task'],
                            style: TextStyle(
                              decoration: _tasks[index]['completed']
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  _showEditDialog(index);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _deleteTask(index);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30, right: 20, top: 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        'Tasks left : $tasksLeft',
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                          ),
                        )
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          _showAddTaskDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(9), // Adjust the padding
                          backgroundColor: Colors.blue, // Background color
                          shadowColor: Colors.black, // Shadow color
                          elevation: 8, // Elevation value to give a shadow effect
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.yellow, // Icon color
                          size: 32, // Icon size
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Task'),
          content: TextField(
            controller: _taskController,
            decoration: InputDecoration(
              hintText: 'Enter your task',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                String newTask = _taskController.text.trim();
                if (newTask.isNotEmpty) {
                  _addTask(newTask); // Add the new task to the list
                }
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
