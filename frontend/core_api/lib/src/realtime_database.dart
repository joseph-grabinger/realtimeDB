import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

import 'database_reference.dart';
import 'query.dart';

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

  /// Creates a new project in the database.
  /// Returns a [RealtimeDatabase] instance for the new project.
  static Future<RealtimeDatabase> createProject(String name) async {
    Uri url = Uri.parse('${Query.baseUrl}$name');

    var body = convert.jsonEncode({});
    
    http.Response response = await http.post(url, body: body);
    if (response.statusCode == 201) {
      return RealtimeDatabase(name);
    } else {
      throw("POST on $url exited with status code ${response.statusCode}");
    }
  }

  /// Deletes a project from the database.
  static Future<void> deleteProject(String name) async {
    Uri url = Uri.parse('${Query.baseUrl}$name');

    http.Response response = await http.delete(url);
    if (response.statusCode == 204) {
      return;
    } else {
      throw("DELETE on $url exited with status code ${response.statusCode}");
    }
  }

}