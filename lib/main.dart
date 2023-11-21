import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Parse().initialize(
    'eFRrJIPKiThtfCYks5WMKbUm45l1pFNj1iDdzbow',
    'https://parseapi.back4app.com',
    clientKey: 'vx1obtVDp0BVTLjtnO4ONwaggaiHszmigYyMGmey',
    autoSendSessionId: true,
    debug: true,
  );

  runApp(MaterialApp(home: TasksScreen()));
}

class TaskModel {
   String title;
  String description;
   String? objectId; // Added objectId property

  TaskModel({required this.title, required this.description, this.objectId});

  factory TaskModel.fromParse(ParseObject parseObject) {
    return TaskModel(
      title: parseObject['title'],
      description: parseObject['description'],
      objectId: parseObject.objectId,
    );
  }
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late ParseObject _taskObject;
  List<TaskModel> tasks = [];
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController(); // Added description controller

  @override
  void initState() {
    super.initState();
    _taskObject = ParseObject('Task');
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      final ParseResponse response = await _taskObject.getAll();
      if (response.success && response.results != null) {
        setState(() {
          tasks = response.results!.map((task) => TaskModel.fromParse(task)).toList();
        });
      } else {
        print('Error fetching tasks: ${response.error!.message}');
      }
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  Future<void> _showTaskDescription(TaskModel task) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Task Description'),
          content: Column(
            children: [
              Text(task.description),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  // Delete task from backend
                  await _deleteTaskFromBackend(task);

                  // Delete task from UI
                  setState(() {
                    tasks.remove(task);
                  });

                  Navigator.of(context).pop();
                },
                child: Text('Delete Task'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // Set button background color
                  onPrimary: Colors.white, // Set text color
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteTaskFromBackend(TaskModel task) async {
    final parseTask = ParseObject('Task')..objectId = task.objectId;

    try {
      final ParseResponse response = await parseTask.delete();
      if (response.success) {
        print('Task deleted from backend successfully!');
      } else {
        print('Error deleting task from backend: ${response.error!.message}');
      }
    } catch (e) {
      print('Error deleting task from backend: $e');
    }
  }

  Future<void> _addTaskWithDescription() async {
    final newTask = _taskController.text;
    final newDescription = _descriptionController.text; // Get description
    if (newTask.isNotEmpty && newDescription.isNotEmpty) {
      final task = TaskModel(title: newTask, description: newDescription);
      setState(() {
        tasks.add(task);
      });

      // Save task to backend
      await _saveTaskToBackend(task);

      _taskController.clear();
      _descriptionController.clear(); // Clear description controller
    }
  }

  Future<void> _saveTaskToBackend(TaskModel task) async {
    final parseTask = ParseObject('Task')
      ..set('title', task.title)
      ..set('description', task.description);

    try {
      final ParseResponse response = await parseTask.save();
      if (response.success) {
        print('Task saved to backend successfully!');
      } else {
        print('Error saving task to backend: ${response.error!.message}');
      }
    } catch (e) {
      print('Error saving task to backend: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          // Background Image as Container
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 40.0, 40.0),
            child: Align(
              child: Container(
                width: 800.0,
                height: 800.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/download.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content...
          Column(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white.withOpacity(0.8), // Set opacity for background
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (tasks.isEmpty)
                        Center(
                          child: Text(
                            'No tasks yet!',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              return AnimatedSize(
                                curve: Curves.fastOutSlowIn,
                                duration: Duration(milliseconds: 500),
                                child: ListTile(
                                  title: Text(
                                    task.title,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  subtitle: Text(
                                    task.description,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  // Add other ListTile properties as needed
                                  onTap: () {
                                    _showTaskDescription(task);
                                  },
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          _showTaskDescription(task); // Show delete confirmation
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          _navigateToUpdateScreen(task);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _taskController,
                      decoration: InputDecoration(
                        labelText: 'Enter Task',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Enter Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        _addTaskWithDescription();
                      },
                      child: Text('Add Task'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue, // Set button background color
                        onPrimary: Colors.white, // Set text color
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToUpdateScreen(TaskModel task) async {
    final updatedTask = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateTaskScreen(task: task),
      ),
    );

    if (updatedTask != null) {
      // Update task in the UI
      setState(() {
        task.title = updatedTask.title;
        task.description = updatedTask.description;
      });

      // Update task in the backend
      await _updateTaskInBackend(updatedTask);
    }
  }

  Future<void> _updateTaskInBackend(TaskModel task) async {
    final parseTask = ParseObject('Task')..objectId = task.objectId;

    try {
      final ParseResponse response = await parseTask.save();
      if (response.success) {
        print('Task updated in backend successfully!');
      } else {
        print('Error updating task in backend: ${response.error!.message}');
      }
    } catch (e) {
      print('Error updating task in backend: $e');
    }
  }
}

class UpdateTaskScreen extends StatefulWidget {
  final TaskModel task;

  const UpdateTaskScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<UpdateTaskScreen> createState() => _UpdateTaskScreenState();
}

class _UpdateTaskScreenState extends State<UpdateTaskScreen> {
  late TextEditingController _updatedTaskController;
  late TextEditingController _updatedDescriptionController;

  @override
  void initState() {
    super.initState();
    _updatedTaskController = TextEditingController(text: widget.task.title);
    _updatedDescriptionController = TextEditingController(text: widget.task.description);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Task'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Task:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _updatedTaskController,
              decoration: InputDecoration(
                labelText: 'Enter Task',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _updatedDescriptionController,
              decoration: InputDecoration(
                labelText: 'Enter Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _updateTaskAndNavigateBack();
              },
              child: Text('Update Task'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Set button background color
                onPrimary: Colors.white, // Set text color
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateTaskAndNavigateBack() async {
    final updatedTask = TaskModel(
      title: _updatedTaskController.text,
      description: _updatedDescriptionController.text,
      objectId: widget.task.objectId,
    );

    // Pass the updated task back to the calling screen
    Navigator.pop(context, updatedTask);
  }

  @override
  void dispose() {
    _updatedTaskController.dispose();
    _updatedDescriptionController.dispose();
    super.dispose();
  }
}
