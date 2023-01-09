import 'package:dart_frog/dart_frog.dart';
import 'package:db/db.dart';
import 'package:dotenv/dotenv.dart';
import 'package:in_memory_todos_data_source/in_memory_todos_data_source.dart';
import 'package:todos_data_source/todos_data_source.dart';
final env = DotEnv()..load();
final _db = DatabaseConnection(env);
final _dataSource = InMemoryTodosDataSource(_db);

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(provider<DatabaseConnection>((_) => _db))
      .use(provider<TodosDataSource>((_) => _dataSource));
}
