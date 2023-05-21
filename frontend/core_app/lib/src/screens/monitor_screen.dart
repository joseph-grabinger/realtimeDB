import 'package:flutter/material.dart';

import 'package:core_api/core_api.dart';

import '../dialogs/delete_project_dialog.dart';
import '../models.dart';
import '../tab_manager.dart';
import '../components/json_visualizer/json_visualizer.dart';
import '../components/others/popup_menu.dart';


class MonitorScreen extends StatefulWidget {
  final Project project;
  final TabManager tabManager;

  const MonitorScreen({
    required this.project,
    required this.tabManager,
    super.key, required,
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
        Row(
          children: [
            Expanded(
              child: Text("${widget.project.type.displayNameLong} - ${widget.project.name}",
                style: const TextStyle(fontSize: 20),
              ),
            ),
            PopupMenu(
              icon: const Icon(Icons.more_horiz),
              children: [
                buildPopupMenuItem('Rename Project', Icons.drive_file_rename_outline ,0, false),
                buildPopupMenuItem('Delete Project', Icons.delete_forever, 1, true),
              ],
              onSelected: (int value) async {
                print(value);

                if (value == 0) {
                  // showDialog(
                  //   context: context,
                  //   builder: (context) => RenameDialog(
                  //     project: widget.project,
                  //   ),
                  // );
                } else if (value == 1) {
                  bool result = await showDialog(
                    context: context,
                    builder: (context) => DeleteProjectDialog(
                      dbRef: rdb!.reference(),
                      name: widget.project.name,
                    ),
                  );

                  if (result) {
                    int index = widget.tabManager.tabController.index;
                    widget.tabManager.removeTab(index);
                  }
                }
              },
            ),
          ],
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
