import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  Future<void> loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

 @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        ThemeProvider themeProvider = ThemeProvider();
        themeProvider.loadTheme(); // Carrega o tema ao inicializar
        return themeProvider;
      },
      child: Consumer<ThemeProvider>(
        builder: (_, themeProvider, __) {
          return MaterialApp(
            title: 'Lista de Tarefas',
            theme: themeProvider.isDarkMode
                ? ThemeData(
                    primarySwatch: Colors.red,
                    brightness: Brightness.dark,
                  )
                : ThemeData(
                    primarySwatch: Colors.red,
                    brightness: Brightness.light,
                  ),
            home: const MyHomePage(title: 'Lista de Tarefas'),
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Task> _tasks = [];
  bool showBottomAppBar = false;

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? tasksJson = prefs.getStringList('tasks');
    if (tasksJson != null) {
      setState(() {
        _tasks = tasksJson.map((taskJson) => Task.fromJson(taskJson)).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    showBottomAppBar = _tasks.isNotEmpty;
    _loadTasks();
  }

  Future<void> _removeTask(List<Task> valoresOrdenados, Task task) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tasks.remove(task);
      valoresOrdenados.remove(task);

      prefs.setStringList('tasks', _tasks.map((task) => task.toJson()).toList());
    });
  }

  Future<void> _addTask(Task newTask) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tasks.add(newTask);
      prefs.setStringList('tasks', _tasks.map((task) => task.toJson()).toList());
    });
  }

  Future<void> _updateTask(int index, Task updatedTask) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tasks[index] = updatedTask;
      prefs.setStringList('tasks', _tasks.map((task) => task.toJson()).toList());
    });
  }

  @override
