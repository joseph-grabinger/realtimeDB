import 'dart:async';

import 'package:core_app/src/components/file_browser/file_browser.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:realtime_api/realtime_api.dart';
import 'package:filestorage_api/filestorage_api.dart';

import '../models.dart';
import '../tab_manager.dart';
import '../components/others/popup_menu.dart';
import '../components/json_visualizer/json_visualizer.dart';
import '../components/file_browser/file_browser_controller.dart';
import '../dialogs/delete_project_dialog.dart';
import '../dialogs/rename_project_dialog.dart';


class MonitorScreen extends StatefulWidget {
  final Project project;
  final TabManager tabManager;

  const MonitorScreen({
    required this.project,
    required this.tabManager,
    super.key,
  });

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  RealtimeDatabase? rdb;
  FileStorage? fs;
  FileBrowserController? browserController;

  final Completer initCompleter = Completer();

  @override
  void initState() {
    super.initState();

    if (widget.project.type == ProjectType.realtimeDatabase) {
      rdb = RealtimeDatabase(widget.project.name);
    } else if (widget.project.type == ProjectType.fileStorage) {
      fs = FileStorage(widget.project.name);

      Get.put(FileBrowserController(projectName: widget.project.name, fileStorage: fs!,));
      browserController = Get.find<FileBrowserController>();
      initCompleter.complete();
    }

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
                if (value == 0) {
                  String? newName = await showDialog(
                    context: context,
                    builder: (context) => RenameProjectDialog(
                      project: widget.project,
                    ),
                  );

                  if (newName != null) {
                    // TODO: update project name in tabmanager
                    widget.project.name = newName;
                    setState(() {});
                  }
                } else if (value == 1) {
                  bool result = await showDialog(
                    context: context,
                    builder: (context) => DeleteProjectDialog(
                      dbRef: rdb?.reference(),
                      fs: fs,
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
        fs != null ? Expanded(
          child: FutureBuilder(
          future: initCompleter.future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return FileBrowser(
                controller: browserController!,
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        ) : Container(),
      ],
    );
  }
}
