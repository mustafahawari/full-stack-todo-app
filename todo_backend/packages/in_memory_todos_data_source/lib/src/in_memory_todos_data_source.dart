import 'package:db/db.dart';
import 'package:todos_data_source/todos_data_source.dart';
import 'package:uuid/uuid.dart';

/// An in-memory implementation of the [TodosDataSource] interface.
class InMemoryTodosDataSource implements TodosDataSource {
  /// Takes db connection to work with db.
  InMemoryTodosDataSource(this._databaseConnection);

  final DatabaseConnection _databaseConnection;
  // final _cache = <String, Todo>{};
  @override
  Future<Todo> create(Todo todo) async {
    // final id = const Uuid().v4();
    // final createTodo = todo.copyWith(id: id);

    try {
      await _databaseConnection.connect();
      print("todo.description ${todo.description}");
      final result = await _databaseConnection.db.query(
        '''
    INSERT INTO todos (title, description, completed, created_at)
    VALUES (@title, @description, @completed, @created_at) RETURNING *
    ''',
        substitutionValues: {
          'title': todo.title,
          'description': todo.description,
          'completed': false,
          'created_at': DateTime.now(),
        },
      );

      if (result.affectedRowCount == 0) {
        throw Exception('Failed to create todo');
      }
      // _cache[id] = createTodo;
      final todoMap = result.first.toColumnMap();
      print("todoMap: $todoMap");
      return Todo.fromJson(todoMap);
    } catch (e) {
      rethrow;
    } finally {
      await _databaseConnection.closeDb();
    }
  }

  @override
  Future<void> delete(int id) async {
    // _cache.remove(id);
    try {
      await _databaseConnection.connect();
      await _databaseConnection.db.query(
        '''
        DELETE FROM todos
        WHERE id = @id
        ''',
        substitutionValues: {'id': id},
      );
    } catch (e) {
      throw Exception('Unexpected Error');
    } finally {
      await _databaseConnection.closeDb();
    }
  }

  @override
  Future<Todo?> read(int id) async {
    try {
      await _databaseConnection.connect();
      final result = await _databaseConnection.db.query(
        'SELECT * FROM todos WHERE id = @id',
        substitutionValues: {'id': id},
      );
      if (result.isEmpty) {
        return null;
      }
      return Todo.fromJson(result.first.toColumnMap());
    } catch (e) {
      print(e.toString());
      throw Exception('Unexpected Error');
    } finally {
      await _databaseConnection.closeDb();
    }
    // return _cache[id];
  }

  @override
  Future<List<Todo>> readAll() async {
    try {
      await _databaseConnection.connect();
      final result = await _databaseConnection.db.query(
        'SELECT * FROM todos',
      );
      final data =
          result.map((e) => e.toColumnMap()).map(Todo.fromJson).toList();
      return data;
    } catch (e) {
      throw Exception(e);
    } finally {
      await _databaseConnection.closeDb();
    }
    // return _cache.values.toList();
  }

  @override
  Future<Todo> update(int id, Todo todo) async {
    // return _cache.update(id, (value) => todo);
    try {
      await _databaseConnection.connect();
      final result = await _databaseConnection.db.query(
        '''
        UPDATE todos
        SET title = COALESCE(@new_title, title),
            description = COALESCE(@new_description, description),
            completed = COALESCE(@new_completed, completed),
            updated_at = current_timestamp
        WHERE id = @id
        RETURNING *
        ''',
        substitutionValues: {
          'id': id,
          'new_title': todo.title,
          'new_description': todo.description,
          'new_completed': todo.completed,
        },
      );
      if (result.isEmpty) {
        throw Exception('Todo not found');
      }
      return Todo.fromJson(result.first.toColumnMap());
    } catch (e) {
      throw Exception('Unexpected error');
    } finally {
      await _databaseConnection.closeDb();
    }
  }
}
