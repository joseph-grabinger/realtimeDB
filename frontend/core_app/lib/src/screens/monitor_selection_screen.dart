import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:realtime_api/realtime_api.dart';
import 'package:filestorage_api/filestorage_api.dart';

import '../dialogs/create_project_dialog.dart';
import '../dialogs/import_project_dialog.dart';
import '../models.dart';
import '../tab_manager.dart';

class MonitorSelectionScreen extends StatefulWidget {
  final PageController pageController;
  final void Function(String) callback;
  final TabManager tabManager;
  final ProjectType projectType;

  const MonitorSelectionScreen({
    required this.pageController,
    required this.callback,
    required this.tabManager,
    required this.projectType,
    super.key,
  });

  @override
  MonitorSelectionScreenState createState() => MonitorSelectionScreenState();
}

class MonitorSelectionScreenState extends State<MonitorSelectionScreen> {
  List<String>? projects;
  String? _value;

  @override
  void initState() {
    super.initState();

    if (widget.projectType == ProjectType.realtimeDatabase) {
      RealtimeDatabase.getProjects().then((List<String> data) => setState(() {
        projects = data;
      }));
    } else {
      FileStorage.getProjects().then((List<String> data) => setState(() {
        projects = data;
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.projectType.displayNameLong,
          style: const TextStyle(fontSize: 20),
        ),
        const Divider(),
        const Row(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Select from existing projects:"),
            ),
          ],
        ),
        projects == null ? const Center(child: CircularProgressIndicator()) : ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 375.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              for (String project in projects!)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _value = project;
                    });
                  },
                  child: ListTile(
                    title: Text(project),
                    leading: Radio<String>(
                      value: project,
                      groupValue: _value,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (String? value) {
                        setState(() {
                          _value = value;
                        });
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (projects != null) Row(
          children: [
            const Spacer(),
            CupertinoButton(
              onPressed: () {
                if (_value != null) {
                  selectProject(_value!);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).primaryColor,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("Continue",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        CupertinoButton(
          onPressed: () async {
            String? projectName = await showDialog(
              context: context,
              builder: (context) => const CreateProjectDialog(),
            );

            if (projectName != null) {
              selectProject(projectName);
            }
          },
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey
            ),
            child: const ListTile(
              leading: Icon(CupertinoIcons.arrow_2_circlepath,
                color: Colors.white,
              ),
              title: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Create New Project",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        CupertinoButton(
          onPressed: () async {
            String? projectName = await showDialog(
              context: context,
              builder: (context) => const ImportProjectDialog(),
            );

            if (projectName != null) {
              selectProject(projectName);
            }
          },
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey
            ),
            child: const ListTile(
              leading: Icon(CupertinoIcons.arrow_2_circlepath,
                color: Colors.white,
              ),
              title: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Import Project",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void selectProject(String projectName) {
    widget.callback(projectName);
    widget.pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    int tabIndex = widget.tabManager.tabController.index;
    widget.tabManager.tabInfo.value[tabIndex].name = "$projectName - ${widget.projectType.displayNameShort}";
    widget.tabManager.tabInfo.notifyListeners();
  }
}
