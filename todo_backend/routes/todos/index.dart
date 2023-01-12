import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:todos_data_source/todos_data_source.dart';

FutureOr<Response> onRequest(RequestContext context) async {
  print('context.request.method static: ${context.request.method.toString()}');
  switch (context.request.method) {
    case HttpMethod.get:
      return _get(context);
    case HttpMethod.post:
      return _post(context);
    case HttpMethod.delete:
    case HttpMethod.put:
      return _put(context);
    case HttpMethod.head:
    case HttpMethod.patch:
    case HttpMethod.options:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _get(RequestContext context) async {
  final dataSource = context.read<TodosDataSource>();
  final todos = await dataSource.readAll();
  print('Todos: ${todos.toString()}');
  
  return Response.json(body: todos);
}

Future<Response> _post(RequestContext context) async {
  final dataSource = context.read<TodosDataSource>();
  final receivedData = await context.request.json() as Map<String, dynamic>;
  print("post data $receivedData");
  final todo = Todo.fromJson(receivedData);
  return Response.json(
    statusCode: HttpStatus.created,
    body: await dataSource.create(todo),
  );
}

Future<Response> _put(RequestContext context) async {
  final dataSource = context.read<TodosDataSource>();
  final updatedTodo =
      Todo.fromJson(await context.request.json() as Map<String, dynamic>);
  print('updated todo route: ${updatedTodo.toString()}');
  final newTodo = await dataSource.update(
    updatedTodo.id!,
    updatedTodo
  );

  return Response.json(body: newTodo);
}
