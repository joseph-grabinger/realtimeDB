import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:core_api/core_api.dart';

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
  List<String> projects = [];
  String? _value;

  @override
  void initState() {
    super.initState();

    RealtimeDatabase.getProjects().then((List<String> data) => setState(() {
      projects = data;
      print('data: $data');
    }));
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
        GestureDetector(
          onTap: () {
            setState(() {
              _value = "Project 1";
            });
          },
          child: ListTile(
            title: const Text("Project 1"),
            leading: Radio<String>(
              value: "Project 1",
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
        GestureDetector(
          onTap: () {
            setState(() {
              _value = "Project 2";
            });
          },
          child: ListTile(
            title: const Text("Project 2"),
            leading: Radio<String>(
              value: "Project 2",
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
        const Spacer(),
        Row(
          children: [
            const Spacer(),
            CupertinoButton(
              onPressed: () {
                if (_value != null) {
                  widget.callback(_value!);
                  widget.pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  int tabIndex = widget.tabManager.tabController.index;
                  widget.tabManager.tabInfo.value[tabIndex].name = "$_value - ${widget.projectType.displayNameShort}";
                  widget.tabManager.tabInfo.notifyListeners();
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
          onPressed: () {},
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
          onPressed: () {},
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
}
