library core_api;

export 'event.dart';

import 'dart:convert' as convert;

import 'query.dart';
import 'database_reference.dart';

import 'package:http/http.dart' as http;

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
    Uri url = Uri.parse(Query.baseUrl);

    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      var data = convert.jsonDecode(response.body);

      return data['projects'].map<String>((e) => e.toString()).toList();
    } else {
      throw("GET on $url exited with status code ${response.statusCode}");
    }
  }

}
