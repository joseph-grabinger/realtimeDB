import 'package:flutter/material.dart';

import 'package:filestorage_api/filestorage_api.dart';

import 'package:get/get.dart';

import '../../others/app_expansion_tile.dart';
import '../file_browser_controller.dart';


class StorageLocationController extends GetxController {

  final GlobalKey<AppExpansionTileState> departmentKey =
          GlobalKey<AppExpansionTileState>();
  final GlobalKey<AppExpansionTileState> personalKey =
          GlobalKey<AppExpansionTileState>();

  final RxString path = ''.obs;

  FolderM? ownStruct;
  FolderM? departmentTray;
  List<FolderM> deps = [];

  String? insertPath;

  final RxBool initDone = false.obs;
  final RxBool depSelected = false.obs;
  final RxBool persSelected = false.obs;

  void Function(Function())? personalTraySetState;
  void Function(Function())? departmentTraySetState;

  final controller = Get.find<FileBrowserController>();

  @override
  void onInit() async {
    super.onInit();

    await controller.initCompleter.future;

    ownStruct = controller.allStructure?.folders.firstWhere(
            (element) => element.name == 'private_tray');

    initDone.value = true;

    await Future.delayed(const Duration(milliseconds: 200));

    // only needed by StorageLocationDialog,
    // not needed if just used by FilesTreeView
    // (like in DragDialog)
    personalKey.currentState?.tileIsExpanded.listen((bool val) {
      persSelected.value = val;
    });
  }

  void addFolderToPath(String folderName, String path) {
    FolderM currentDir;
    bool? isDepartment;

    if (path.startsWith('personal_tray')) {
      currentDir = ownStruct!;
      isDepartment = false;
    } else {
      currentDir = departmentTray!;
      isDepartment = true;
    }

    List<String> pathParts = path.split('/');
    int index = 1;

    while (index < pathParts.length-1) {
      currentDir = currentDir.folders.firstWhere(
              (element) => element.name == pathParts[index]);
      index++;
    }

    currentDir.folders.add(FolderM(
        name: folderName,
        folders: [],
        files: [],
        modified: DateTime.now(),
    ));

    insertPath = '$path$folderName/';

    if (isDepartment) {
      departmentTraySetState!(() {});
    } else {
      personalTraySetState!(() {});
    }
  }

}