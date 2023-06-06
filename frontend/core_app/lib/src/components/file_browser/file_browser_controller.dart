import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:filestorage_api/filestorage_api.dart';

import 'package:get/get.dart';
import 'package:internet_file/internet_file.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../others/custom_snackbar.dart';
import '../others/popup_menu.dart';
import 'dialogs/delete_dailog.dart';
import 'dialogs/rename_dialog.dart';
import 'dialogs/storage_location_controller.dart';
import 'dialogs/storage_location_dialog.dart';
import 'model.dart';


class FileBrowserController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final FileStorage fileStorage;
  RxString path;
  FolderM? dirStructure;
  bool isDepartment;

  FileBrowserController({
    required this.fileStorage,
    required this.path,
    required this.dirStructure,
    this.isDepartment = false,
  });

  final bool isMobile = Platform.isIOS || Platform.isAndroid;

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

  final List<PopupMenuItem<int>> defaultPopupItems = [
    buildPopupMenuItem('Copy', Icons.copy, 0, false),
    buildPopupMenuItem('Open path', Icons.open_in_browser, 1, false),
    buildPopupMenuItem('Move', Icons.drive_file_move_outline, 2, false),
    buildPopupMenuItem('Delete', Icons.delete, 3, true),
    buildPopupMenuItem('Rename', Icons.drive_file_rename_outline, 4, false),
    buildPopupMenuItem('Download', Icons.download, 5, false),
  ];

  FolderM? allStructure;
  final Completer initCompleter = Completer();

  @override
  void onInit() async {
    initCompleter.future;
    allStructure = await fileStorage.getStructure('/');
    if (allStructure == null) {
      print("error on getting all structure");
      initCompleter.completeError("getStructure('/all') returned null");
    } else {
      initCompleter.complete();
    }

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
    path.value += '${dir.name}/';

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

    dirStructure = await fileStorage.getStructure(path.value);

    if (dirStructure == null) {
      print('StacError on Refresh');
      return;
    }

    // replace the current path in allStructure with the new dirStructure
    List<String> pathParts = path.value.split('/');
    FolderM? currentAllStructure = allStructure;
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

   /// Handles selection of all [defaultPopupItems].
  /// [value] corresponds to the index of the selected item.
  /// [onDone] can be used as a extra callback after the default action.
  void defaultOnPopupSelected(int value, String filepath, bool isFile,
      {void Function(int, String?)? onDone}) async {
    String? newTitle;

    switch (value) {
      case 0: {
        // copy
        print('Copied: $filepath');
        Clipboard.setData(ClipboardData(
          text: '!@?SHARE-APP-DATA?@!$filepath',
        ));
      } break;
      case 1: {
        // open path
        print('Open path: $filepath');
        var parts = filepath.split('/');
        parts.removeLast();
        String path = '${parts.join('/')}/';
        print('Path: $path');
        openPath(path);
      } break;
      case 2: {
        // move
        Get.put(StorageLocationController());
        final storageLocationController = Get.find<StorageLocationController>();

        await Get.dialog(
          StorageLocationDialog(
            buttonLabel: 'Move',
            onDone: () async {
              var parts = filepath.split('/');
              String filename = parts.last;
              parts.removeLast();
              String source = '${parts.join('/')}/';
              String destination = storageLocationController.path.value;

              await fileStorage.moveFile(filename, source, destination);
              await refreshStructure(); // was by path for src and dst
            },
          ),
          barrierDismissible: false,
        );
      }
      break;
      case 3: {
        // delete
        print("delete called with: $filepath");
        var parts = filepath.split('/');
        String filename = parts.removeLast();
        String path = '${parts.join('/')}/';

        await Get.dialog(DeleteDialog(
            path: path, filename: filename),
          barrierDismissible: false,
        );

        await refreshStructure(); // was by path
      } break;
      case 4: {
        // rename
        var parts = filepath.split('/');
        String filename = parts.removeLast();
        String path = '${parts.join('/')}/';
        newTitle = await Get.dialog(RenameDialog(
          path: path,
          filename: filename,
          isFile: isFile,
        ));
        await refreshStructure(); // was by path
      } break;
      case 5: {
        // download
        await downloadFile(filepath);
      } break;
    }

    if (onDone != null) onDone(value, newTitle);
  }

  /// Opens the provided [path] in the corresponding [FileBrowser],
  /// by locating the [FileBrowserController].
  void openPath(String path) {
    List<String> pathParts = [];
    FolderM? current;

    currentDir.clear();
    stack.list.clear();
    stack.push(dirStructure!);
    this.path.value = ogPath;

    pathParts = path.split('/');
    pathParts.removeRange(0, 4);
    
    current = dirStructure!;

    for (String s in pathParts) {
      if (s == '') {
        // this case was only used when pathPArts == '' && pathPArts.length == 1
        currentDir.clear();
        currentDir.addAll(current!.folders);
        currentDir.addAll(current.files);
        if (descending.value) {
          currentDir.sort((a,b) => a.compareTo(b));
        } else {
          currentDir.sort((a,b) => b.compareTo(a));
        }
        continue;
      }
      current = current!.folders.firstWhere(
              (element) => element.name == s);
      push(current);
    }
  }

   /// Saves to file at the given [path] to the local downloads folder.
  /// Expects [path] to be a file path, not a directory path
  /// and expects [path] to  NOT have a leading slash.
  Future<void> downloadFile(String path) async {
    Directory? downloadsDir;

    if (!isMobile) {
      downloadsDir = await getDownloadsDirectory();
    } else {
      if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      } else {
        downloadsDir =  await getExternalStorageDirectory();
      }
    }

    String downloadsPath = downloadsDir!.path;

    try {
      Uint8List internetFile = await InternetFile.get(
        '${fileStorage.projectUrl}/get_file?filepath=$path',
      );

      String filename = path.split('/').last;


      File file = File('$downloadsPath/$filename');
      var raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(internetFile!);
      await raf.close();

      showSnackbar('Download complete', 'path: $downloadsPath/$filename');

    } on PlatformException catch (e) {
      print("Error on download file: $e");
      showSnackbar('Download Error', 'Unknown Error.');
    }
  }

    Future<Uint8List> getPDFInetFile(String filepath) async {
    try {
      Uint8List internetFile = await InternetFile.get(
        '${fileStorage.projectUrl}/get_file?filepath=$filepath',
      );
      return internetFile;
    } on PlatformException catch (e) {
      print("Error on getPDFInetFile: $e");
      return Uint8List(0);
    }
  }

  Image getNetworkImage(String filepath, BoxFit fit) => Image.network(
    '${fileStorage.projectUrl}/get_file?filepath=$filepath',
    errorBuilder: (context, error, stackTrace) {
      return const SizedBox(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 40),
            SizedBox(width: 10),
            Text(
              'Fehler beim laden der Vorschau',
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    },
    fit: fit,
  );

  Icon getFileIcon(String filename) {
    String fileType = filename.split('.').last.toLowerCase();
    switch (fileType) {
      case 'pdf': return const Icon(MdiIcons.filePdfBox, color: Colors.red);
      case 'mp4': return const Icon(MdiIcons.movie, color: Colors.red);
      case 'jpg': return const Icon(MdiIcons.fileJpgBox, color: Colors.green);
      case 'jpeg': return const Icon(MdiIcons.fileJpgBox, color: Colors.green);
      case 'png': return const Icon(MdiIcons.filePngBox, color: Colors.green);
      case 'tiff': return const Icon(Icons.image_outlined, color: Colors.green);
      case 'tif': return const Icon(Icons.image_outlined, color: Colors.green);
      default: return const Icon(Icons.file_present, color: Colors.black54);
    }
  }

  String formatDate(DateTime date) => DateFormat("dd.MM.yyyy hh:mm").format(date);

  String formatDateShort(DateTime date) => DateFormat("dd.MM.yy").format(date);

}
