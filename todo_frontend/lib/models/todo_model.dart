import 'package:equatable/equatable.dart';

class TodoModel extends Equatable {
  int? id;
  String title;
  String? description;
  bool? completed;

  TodoModel({this.id, required this.title, this.description, this.completed});
  factory TodoModel.fromJson(Map<String, dynamic> data) {
    return TodoModel(
      id: data['id'],
      title: data['title'],
      description: data['description'],
      completed: data['completed'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "completed": completed ?? false,
    };
  }

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [id, title, description, completed];
}
