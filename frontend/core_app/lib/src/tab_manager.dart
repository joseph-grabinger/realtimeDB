import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'models.dart';
import 'screens/monitor_selection_screen.dart';
import 'screens/monitor_screen.dart';

class TabManager {
  late TickerProvider _vsync;

  ValueNotifier<List<Project>> tabInfo = ValueNotifier([]);

  int? initPosition;

  late TabController tabController;

  void init(TickerProvider vsync, int position) {
    _vsync = vsync;
    initPosition = position;
    tabController = TabController(
        vsync: vsync,
        length: tabInfo.value.length,
        initialIndex: position,
    );
  }

  void removeTab(int index) {
    tabInfo.value.removeAt(index);

    if (tabInfo.value.length-1 < 0) {
      tabController.dispose();
    } else {
      tabController = TabController(
        vsync: _vsync,
        length: tabInfo.value.length,
        initialIndex: tabInfo.value.length-1,
      );
    }

    tabInfo.notifyListeners();
  }

  void addTab(Project project) {
    bool nameExists = tabInfo.value.any(
      (Project p) => p.name.contains(project.name));

    if (nameExists) {
      project.name += tabInfo.value.length.toString();
    }
    tabInfo.value.add(project);

    tabController = TabController(
      vsync: _vsync,
      length: tabInfo.value.length,
      initialIndex: tabInfo.value.length >=2
          ? tabInfo.value.length-2
          : tabInfo.value.length-1,
    );

    tabInfo.notifyListeners();
    tabController.animateTo(tabInfo.value.length-1);
  }

  Widget pageBuilder(context, index) {
    return TabPage(tabManager: this, projectType: tabInfo.value[index].type);
  }

  Widget tabBuilder(context, index) => Tab(
    child: SizedBox(
      height: 40,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Row(
          children: [
            Flexible(
              fit: FlexFit.tight,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(tabInfo.value[index].name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              tooltip: "Close Tab",
              icon: const Icon(
                CupertinoIcons.xmark,
                color: Colors.black ,
                size: 12,
              ),
              onPressed: () {
                removeTab(index);
              },
            ),
          ],
        ),
      ),
    ),
  );

}

class TabPage extends StatefulWidget {
  final TabManager tabManager;
  final ProjectType projectType;

  const TabPage({
    required this.tabManager, 
    required this.projectType,
    super.key,
  });

  @override
  TabPageState createState() => TabPageState();
}

class TabPageState extends State<TabPage> with AutomaticKeepAliveClientMixin {
  PageController pageController = PageController();

  String? projectString;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          MonitorSelectionScreen(
            pageController: pageController,
            callback: (String val) {
              setState(() {
                projectString = val;
              });
            },
            tabManager: widget.tabManager,
            projectType: widget.projectType,
          ),
          MonitorScreen(
            project: projectString != null 
              ? Project(projectString!, widget.projectType) 
              : Project('default', widget.projectType),
          ),
        ],
      ),
    );
  }

}

