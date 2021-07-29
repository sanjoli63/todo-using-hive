import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'todo_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
      body: Column(
        children: <Widget>[
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: todoBox!.listenable(),
              builder: (context, Box<TodoModel> todos, _) {
                List<int> keys = todos.keys.cast<int>().toList();
                return ListView.separated(
                  itemBuilder: (_, index) {
                    final int key = keys[index];
                    final TodoModel? todo = todos.get(key);
                    return ListTile(
                      title: Text(
                        todo!.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      subtitle: Text(
                        todo.detail,
                        style: TextStyle(fontSize: 16),
                      ),
                      leading: Text("$key"),
                      trailing: Icon(Icons.check,
                          color: todo.iscompleted ? Colors.green : Colors.red),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      TextButton(
                                        child: Text('Mark AS Completed'),
                                        onPressed: () {
                                          TodoModel mTodo = TodoModel(
                                              todo.title, todo.detail, true);
                                          todoBox!.put(key, mTodo);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                    );
                  },
                  separatorBuilder: (_, index) => Divider(),
                  itemCount: keys.length,
                  shrinkWrap: true,
                );
              },
            ),
          ),
        ],
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
