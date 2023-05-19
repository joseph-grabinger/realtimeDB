library core_api;

export 'event.dart';

import 'database_reference.dart';

/// A realtime database.
class RealtimeDatabase {
  final String? project;

  RealtimeDatabase(this.project) {
    if (project == null) {
      throw("project must not be null");
    }
    if (project!.contains('/')) {
      throw("project must not contain '/' charters");
    }
  }

  /// Gets a DatabaseReference for the root of your Realtime Database Project.
  DatabaseReference reference() => DatabaseReference(this, <String>[]);

  /// Returns a List of all projects in the database.
  static Future<List<String>> getProjects() async {
    // TODO: implement
    return ["todo"];
  }

}