Widget build(BuildContext context) {
  

    List<Task> valoresOrdenados = [];

    // Adiciona os valores "HIGH" à lista ordenada
    valoresOrdenados.addAll(_tasks.where((task) => task.priority == 'HIGH'));

    // Adiciona os valores "MEDIUM" à lista ordenada
    valoresOrdenados.addAll(_tasks.where((task) => task.priority == 'MEDIUM'));

    // Adiciona os valores "LOW" à lista ordenada
    valoresOrdenados.addAll(_tasks.where((task) => task.priority == 'LOW'));

    valoresOrdenados.addAll(_tasks.where((task) => task.priority == 'WORK'));

    valoresOrdenados.addAll(_tasks.where((task) => task.priority == 'NONE'));

    valoresOrdenados.addAll(_tasks.where((task) => task.priority == 'DONE'));

  
    return Consumer<ThemeProvider>(
      builder: (_, themeProvider, __) {
      return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 70,
        centerTitle: true,
        flexibleSpace: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                gradient: const LinearGradient(
                  colors: [Colors.red, Colors.pink],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/foxyplanner.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          ListView.separated(
            itemCount: _tasks.length > 0 ? valoresOrdenados.length : 1,
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(
                height: 5,
              );
            },
            itemBuilder: (BuildContext context, int index) {
              if (_tasks.isEmpty) {
                return 
                  ListTile(
                    title: const Text('Nenhuma tarefa', textAlign: TextAlign.center, style: TextStyle(color: Color.fromARGB(255, 110, 110, 110), fontSize: 18),),
                  );
              }
              final task = valoresOrdenados[index];
              IconData? iconData;
              Color? iconColor;

              switch(task.priority) {
                case "HIGH":
                  iconData = Icons.error_outline;
                  iconColor = Colors.red;
                  break;
                case "MEDIUM":
                  iconData = Icons.remove_circle_outline_rounded;
                  iconColor = Color.fromARGB(255, 255, 166, 0);
                  break;
                case "LOW":
                  iconData = Icons.arrow_drop_down_circle_outlined;
                  iconColor = Colors.blue;
                  break;
                case "WORK":
                  iconData = Icons.build_circle_outlined;
                  iconColor = Colors.purple;
                  break;
                case "NONE":
                  iconData = Icons.adjust;
                  iconColor = Colors.grey;
                  break;
                case "DONE":
                  iconData = Icons.check_circle_outline_rounded;
                  iconColor = Colors.green;
                  break;
              }  

              return 
              GestureDetector(
                onLongPress: () {
                  // Ação a ser executada ao pressionar e manter pressionado
                  if (task.priority != "DONE") {
                    task.priority = "DONE";
                  }

                  setState(() {
                    valoresOrdenados.addAll(_tasks.where((task) => task.priority == 'HIGH'));

                  // Adiciona os valores "MEDIUM" à lista ordenada
                  valoresOrdenados.addAll(_tasks.where((task) => task.priority == 'MEDIUM'));

                  // Adiciona os valores "LOW" à lista ordenada
                  valoresOrdenados.addAll(_tasks.where((task) => task.priority == 'LOW'));

                  valoresOrdenados.addAll(_tasks.where((task) => task.priority == 'WORK'));

                  valoresOrdenados.addAll(_tasks.where((task) => task.priority == 'NONE'));

                  valoresOrdenados.addAll(_tasks.where((task) => task.priority == 'DONE'));
                  });
                },
              child: Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.startToEnd,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      Text(
                        '   REMOVER',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                onDismissed: (_) {
                  _removeTask(valoresOrdenados, task);
                },
                child: 
                Container(
                  color: task.priority == 'DONE' ? Colors.green.withOpacity(0.1) : Colors.transparent, 
                  child: 
                   ListTile(
                  
                  leading:
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        iconData ?? Icons.error_outline,
                        color: iconColor,
                        size: 40.0,
                      ),
                    ],
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 18,
                      decoration: task.priority == 'DONE' ? TextDecoration.lineThrough : null,
                      color: task.priority == 'DONE' ? Colors.green : null,
                    ),
                  ),
                  subtitle: Text(
                    task.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditTaskPage(task: task)),
                    ).then((updatedTask) {
                      if (updatedTask != null) {
                        _updateTask(index, updatedTask);
                      }
                    });
                  },
                ),
                )
               
              )
              );
            },
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: GestureDetector(
                onTap: () {
                  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                  themeProvider.toggleDarkMode();
                },
                child: Image.asset(
                  'assets/images/fox.png',
                  width: 73,
                  height: 73,
                ),
              ),
            ),
          ),
          Align(
  alignment: Alignment.bottomCenter,
  child: Visibility(
    visible: _tasks.where((task) => task.priority != "DONE").length > 0,
    child: GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Center(child: Text('Quantidade de Tarefas'),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start, // Alinha à esquerda
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alinha os elementos à direita
                    children: [
                      Icon(Icons.error_outline, color: Colors.red),
                      Text('Alta:'),
                      Text('${_tasks.where((task) => task.priority == "HIGH").length}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.remove_circle_outline_rounded, color: Color.fromARGB(255, 255, 166, 0)),
                      Text('Média:'),
                      Text('${_tasks.where((task) => task.priority == "MEDIUM").length}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.blue,),
                      Text('Baixa:'),
                      Text('${_tasks.where((task) => task.priority == "LOW").length}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.build_circle_outlined, color: Colors.purple),
                      Text('Trabalho:'),
                      Text('${_tasks.where((task) => task.priority == "WORK").length}'),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Fechar'),
                ),
              ],
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 27.0),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            '${_tasks.where((task) => task.priority != "DONE").length} ${_tasks.where((task) => task.priority != "DONE").length == 1 ? 'Tarefa Pendente' : 'Tarefas Pendentes'}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ),
  ),
),

        ],
        
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskPage()),
          ).then((value) {
            if (value != null) {
              _addTask(value);
            }
          });
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      
      );
      }
    );
  }
}

class AddTaskPage extends StatefulWidget {
  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  String valorSelecionado = 'NONE';

