library core_api;

export 'event.dart';

import 'database_reference.dart';

/// A realtime database.
class RealtimeDatabase {
  /// Gets a DatabaseReference for the root of your Realtime Database Project.
  DatabaseReference reference() => DatabaseReference(this, <String>[]);

  RealtimeDatabase(this.project) {
    if (project == null) {
      throw("project must not be null");
    }
    if (project!.contains('/')) {
      throw("project must not contain '/' charters");
    }
  }

  final String? project;
}
