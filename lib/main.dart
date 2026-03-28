import 'package:flutter/material.dart';

void main() => runApp(const TaskerApp());

class TaskerApp extends StatelessWidget {
  const TaskerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const TaskListScreen(),
    );
  }
}

class Task {
  String title;
  bool isHighPriority;
  Task({required this.title, this.isHighPriority = false});
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final List<Task> _tasks = [];
  final TextEditingController _controller = TextEditingController();
  bool _isHighPriority = false;

  void _addTask() {
    if (_controller.text.isEmpty) return;
    setState(() {
      _tasks.insert(0, Task(title: _controller.text, isHighPriority: _isHighPriority));
      _controller.clear();
      _isHighPriority = false; // Reset toggle
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Priority Tasker'), centerTitle: true),
      body: Column(
        children: [
          // Input Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter task name...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(_isHighPriority ? Icons.priority_high : Icons.low_priority),
                  color: _isHighPriority ? Colors.red : Colors.grey,
                  onPressed: () => setState(() => _isHighPriority = !_isHighPriority),
                ),
                ElevatedButton(onPressed: _addTask, child: const Icon(Icons.add)),
              ],
            ),
          ),
          
          // List Section
          Expanded(
            child: _tasks.isEmpty 
              ? const Center(child: Text("No tasks yet! Add one above."))
              : ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      color: task.isHighPriority ? Colors.red[50] : Colors.white,
                      child: ListTile(
                        leading: Icon(
                          task.isHighPriority ? Icons.warning : Icons.task_alt,
                          color: task.isHighPriority ? Colors.red : Colors.indigo,
                        ),
                        title: Text(task.title),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => setState(() => _tasks.removeAt(index)),
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}