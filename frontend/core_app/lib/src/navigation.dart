import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'models.dart';
import 'tab_manager.dart';


class Navigation extends StatelessWidget {
  Navigation({super.key});

  final TabManager _tabManager = TabManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideBar(tabManager: _tabManager),
          Expanded(
            child: MainWindow(tabManager: _tabManager),
          ),
        ],
      ),
    );
  }
}

class SideBar extends StatelessWidget {
  const SideBar({required this.tabManager, super.key});

  final TabManager tabManager;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        width: 70,
        color: Theme.of(context).primaryColor,
        child: Column(
          children: [
            SizedBox(
              height: 65,
              child: Padding(
                padding: const EdgeInsets.only(top:8.0),
                child: Center(
                  child: SvgPicture.asset('assets/dunef_logo_black.svg',
                    color: Colors.blueGrey,
                  ),
                ),
              ),
            ),
            const Divider(color: Colors.black),
            ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 100,
                maxHeight: 200,
              ),
              child: Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.storage_rounded),
                      tooltip: "Realtime Database",
                      onPressed: () => tabManager.addTab(Project(
                        "New Realtime Database Monitor",
                        ProjectType.realtimeDatabase,
                      )),
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.folder),
                      tooltip: "Document Storage",
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.person_2),
                      tooltip: "Authetication",
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.graph_circle),
                      tooltip: "Usage",
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.black),
            Flexible(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/background.png'),
                    fit: BoxFit.cover
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: RotatedBox(
                      quarterTurns: -1,
                      child: Text(
                        "Realtime Database Interface",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }
}

class MainWindow extends StatefulWidget {
  const MainWindow({required this.tabManager, super.key});

  final TabManager tabManager;

  @override
  MainWindowState createState() => MainWindowState();
}

class MainWindowState extends State<MainWindow>
    with TickerProviderStateMixin {

  @override
  void initState() {
    widget.tabManager.init(this, widget.tabManager.initPosition ?? 0);
    super.initState();
  }

  @override
  void dispose() {
    widget.tabManager.tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.tabManager.init(this, widget.tabManager.initPosition ?? 0); //TODO DEBUG only
    return ValueListenableBuilder<List<Project>>(
      valueListenable: widget.tabManager.tabInfo,
      builder: (BuildContext context, List<Project> value, Widget? child) {
        if (value.isEmpty) return Container();

        return Column(
          children: [
            TabBar(
              controller: widget.tabManager.tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Theme.of(context).hintColor,
              indicator: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
              ),
              indicatorColor: Colors.grey,
              tabs: List.generate(
                value.length,
                    (index) => widget.tabManager.tabBuilder(context, index),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: widget.tabManager.tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(
                  value.length, (index) => widget.tabManager.pageBuilder(context, index),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
