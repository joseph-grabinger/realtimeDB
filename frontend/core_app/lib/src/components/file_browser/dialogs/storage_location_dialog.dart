import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../others/app_expansion_tile.dart';
import '../model.dart';
import 'add_folder_dialog.dart';
import 'storage_location_controller.dart';

Widget title(String title, IconData iconData) => Row(
  children: [
    Icon(iconData, color: Colors.grey.shade600),
    const SizedBox(width: 12.0),
    Expanded(child: Text(title, overflow: TextOverflow.ellipsis)),
  ],
);

/// A dialog to select a storage location from either the users personal tray
/// or a department tray.
class StorageLocationDialog extends GetView<StorageLocationController> {
  final String buttonLabel;
  final Future Function() onDone;

  const StorageLocationDialog({
    Key? key,
    required this.buttonLabel,
    required this.onDone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 8.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 500,
        maxWidth: 500,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        Get.back();
                        Get.delete<StorageLocationController>();
                      },
                      child: const Text('Abbrechen', maxLines: 1),
                    ),
                  ),
                ),
                const Text('Speicherort wählen',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Obx(() => IconButton(
                      onPressed: () async {
                        String? result = await Get.dialog(AddFolderDialog(
                          path: '/${controller.homeController.cleanPath(controller.path.value)}',
                        ));

                        if (result != null) {
                          // add folder to structure
                          controller.addFolderToPath(result, controller.path.value);
                        }
                      },
                      icon: Icon(CupertinoIcons.folder_badge_plus,
                        color: (controller.depSelected.value &&
                            controller.path.value.split('/').length >= 4) ||
                            controller.persSelected.value
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      tooltip: 'Ordner erstellen',
                      splashRadius: 10,
                    )),
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              controller: ScrollController(),
              children: const [
                FilesTreeView(buildTitle: title),
              ],
            ),
          ),
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Center(
              child: Obx(() => CupertinoButton(
                onPressed: () async {
                  await onDone();
                  Get.back();
                  Get.delete<StorageLocationController>();
                },
                  color: (controller.depSelected.value &&
                      controller.path.value.split('/').length >= 4) ||
                      controller.persSelected.value
                    ? Colors.blue
                    : Colors.grey,
                child: Text(buttonLabel),
              )),
            ),
          ),
        ],
      ),
    ),
  );
}

class FilesTreeView extends StatefulWidget {
  final Widget Function(String, IconData) buildTitle;

  const FilesTreeView({
    Key? key,
    required this.buildTitle,
  }) : super(key: key);

  @override
  State<FilesTreeView> createState() => _FilesTreeViewState();
}

class _FilesTreeViewState extends State<FilesTreeView> {
  final controller = Get.find<StorageLocationController>();

  @override
  void initState() {
    super.initState();

    controller.personalTraySetState = setState;
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    List<GlobalKey<AppExpansionTileState>> keys = controller.ownStruct != null
        ? List.generate(
          controller.ownStruct!.folders.length,
              (index) => GlobalKey<AppExpansionTileState>())
        : [];

    List<BKey> bKeys = controller.ownStruct != null
        ? List.generate(controller.ownStruct!.folders.length,
            (index) => BKey(false.obs))
        : [];
    return AppExpansionTile(
      key: controller.personalKey,
      title: widget.buildTitle('Dateien', Icons.folder_outlined),
      initiallyExpanded: controller.insertPath != null &&
          controller.insertPath!.startsWith('personal_tray'),
      onExpansionChanged: (bool expanded) {
        if (expanded) {
          controller.path.value = 'personal_tray/';
          if (controller.departmentKey.currentState != null) {
            controller.departmentKey.currentState!.collapse();
          }
        } else {
          // remove from path until [personal_tray] is removed
          List<String> parts = controller.path.value.split('/');
          while (true) {
            if (parts.isEmpty) break;
            if (parts.last == 'personal_tray') {
              parts.removeLast();
              break;
            } else {
              parts.removeLast();
            }
          }
          controller.path.value = parts.join('/') + '/';
        }
      },
      children: controller.initDone.value ? controller.ownStruct!.folders.map(
            (FolderM element) {
              List<GlobalKey<AppExpansionTileState>> others = [];
              List<BKey> otherBKeys = [];
          int index = controller.ownStruct!.folders.indexOf(element);
          var k = keys[index];

          for (int i = 0; i < keys.length; i++) {
            if (keys[i] != k) {
              others.add(keys[i]);
              otherBKeys.add(bKeys[i]);
            }
          }
          var bKey = bKeys[index];
          return Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: DirItem(
              dir: element,
              gKey: k, bKey: bKey,
              otherKeys: others, otherBKeys: otherBKeys,
              path: 'personal_tray/${element.name}/',
              buildTitle: widget.buildTitle,
            ),
          );
        },
      ).toList() : [],
    );
  });
}

