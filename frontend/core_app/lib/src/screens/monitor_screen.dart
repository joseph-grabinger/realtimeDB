import 'package:flutter/material.dart';

import 'package:core_api/core_api.dart';

import '../models.dart';
import '../components/json_visualizer/json_visualizer.dart';


class MonitorScreen extends StatefulWidget {
  final Project project;

  const MonitorScreen({
    required this.project,
    super.key,
  });

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  RealtimeDatabase? rdb; 

  @override
  void initState() {
    super.initState();

    rdb = RealtimeDatabase(widget.project.name);
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("${widget.project.type.displayNameLong} - ${widget.project.name}",
          style: const TextStyle(fontSize: 20),
        ),
        const Divider(),
        rdb != null ? Expanded(
          child: StreamBuilder(
            stream: rdb!.reference().onValue(),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                return JsonVisualizer(
                  snapshot: snapshot,
                  dbRef: rdb!.reference(),
                );
              },
          ),
        ) : Container(),
      ],
    );
  }
}
