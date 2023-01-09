class TodoModel {
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
      "description" : description ?? "",
      "completed": completed ?? false,
    };
  }
  
}
