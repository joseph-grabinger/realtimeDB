import 'package:flutter/material.dart';

import 'package:core_api/core_api.dart';

import '/src/models.dart';
import '/src/components/json_visualizer/json_visualizer.dart';


class MonitorScreen extends StatelessWidget {
  final Project project;

  MonitorScreen({
    required this.project,
    super.key,
  });


  final rdb = RealtimeDatabase("todo"); // TODO: get project from projectString

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Realtime Database Monitor - ${project.name}",
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


