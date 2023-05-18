import 'package:flutter/material.dart';

import 'package:core_api/core_api.dart';

import 'package:core_app/src/components/json_visualizer/json_visualizer.dart';


class MonitorScreen extends StatelessWidget {
  MonitorScreen({
    required this.projectString,
    super.key,
  });

  final String projectString;

  final rdb = RealtimeDatabase("todo");

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Realtime Database Monitor - $projectString",
          style: const TextStyle(fontSize: 20),
        ),
        const Divider(),
        Expanded(
          child: StreamBuilder(
            stream: rdb.reference().onValue(),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                return JsonVisualizer(
                  snapshot: snapshot,
                  dbRef: rdb.reference(),
                );
              },
          ),
        ),
      ],
    );
  }
}