class DirItem extends StatefulWidget {
  final FolderM dir;
  final GlobalKey<AppExpansionTileState> gKey;
  final BKey bKey;
  final List<GlobalKey<AppExpansionTileState>> otherKeys;
  final List<BKey> otherBKeys;
  final String path;
  final Widget Function(String, IconData) buildTitle;

  DirItem({
    Key? key,
    required this.dir,
    required this.gKey,
    required this.bKey,
    required this.otherKeys,
    required this.otherBKeys,
    required this.path,
    required this.buildTitle,
  }) : super(key: key) {
    len = dir.folders.length;
    keys = List.generate(len, (index) => GlobalKey<AppExpansionTileState>());
    bKeys = List.generate(len, (index) => BKey(false.obs));
  }

  late final List<GlobalKey<AppExpansionTileState>> keys;
  late final List<BKey> bKeys;
  late final int len;

  @override
  State<DirItem> createState() => _DirItemState();
}

class _DirItemState extends State<DirItem> {

  late Widget title;

  final storageLocationController = Get.find<StorageLocationController>();

  void unselectAll() {
    for (int i = 0; i < widget.otherKeys.length; i++) {
      if (widget.otherKeys[i].currentState != null
          && widget.otherKeys[i].currentState!.tileIsExpanded.value) {
        widget.otherKeys[i].currentState!.collapse();
      }
      if (widget.otherBKeys[i].val.value) {
        widget.otherBKeys[i].val.value = false;
      }
    }
  }

  void unselectAllChildren() {
    for (int i = 0; i < widget.len; i++) {
      if (widget.keys[i].currentState != null
          && widget.keys[i].currentState!.tileIsExpanded.value
          && widget.keys[i] == widget.gKey) {
        widget.keys[i].currentState!.collapse();
      }
      if (widget.bKeys[i].val.value) {
        widget.bKeys[i].val.value = false;
      }
    }
  }

  @override
  void initState() {
    title = widget.buildTitle(widget.dir.name, Icons.folder_outlined);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.dir.folders.isNotEmpty ? AppExpansionTile(
      key: widget.gKey,
      title: title,
      initiallyExpanded: storageLocationController.insertPath != null &&
          storageLocationController.insertPath!.startsWith(widget.path),
      onExpansionChanged: (bool expanded) {
        if (expanded) {
          unselectAll();
          storageLocationController.path.value = widget.path;
        } else {
          unselectAllChildren();

          // remove from path until [widget.dir.name] is removed
          List<String> parts = storageLocationController.path.value.split('/');
          while (true) {
            if (parts.last == widget.dir.name) {
              parts.removeLast();
              break;
            } else {
              parts.removeLast();
            }
          }
          storageLocationController.path.value = parts.join('/') + '/';
        }
      },
      children: widget.dir.folders.map((e) {
        int index = widget.dir.folders.indexOf(e);
        var k = widget.keys[index];
        var bKey = widget.bKeys[index];
        List<GlobalKey<AppExpansionTileState>> others = [];
        List<BKey> otherBKeys = [];
        for (int i = 0; i < widget.keys.length; i++) {
          if (widget.keys[i] != k) {
            others.add(widget.keys[i]);
            otherBKeys.add(widget.bKeys[i]);
          }
        }
        return Padding(
          padding: const EdgeInsets.only(
            left: 30.0,
            right: 8.0,
            top: 8.0,
            bottom: 8.0,
          ),
          child: DirItem(
            dir: e,
            gKey: k,
            bKey: bKey,
            otherKeys: others,
            otherBKeys: otherBKeys,
            path: '${widget.path}${e.name}/',
            buildTitle: widget.buildTitle,
          ),
        );
      }).toList(),
    ) : Obx(() => ListTile(
      hoverColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.only(left: 18),
      onTap: () {
        widget.bKey.val.value = !widget.bKey.val.value;
        if (widget.bKey.val.value) {
          unselectAll();
          storageLocationController.path.value = widget.path;
        }
      },
      title: Row(
        children: [
          Icon(Icons.folder_outlined, color: Colors.grey.shade600),
          const SizedBox(width: 12.0),
          Text(widget.dir.name,
            style: widget.bKey.val.value
              ? const TextStyle(color: Colors.blue)
              : null,
          ),
        ],
      ),
    ));
  }
}


class BKey {
  RxBool val;

  BKey(this.val);
}
