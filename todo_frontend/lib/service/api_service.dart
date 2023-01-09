import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/todo_model.dart';

class ApiService {
  Future<void> addTodos(TodoModel todo) async {
    try {
      print("todo from user ${todo.toMap()}");
      final encodeJson = jsonEncode(todo.toMap());
      final result = await http.post(
        Uri.parse("$baseUrl/todos"),
        body: encodeJson
      );
      print("Response: $result");
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TodoModel>> getTodos() async {
    try {
      final result = await http.get(
        Uri.parse("$baseUrl/todos"),
      );
      print("Response: $result");
      if (result.statusCode == 200) {
        final List dResult = jsonDecode(result.body);
        final List<TodoModel> todos =
            dResult.map((e) => TodoModel.fromJson(e)).toList();
        return todos;
      } else {
        throw Exception("Error occured");
      }
    } catch (e) {
      rethrow;
    }
  }
}

const String baseUrl = "http://localhost:8080";
