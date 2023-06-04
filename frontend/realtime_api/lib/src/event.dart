
enum EventType {
  setEvent,
  updateEvent,
  removeEvent,
}

class Event {
  late EventType type;
  late String path;
  late String project;
  dynamic data;

  Event({
    required this.type, 
    required this.path, 
    required this.project, 
    required this.data,
  });

  Event.fromMap(Map<String, dynamic> map) {
    type = castType(map['type']);
    path = map['path'];
    project = map['project'];
    data = map['data'];
  }

}

EventType castType(String s) {
  switch (s) {
    case "POST": {
      return EventType.setEvent;
    }
    case "PUT": {
      return EventType.updateEvent;
    }
    case "DELETE": {
      return EventType.removeEvent;
    }
    default: {
      throw("invalid EventType");
    }
  }
}