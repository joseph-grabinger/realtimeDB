import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'model.dart';


class FileBrowserController extends GetxController
    with GetSingleTickerProviderStateMixin {
  RxString path;
  FolderM? dirStructure;
  bool isDepartment;

  FileBrowserController({
    required this.path,
    required this.dirStructure,
    this.isDepartment = false,
  });

  final homeController = Get.find<HomeController>();

  NavStack stack = NavStack<FolderM?>();

  final RxList<dynamic> currentDir = [].obs;
  final RxMap<String, dynamic> currentFiles = <String, dynamic>{}.obs;
  final RxBool isPush = false.obs;
  final RxBool descending = true.obs;
  final RxBool gridView = true.obs;

  late AnimationController controller;
  late CurvedAnimation easeInAnimation;
  final Duration kExpand = const Duration(milliseconds: 250);

  late final String ogPath;

  @override
  void onInit() async {
    ogPath = path.value;
    controller = AnimationController(duration: kExpand, vsync: this);
    easeInAnimation = CurvedAnimation(parent: controller, curve: Curves.easeIn);

    if (dirStructure != null) {
      currentDir.addAll(dirStructure!.folders);
      currentDir.addAll(dirStructure!.files);
      currentDir.sort((a,b) => a.compareTo(b));

      stack.push(dirStructure!);
    }

    super.onInit();
  }

  /// Pushes a given [dir] to the [stack] and updates the [currentDir].
  void push(FolderM dir) {
    isPush.value = true;
    currentFiles.clear();
    stack.push(dir);
    print("Pushed: ${dir.name}");
    currentDir.clear();
    currentDir.addAll(dir.folders);
    currentDir.addAll(dir.files);
    path.value += dir.name + '/';

    if (descending.value) {
      currentDir.sort((a,b) => a.compareTo(b));
    } else {
      currentDir.sort((a,b) => b.compareTo(a));
    }

    isPush.value = false;
  }

  /// Pops a given [dir] of the [stack] and updates the [currentDir].
  void pop() {
    isPush.value = true;
    currentFiles.clear();
    FolderM f = stack.pop();
    print("Popped: ${f.name}");
    FolderM dir = stack.peek;
    currentDir.clear();
    currentDir.addAll(dir.folders);
    currentDir.addAll(dir.files);

    if (descending.value) {
      currentDir.sort((a,b) => a.compareTo(b));
    } else {
      currentDir.sort((a,b) => b.compareTo(a));
    }

    if (ogPath != path.value) {
      var parts = path.value.split('/');
      parts.removeAt(parts.length-2);
      path.value = parts.join('/');
    }

    isPush.value = false;
  }

  /// Refreshes the structure of the current directory based on the current [path].
  /// The fetched structure then updates [homeController.allStructure],
  /// is then pushed to the [stack] and the [currentDir] is updated.
  Future<void> refreshStructure() async {
    currentFiles.clear();

    FolderM? dirStructure;

    path.value = ogPath;

    dirStructure = await homeController.getStructure(path.value);

    if (dirStructure == null) {
      print('StacError on Refresh');
      return;
    }

    // replace the current path in allStructure with the new dirStructure
    List<String> pathParts = path.value.split('/');
    FolderM? currentAllStructure = homeController.allStructure;
    if (pathParts[1] == 'department_tray') {
      for (int i = 1; i < pathParts.length-1; i++) {
        currentAllStructure = currentAllStructure!.folders.firstWhere(
          (element) => element.name == pathParts[i],
          orElse: () {
            print("added to allStructure: ${pathParts[i]}");
            FolderM folder = FolderM(name: pathParts[i], folders: [], files: [], modified: DateTime.now());
            currentAllStructure!.folders.add(folder);
            return folder;
          },
        );
      }
    } else {  // private_tray
      currentAllStructure = currentAllStructure!.folders.firstWhere(
              (element) => element.name == pathParts[pathParts.length-2]);
    }
    currentAllStructure!.folders = dirStructure.folders;
    currentAllStructure.files = dirStructure.files;

    // replace the stack with the new dirStructure
    FolderM? current = dirStructure;

    stack.list[0] = dirStructure;

    for (int i = 1; i < stack.list.length; i++) {
      List<FolderM> dirs = current!.folders;
      print('Stack $i: ${stack.list[i].name}');
      for(dynamic d in dirs) {
        if (d.name == stack.list[i].name) {
          path.value += '${d.name}/';
          stack.list[i] = d;
          current = d;
        }
      }
    }

    currentDir.clear();
    currentDir.addAll(current?.folders ?? []);
    currentDir.addAll(current?.files ?? []);
    currentDir.sort((a,b) => a.compareTo(b));
  }

}
