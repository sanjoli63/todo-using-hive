import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'todo_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

enum TodoFilter { ALL, COMPLETED, INCOMPLETED }

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Box<TodoModel>? todoBox;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController detailController = TextEditingController();
  TodoFilter filter = TodoFilter.ALL;

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
              if (value.compareTo("All") == 0) {
                setState(() {
                  filter = TodoFilter.ALL;
                });
              } else if (value.compareTo("Compeleted") == 0) {
                setState(() {
                  filter = TodoFilter.COMPLETED;
                });
              } else {
                setState(() {
                  filter = TodoFilter.INCOMPLETED;
                });
              }
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
                List<int> keys;
                if (filter == TodoFilter.ALL) {
                  keys = todos.keys.cast<int>().toList();
                } else if (filter == TodoFilter.COMPLETED) {
                  keys = todos.keys
                      .cast<int>()
                      .where((key) => todos.get(key)!.iscompleted)
                      .toList();
                  if (keys.isEmpty) {
                    return LayoutBuilder(builder: (ctx, constraints) {
                      return Column(
                        children: <Widget>[
                          Text(
                            'You have not completed any tasks',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Container(
                              height: constraints.maxHeight * 0.5,
                              child: SvgPicture.asset(
                                'assets/undraw_Done_checking_re_6vyx.svg',
                                fit: BoxFit.cover,
                              )),
                        ],
                      );
                    });
                  }
                } else {
                  keys = todos.keys
                      .cast<int>()
                      .where((key) => !todos.get(key)!.iscompleted)
                      .toList();
                  if (keys.isEmpty) {
                    return LayoutBuilder(builder: (ctx, constraints) {
                      return Column(
                        children: <Widget>[
                          Text(
                            'All tasks are completed',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Container(
                              height: constraints.maxHeight * 0.4,
                              child: SvgPicture.asset(
                                'assets/undraw_happy_feeling_slmw.svg',
                                fit: BoxFit.cover,
                              )),
                        ],
                      );
                    });
                  }
                }
                return todos.isEmpty
                    ? LayoutBuilder(builder: (ctx, constraints) {
                        return Column(
                          children: <Widget>[
                            Text(
                              'No Data added yet!',
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Container(
                                height: constraints.maxHeight * 0.4,
                                child: SvgPicture.asset(
                                  'assets/undraw_To_do_list_re_9nt7.svg',
                                  fit: BoxFit.cover,
                                )),
                          ],
                        );
                      })
                    : ListView.separated(
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
                            leading: Icon(Icons.check_box,
                                color: todo.iscompleted
                                    ? Colors.green
                                    : Colors.red),
                            trailing: TextButton.icon(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.deepOrange,
                              ),
                              label: const Text(
                                'Delete',
                                style: TextStyle(
                                  color: Colors.lightGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              onPressed: () {
                                todoBox!.delete(key);
                              },
                            ),
                            onTap: () {
                              if (todo.iscompleted == false) {
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
                                                child:
                                                    Text('Mark AS Completed'),
                                                onPressed: () {
                                                  TodoModel mTodo = TodoModel(
                                                      todo.title,
                                                      todo.detail,
                                                      true);
                                                  todoBox!.put(key, mTodo);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              } else {
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
                                                child:
                                                    Text('Mark AS InCompleted'),
                                                onPressed: () {
                                                  TodoModel mTodo = TodoModel(
                                                      todo.title,
                                                      todo.detail,
                                                      false);
                                                  todoBox!.put(key, mTodo);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              }
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
