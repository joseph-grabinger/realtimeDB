
class Project {
  String name;
  final ProjectType type;

  Project(this.name, this.type);
}

enum ProjectType {
  realtimeDatabase,
  fileStorage,
}

extension ProjectTypeExtension on ProjectType {
  String get displayNameLong {
    switch (this) {
      case ProjectType.realtimeDatabase:
        return "Realtime Database Montior";
      case ProjectType.fileStorage:
        return "File Storage Explorer";
    }
  }

  String get displayNameShort {
    switch (this) {
      case ProjectType.realtimeDatabase:
        return "Realtime Monitor";
      case ProjectType.fileStorage:
        return "Storage Explorer";
    }
  }
}
