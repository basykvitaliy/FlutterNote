class Note{
  int id;
  int status;
  String title;
  String priority;
  DateTime date;

  Note({this.status, this.title, this.priority, this.date});
  Note.withId({this.id, this.status, this.title, this.priority, this.date});

  Map<String, dynamic> toMap(){
    final map = Map<String, dynamic>();
    if(id != null){
      map["id"] = id;
    }
    map["title"] = title;
    map["priority"] = priority;
    map["status"] = status;
    map["date"] = date.toIso8601String();
    return map;
  }

  factory Note.fromMap(Map<String, dynamic> map){
    return Note.withId(
      id: map["id"],
      title: map["title"],
      priority: map["priority"],
      status: map["status"],
      date: DateTime.parse(map["date"]),
    );
  }
}