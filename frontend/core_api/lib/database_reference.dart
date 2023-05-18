import 'package:core_api/core_api.dart';

import 'query.dart';

class DatabaseReference extends Query {
  DatabaseReference(
      RealtimeDatabase database,
      List<String> pathComponents)
        : super(database: database, pathComponents: pathComponents);


  /// Gets a DatabaseReference for the root location.
  DatabaseReference root() {
    return DatabaseReference(database, <String>[]);
  }

  /// Gets a DatabaseReference for the location at the specified relative path.
  DatabaseReference child(String path) {
    return DatabaseReference(database,
        (List<String>.from(pathComponents)..addAll(path.split('/'))));
  }

}
