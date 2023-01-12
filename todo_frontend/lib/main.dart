import 'dart:developer';

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
                    return Dismissible(
                      key: UniqueKey(),
                      background: const Card(
                        color: Colors.red,
                      ),
                      onDismissed: (direcrion) {
                        api.deleteTodo(todos![index]).then((result) {
                          if (result) {
                            const snack = SnackBar(content: Text("Deleted"));

                            ScaffoldMessenger.of(context).showSnackBar(snack);

                            todos!.remove(todos![index]);
                            setState(() {});
                          } else {
                            const snack =
                                SnackBar(content: Text("Delete failed"));

                            ScaffoldMessenger.of(context).showSnackBar(snack);
                          }
                        });
                      },
                      child: Card(
                        child: ListTile(
                          onTap: () async {
                            final a = await showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  titleEditingController.text =
                                      todos![index].title;
                                  descriptionEditingController.text =
                                      todos![index].description ?? "";
                                  return commonModalBottomSheet(context);
                                });
                            if (a != null) {
                              a.completed = todos![index].completed;
                              a.id = todos![index].id;
                              api.updateTodo(a as TodoModel).then((result) {
                                todos!.where((element) {
                                  if (element.id == result.id) {
                                    element.description = result.description;
                                    element.completed = result.completed;
                                    element.title = result.title;
                                    log(todos.toString());
                                    setState(() {});
                                    return true;
                                  } else {
                                    log("not found");
                                    return false;
                                  }
                                }).toList();
                              });
                            }
                          },
                          title: Text(todos![index].title),
                          // tileColor: Colors.grey,
                          subtitle: Text(
                              todos![index].description ?? "No description"),
                          leading: Checkbox(
                            value: todos![index].completed,
                            onChanged: (value) async {
                              todos![index].completed =
                                  !todos![index].completed!;
                              await api.updateTodo(todos![index]);
                              setState(() {});
                            },
                          ),
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
              titleEditingController.clear();
              descriptionEditingController.clear();
              final a = await showModalBottomSheet(
                context: context,
                builder: (context) => commonModalBottomSheet(context),
              );
              if (a != null) {
                await api.addTodos(a as TodoModel);
                titleEditingController.clear();
                descriptionEditingController.clear();
                todos = await api.getTodos();
                setState(() {});
              }
            },
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  Padding commonModalBottomSheet(
    BuildContext context,
  ) {
    return Padding(
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
              hintText: "Enter description",
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
                  description: descriptionEditingController.text != ""
                      ? descriptionEditingController.text
                      : null,
                );
                Navigator.pop(context, todoModel);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
