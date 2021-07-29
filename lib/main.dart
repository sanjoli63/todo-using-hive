import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'todo_model.dart';

const String todoBoxName = "todo";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  Hive.registerAdapter(TodoModelAdapter());
  await Hive.openBox<TodoModel>(todoBoxName);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Box<TodoModel>? todoBox;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController detailController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    todoBox = Hive.box<TodoModel>(todoBoxName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (value) {
              ///Todo : Take action accordingly
              ///
            },
            itemBuilder: (BuildContext context) {
              return ["All", "Compeleted", "Incompleted"].map((option) {
                return PopupMenuItem(
                  value: option,
                  child: Text(option),
                );
              }).toList();
            },
          )
        ],
        title: Text("Hive Todo"),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextField(
                            controller: titleController,
                            decoration: InputDecoration(hintText: 'Title'),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          TextField(
                            controller: detailController,
                            decoration: InputDecoration(hintText: 'Details'),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          TextButton(
                            child: Text('Add Todo'),
                            onPressed: () {
                              final String title = titleController.text;
                              final String detail = detailController.text;
                              TodoModel todo = TodoModel(title, detail, false);
                              todoBox!.add(todo);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                });
          }),
    );
  }
}
