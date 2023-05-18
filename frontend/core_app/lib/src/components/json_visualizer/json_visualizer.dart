import 'dart:collection';
import 'dart:convert';

import 'package:dunef_db/src/components/json_visualizer/root_node.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:realtime_database/database_reference.dart';
import 'package:realtime_database/realtime_database.dart';

import 'data_node.dart';


class JsonVisualizer extends StatefulWidget {
  JsonVisualizer({
    Key key,
    @required this.snapshot,
    @required this.dbRef,
  }) : super(key: key);

  final AsyncSnapshot<dynamic> snapshot;
  final DatabaseReference dbRef;

  @override
  _JsonVisualizerState createState() => _JsonVisualizerState();
}

class _JsonVisualizerState extends State<JsonVisualizer> {
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => FocusScope.of(context).unfocus());
  }

  @override
  Widget build(BuildContext context) {
    print("JSON-Visualizer: Build Called!");
    if (widget.snapshot.hasData) {
      LinkedHashMap map = widget.snapshot.data;

      print(map);

      Map mapBody = jsonDecode(jsonEncode(map));

      return SingleChildScrollView(
        controller: _scrollController,
        child: Scrollbar(
          controller: _scrollController,
          isAlwaysShown: true,
          child: RawKeyboardListener(
            focusNode: new FocusNode(),
            onKey: (RawKeyEvent event) async {
              if (event.logicalKey == LogicalKeyboardKey.escape) {
                FocusScope.of(context).unfocus();
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RootNode(),
                /*Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                    color: Colors.grey[300],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Root"),
                  ),
                ),*/
                DataNode(
                  dataIt: mapBody.entries,
                  dbRef: widget.dbRef,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: AspectRatio(
          aspectRatio: 1,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
            ),
          ),
        ),
      );
    }
  }
}