  Future<void> _addTask() async {
    final newTitle = _titleController.text.trim();
    String newDescription = _descriptionController.text.trim();
    final newPriority = valorSelecionado;
    if (newDescription.isEmpty) {
      newDescription = 'Sem descrição.';
    }
    if (newTitle.isNotEmpty) {
      Navigator.pop(context, Task(newTitle, newDescription, newPriority));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 70,
        title: const Text("Adicionar Tarefa"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
            gradient: const LinearGradient(
              colors: [Colors.red, Colors.pink],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
      ),
      body: Container(
        child: Column(
          children: [
            
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Título', icon: Icon(Icons.edit)),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Descrição', icon: Icon(Icons.edit_document)),
                  ),
                  const SizedBox(height: 32.0),
                  Row(
                    children: [
                      Icon(Icons.edit_notifications, color: Colors.grey,),
                      SizedBox(width: 16),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text("Prioridade", style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 117, 117, 117),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8.0),
                   RadioListTile<String>(
                    title: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red,), // Ícone
                        SizedBox(width: 8), // Espaçamento entre o ícone e o texto
                        Text('Alta', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    
                    value: 'HIGH',
                    groupValue: valorSelecionado,
                    activeColor: Colors.red,
                    onChanged: (value) {
                      setState(() {
                        valorSelecionado = value!;
                      });
                    },
                    
                    
                  ),
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        Icon(Icons.remove_circle_outline_rounded, color: Color.fromARGB(255, 255, 166, 0)), // Ícone
                        SizedBox(width: 8), // Espaçamento entre o ícone e o texto
                        Text('Média', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    
                    value: 'MEDIUM',
                    groupValue: valorSelecionado,
                    activeColor: Colors.red,
                    onChanged: (value) {
                      setState(() {
                        valorSelecionado = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.blue), // Ícone
                        SizedBox(width: 8), // Espaçamento entre o ícone e o texto
                        Text('Baixa', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    
                    value: 'LOW',
                    groupValue: valorSelecionado,
                    activeColor: Colors.red,
                    onChanged: (value) {
                      setState(() {
                        valorSelecionado = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        Icon(Icons.build_circle_outlined, color: Colors.purple), // Ícone
                        SizedBox(width: 8), // Espaçamento entre o ícone e o texto
                        Text('Trabalho', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    
                    value: 'WORK',
                    groupValue: valorSelecionado,
                    activeColor: Colors.red,
                    onChanged: (value) {
                      setState(() {
                        valorSelecionado = value!;
                      });
                    },
                  ),
                ],
              ),
              
            ),
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.check),
        backgroundColor: Colors.red
      ),
      
    );
  }
}

class EditTaskPage extends StatefulWidget {
  final Task task;

  EditTaskPage({required this.task});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String valorSelecionado;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    valorSelecionado = widget.task.priority;
  }

  Future<void> _updateTask() async {
    final updatedTitle = _titleController.text.trim();
    String updatedDescription = _descriptionController.text.trim();
    final updatedPriority = valorSelecionado;
    if (updatedDescription.length == 0) {
      updatedDescription = 'Sem descrição.';
    }
    if (updatedTitle.isNotEmpty) {
      Navigator.pop(context, Task(updatedTitle, updatedDescription, updatedPriority));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 70,
        title: const Text("Editar Tarefa"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
            gradient: const LinearGradient(
              colors: [Colors.red, Colors.pink],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
      ),
      body: Container(
        child: Column(
          children: [
             Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Título', icon: Icon(Icons.edit)),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Descrição', icon: Icon(Icons.edit_document)),
                  ),
                  const SizedBox(height: 32.0),
                  Row(
                    children: [
                      Icon(Icons.edit_notifications, color: Colors.grey,),
                      SizedBox(width: 16),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text("Prioridade", style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 117, 117, 117),
                          ),
                        ),
                      ),
                      ],
                  ),
                  const SizedBox(height: 8.0),
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red,), // Ícone
                        SizedBox(width: 8), // Espaçamento entre o ícone e o texto
                        Text('Alta', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    
                    value: 'HIGH',
                    groupValue: valorSelecionado,
                    activeColor: Colors.red,
                    onChanged: (value) {
                      setState(() {
                        valorSelecionado = value!;
                      });
                    },
                    
                    
                  ),
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        Icon(Icons.remove_circle_outline_rounded, color: Color.fromARGB(255, 255, 166, 0)), // Ícone
                        SizedBox(width: 8), // Espaçamento entre o ícone e o texto
                        Text('Média', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    
                    value: 'MEDIUM',
                    groupValue: valorSelecionado,
                    activeColor: Colors.red,
                    onChanged: (value) {
                      setState(() {
                        valorSelecionado = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.blue), // Ícone
                        SizedBox(width: 8), // Espaçamento entre o ícone e o texto
                        Text('Baixa', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    
                    value: 'LOW',
                    groupValue: valorSelecionado,
                    activeColor: Colors.red,
                    onChanged: (value) {
                      setState(() {
                        valorSelecionado = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        Icon(Icons.build_circle_outlined, color: Colors.purple), // Ícone
                        SizedBox(width: 8), // Espaçamento entre o ícone e o texto
                        Text('Trabalho', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    
                    value: 'WORK',
                    groupValue: valorSelecionado,
                    activeColor: Colors.red,
                    onChanged: (value) {
                      setState(() {
                        valorSelecionado = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateTask,
        child: const Icon(Icons.check),
        backgroundColor: Colors.red
      ),
    );
    
  }
}

class Task {
  String title;
  final String description;
  String priority;

  Task(this.title, this.description, this.priority);

  factory Task.fromJson(String json) {
    final map = Map<String, dynamic>.from(jsonDecode(json));
    return Task(map['title'], map['description'], map['priority']);
  }

  String toJson() {
    final map = {
      'title': title,
      'description': description,
      'priority': priority,
    };
    return jsonEncode(map);
  }
}
