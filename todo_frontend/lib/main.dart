import 'package:flutter/material.dart';
import 'package:todo_frontend/models/todo_model.dart';
import 'package:todo_frontend/service/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ApiService api = ApiService();
  var titleEditingController = TextEditingController();
  var descriptionEditingController = TextEditingController();
  List<TodoModel>? todos;

  @override
  void initState() {
    // api.getTodos();
    getAlltodos();
    super.initState();
  }

  getAlltodos() async {
    todos = await api.getTodos();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo App"),
      ),
      body: todos == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : todos!.isNotEmpty
              ? ListView.separated(
                  itemCount: todos!.length,
                  separatorBuilder: (context, index) => const SizedBox(
                        height: 10,
                      ),
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(todos![index].title),
                        // tileColor: Colors.grey,
                        subtitle:
                            Text(todos![index].description ?? "No description"),
                        leading: Checkbox(
                          value: todos![index].completed,
                          onChanged: (value) {},
                        ),
                      ),
                    );
                  })
              : const Center(
                  child: Text("No todos"),
                ),
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
            onPressed: () async {
              final a = await showModalBottomSheet(
                context: context,
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        controller: titleEditingController,
                        decoration: InputDecoration(
                          hintText: "Enter title",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: descriptionEditingController,
                        decoration: InputDecoration(
                          hintText: "Enter title",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (titleEditingController.text.isNotEmpty) {
                            TodoModel todoModel = TodoModel(
                              title: titleEditingController.text,
                              description: descriptionEditingController.text,
                            );
                            Navigator.pop(context, todoModel);
                          }
                        },
                        child: const Text("Add"),
                      ),
                    ],
                  ),
                ),
              );
              if (a != null) {
                await api.addTodos(a as TodoModel);
                 todos  = await api.getTodos();
                setState(()  {
                  
                });
              }
            },
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}
