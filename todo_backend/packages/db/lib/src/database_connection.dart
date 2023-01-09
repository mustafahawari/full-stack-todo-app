import 'dart:developer';

import 'package:dotenv/dotenv.dart';
import 'package:postgres/postgres.dart';

class DatabaseConnection {
  DatabaseConnection(this._dotEnv) {
    _host = _dotEnv['DB_HOST'] ?? 'localhost';
    _port = int.tryParse(_dotEnv['DB_PORT'] ?? '') ?? 5432;
    _database = _dotEnv['DB_DATABASE'] ?? 'test';
    _username = _dotEnv['DB_USERNAME'] ?? 'test';
    _password = _dotEnv['DB_PASSWORD'] ?? 'test';
  }
  final DotEnv _dotEnv;
  late String _host;
  late int _port;
  late String _database;
  late String _username;
  late String _password;
  PostgreSQLConnection? _connection;

  PostgreSQLConnection get db {
    return _connection ??=
        throw Exception('Database Connection not initialized');
  }

  Future<void> connect() async {
    try {
      _connection = PostgreSQLConnection(
        _host,
        _port,
        _database,
        username: _username,
        password: _password,
      );
      log('Database connection successful');
      return  await _connection!.open();
    } on Exception catch (e) {
      log('Database connection failed: $e');
    }
  }
  Future<void> closeDb() => _connection!.close();
}
