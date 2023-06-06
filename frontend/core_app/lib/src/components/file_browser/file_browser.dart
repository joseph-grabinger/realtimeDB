import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:filestorage_api/filestorage_api.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pdfx/pdfx.dart';

import '../others/popup_menu.dart';
import 'dialogs/add_folder_dialog.dart';
import 'dialogs/unsupported_type_dialog.dart';
import 'file_browser_controller.dart';
import 'file_view.dart';
import 'utils.dart';


class FileBrowser extends StatelessWidget {
  final FileBrowserController controller;

  FileBrowser({Key? key, required this.controller}) : super(key: key);


  final bool isMobile = Platform.isIOS || Platform.isAndroid;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: controller.stack.list.length > 1 ? [
          buildBackButton(),
          buildSortNameButton(),
          buildViewButton(),
        ] : [
          buildSortNameButton(),
          buildViewButton(),
        ],
      )),
      const Divider(height: 1),
      Expanded(
        child: buildPlatformGestureListener(
          context: context,
          child: RefreshIndicator(
            onRefresh: () async {
              return controller.refreshStructure();
            },
            color: Colors.grey,
            displacement: 0,
            child: Obx(() => controller.gridView.value ? SingleChildScrollView(
              controller: ScrollController(),
              clipBehavior: Clip.antiAlias,
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 400,
                  minWidth: double.infinity
                ),
                child: controller.currentDir.isNotEmpty ? Wrap(
                  runAlignment: WrapAlignment.start,
                  children: controller.currentDir.map((item) => InkWell(
                    onTap: () => onTap(item),
                    child: SizedBox(
                      height: 150,
                      width:  isMobile
                          ? calculateItemWidth(context, 17.0) : 170,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: !controller.isPush.value ? Builder(
                              builder: (BuildContext context) {
                                if (item is FolderM) {
                                  return Icon(Icons.folder,
                                    size: 100,
                                    color: Colors.grey[600],
                                  );
                                } else {
                                  switch(item.type) {
                                    case Type.image: {
                                      return Padding(
                                        padding: const EdgeInsets.only(top:8.0),
                                        child: Center(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10.0),
                                            child: controller.getNetworkImage(
                                                controller.path.value+item.name, BoxFit.cover),
                                          ),
                                        ),
                                      );
                                    }
                                    case Type.pdf: {
                                      return Padding(
                                        padding: const EdgeInsets.only(top:8.0),
                                        child: FutureBuilder(
                                          future: getPDFThumbnail(item),
                                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                                            if (snapshot.hasData) {
                                              return Image(
                                                image: MemoryImage(snapshot.data.bytes),
                                              );
                                            } else if(snapshot.hasError) {
                                              return const Center(
                                                child: Icon(
                                                  MdiIcons.filePngBox,
                                                  color: Colors.green,
                                                ),
                                              );
                                            } else {
                                              return const Center(
                                                child: CircularProgressIndicator(),
                                              );
                                            }
                                          },
                                        ),
                                      );
                                    }
                                    default: {
                                      return const Padding(
                                        padding:  EdgeInsets.only(top:8.0),
                                        child: Icon(MdiIcons.fileAlert, size: 50),
                                      );
                                    }
                                  }
                                }
                              },
                            ) : Container(),
                          ),
                          SizedBox(
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: item is FileM ? controller.getFileIcon(item.name) : Container(),
                                ),
                                Flexible(
                                  child: Text(
                                    item.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                PopupMenu(
                                  onSelected: (int value) => controller.defaultOnPopupSelected(
                                      value, controller.path.value+item.name, item is FileM),
                                  children: item is FileM
                                      ? controller.defaultPopupItems.where(
                                          (element) => element.value != 1).toList()
                                      : controller.defaultPopupItems.where(
                                        (element) => element.value != 1 &&
                                        element.value != 5 &&
                                        element.value != 6,
                                  ).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )).toList(),
                ) : const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 28.0),
                    child: Text('Dieses Verzeichnis ist leer.'),
                  ),
                ),
              ),
            ) : ListView.builder(
              controller: ScrollController(),
              itemCount: controller.currentDir.length,
              itemBuilder: (BuildContext context, int index) {
                var dir = controller.currentDir[index];
                return ListTile(
                  onTap: () => onTap(dir),
                  leading: dir is FolderM
                      ? const Icon(Icons.folder)
                      : controller.getFileIcon(dir.name),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child:
                        Text(dir.name,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(isMobile
                            ? controller.formatDateShort(dir.modified)
                            : controller.formatDate(dir.modified),
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenu(
                    onSelected: (int value) => controller.defaultOnPopupSelected(
                        value, controller.path.value+dir.name, dir is FileM),
                    children: dir is FileM
                        ? controller.defaultPopupItems.where(
                            (element) => element.value != 1).toList()
                        : controller.defaultPopupItems.where(
                          (element) => element.value != 1 &&
                          element.value != 5 &&
                          element.value != 6,
                    ).toList(),
                  ),
                );
              },
            )),
          ),
        ),
      ),
    ],
  );

  Future<PdfPageImage?> getPDFThumbnail(item) async {
    Uint8List internetFile = await controller.getPDFInetFile(
        controller.path.value+item.name);

    if (internetFile.isEmpty) return null;

    controller.currentFiles[item.name] = internetFile;
    final document = await PdfDocument.openData(internetFile);
    final page = await document.getPage(1);
    final pageImage = await page.render(width: page.width, height: page.height);
    await page.close();

    return pageImage;
  }

  /// Handles the tap on what could be a folder or a file.
  void onTap (dynamic dir) {
    if (dir is FolderM) {
      controller.push(dir);
    } else {
      switch(dir.type){
        case Type.pdf: {
          Get.dialog(FileView(
              file: !controller.gridView.value
                  ? controller.getPDFInetFile(controller.path.value+dir.name)
                  : controller.currentFiles[dir.name],
              title: RxString(dir.name),
              type: Type.pdf,
              filepath: controller.path.value, isMobile: isMobile,
            ),
            useSafeArea: false,
          );
        }
        break;
        case Type.image: {
          Get.dialog(FileView(
              file: controller.getNetworkImage(
                  controller.path.value+dir.name, BoxFit.cover),
              title: RxString(dir.name),
              type: Type.image,
              filepath: controller.path.value,
              isMobile: isMobile,
            ),
            useSafeArea: false,
          );
        }
        break;
        default: {
          Get.dialog(UnsupportedTypeDialog(filename: dir.name));
        }
      }
    }
  }

  /// Handles an alternate tap
  /// e.g. a long press on mobile, and a right click on desktop.
  /// Shows a popup menu with options ant the provided [globalPosition].
  Future<void> onAltPressed(Offset globalPosition, BuildContext context) async {
    final overlay = Overlay.of(context)?.context.findRenderObject() as RenderBox;

    final localOffset = overlay.globalToLocal(globalPosition);

    List<PopupMenuItem<int>> items = [
      buildPopupMenuItem('Einfügen', Icons.content_paste, 0, false),
      buildPopupMenuItem('Neuer Ordner', Icons.create_new_folder_rounded, 1, false),
    ];

    String? clipboardContent = (await Clipboard.getData(Clipboard.kTextPlain))!.text;
    String? clipboardPath;

    if (clipboardContent == null ||
        !clipboardContent.startsWith('!@?SHARE-APP-DATA?@!')) {
      items.removeAt(0);
    } else {
      clipboardPath = clipboardContent.split('!@?SHARE-APP-DATA?@!')[1];
    }

    int? selectedValue = await showMenu<int>(
      context: context,
      items: items,
      shape: popupMenuShape,
      position: RelativeRect.fromRect(
        localOffset & const Size(48.0, 48.0),
        Offset.zero & overlay.size,
      ),
    );
    if (selectedValue == null) return;

    if (selectedValue == 0) {
      // Paste
      await controller.fileStorage.copyFile(clipboardPath!,
          controller.path.value.substring(1));
    } else {
      // New Folder
      await Get.dialog(AddFolderDialog(
        path: controller.path.value,
      ));
    }
    await controller.refreshStructure();
  }

  Widget buildBackButton() => InkWell(
    onTap: () => controller.pop(),
    child: const Row(
      children: [
        Icon(Icons.chevron_left),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          child: Text('Zurück'),
        ),
      ],
    ),
  );

  Widget buildRefreshButton() => IconButton(
    icon: const Icon(Icons.refresh, color: Color(0xff888888)),
    splashRadius: 18.0,
    tooltip: 'Aktualisieren',
    onPressed: () async {
      await controller.refreshStructure();
    },
  );

  Widget buildSortNameButton() => Align(
    alignment: controller.stack.list.length > 1
        ? Alignment.center
        : Alignment.centerLeft,
    child: InkWell(
      onTap: () {
        if (!controller.descending.value) {
          controller.controller.reverse();
          controller.descending.value = true;
        } else {
          controller.controller.forward();
          controller.descending.value = false;
        }
        controller.currentDir.value = controller.currentDir.reversed.toList();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Row(
          children: [
            const Text('Name'),
            const SizedBox(width: 5),
            RotationTransition(
              turns: Tween<double>(
                begin: 0.0, end: 0.5,
              ).animate(controller.easeInAnimation),
              child: const Icon(Icons.arrow_upward, color: Color(0xff888888)),
            ),
          ],
        ),
      ),
    ),
  );

  Widget buildViewButton() => Align(
    alignment: Alignment.centerRight,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isMobile) buildRefreshButton(),
        if (!isMobile) const SizedBox(width: 8.0),
        IconButton(
          onPressed: () => controller.gridView.value = !controller.gridView.value,
          tooltip: 'Ansicht ändern',
          splashRadius: 15,
          icon: Icon(controller.gridView.value
              ? Icons.view_list_outlined
              : Icons.grid_view,
            color: const Color(0xff888888),
          ),
        ),
      ],
    ),
  );

  Widget buildPlatformGestureListener({required BuildContext context, required Widget child}) {
    if (isMobile) {
      return GestureDetector(
        onLongPressStart: (LongPressStartDetails details) async {
          await onAltPressed(details.globalPosition, context);
        },
        child: child,
      );
    } else {
      return Listener(
        onPointerDown: (PointerDownEvent event) async {
          if (event.kind == PointerDeviceKind.mouse &&
              event.buttons == kSecondaryMouseButton) {
            await onAltPressed(event.position, context);
          }
        },
        child: child,
      );
    }
  }

}
