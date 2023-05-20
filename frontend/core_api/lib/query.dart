
import 'dart:async';
import 'dart:convert' as convert;

import 'package:flutter/foundation.dart';

import 'core_api.dart';
import 'utils.dart';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;


class Query {
  Query({required this.pathComponents, required this.database});

  final List<String> pathComponents;
  final RealtimeDatabase database;

  /// Slash-delimited path representing the database location of this query.
  String get path => pathComponents.join('/');

  static const String baseUrl = "http://localhost:5001/api/";
  static const String wsBaseUrl = "ws://localhost:5001/ws/";

  Uri get _url => Uri.parse('$baseUrl${database.project}/$path');
  Uri get _wsUrl => Uri.parse('$wsBaseUrl${database.project}/$path');

  /// Gets the most up-to-date result for this query and returns as native type.
  Future<dynamic> get() async {
    debugPrint("GET called with: $_url");

    http.Response response = await http.get(_url);
    if (response.statusCode == 200) {
      return convert.jsonDecode(response.body);
    } else {
      throw("GET on $_url exited with status code ${response.statusCode}");
    }
  }

  /// Write `value` to the location.
  /// This will overwrite any data at this location and all child locations.
  void set(dynamic value) async {
    debugPrint("SET called with: $_url");

    var body = convert.jsonEncode(value);

    http.Response response = await http.post(_url, body: body);
    if (response.statusCode != 201) {
      throw("SET on $_url with {$value} exited with status code ${response.statusCode}");
    }
  }

  /// Update the node with the `value`.
  void update(dynamic value) async {
    debugPrint("UPDATE called with: $_url");

    var body = convert.jsonEncode(value);

    http.Response response = await http.put(_url, body: body);
    if (response.statusCode != 201) {
      throw("UPDATE on $_url with {$value} exited with status code ${response.statusCode}");
    }
  }

  /// Removes the data at the location.
  void remove() async {
    debugPrint("REMOVE called with: $_url");

    http.Response response = await http.delete(_url);
    if (response.statusCode != 201) {
      throw("REMOVE on $_url exited with status code ${response.statusCode}");
    }
  }

  /// Fires when the data at this location is changed.
  Stream<dynamic> onValue() {
    final channel = WebSocketChannel.connect(_wsUrl);
    StreamController<dynamic> controller = StreamController<dynamic>();
    dynamic currentVals;

    get().then((value) {
      controller.sink.add(value);
      currentVals = value;
    });

    StreamSubscription sub = channel.stream.map((event) {
      Event e = Event.fromMap(convert.jsonDecode(event));
      List<String> pathComp = e.path.split('/');
      PrimitiveWrapper data = PrimitiveWrapper(currentVals);
      replaceValueInMap(data, e.data, pathComp);

      currentVals = data.value;
      controller.sink.add(currentVals);
    }).listen((event) {});

    controller.onCancel = () {
      sub.cancel();
      controller.close();
    };

    return controller.stream;
  }

}
