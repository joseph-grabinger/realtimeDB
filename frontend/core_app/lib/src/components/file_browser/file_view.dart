import 'dart:async';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:filestorage_api/filestorage_api.dart';

import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';
import 'package:cross_file/cross_file.dart';

import 'file_browser_controller.dart';
import '../others/back_text_button.dart';
import '../others/popup_menu.dart';



class FileView extends StatefulWidget {
  final dynamic file;
  final RxString title;
  final Type type;
  final String filepath;
  final void Function(int)? onPopupSelected;
  final List<PopupMenuItem<int>>? popupChildren;
  final bool isMobile;

  const FileView({
    Key? key,
    required this.file,
    required this.title,
    required this.type,
    required this.filepath,
    required this.isMobile,
    this.onPopupSelected,
    this.popupChildren,
  }) : super(key: key);

  @override
  State<FileView> createState() => _FileViewState();
}

class _FileViewState extends State<FileView> {
  final BoxDecoration backgroundDeco = const BoxDecoration(
    color: Colors.white,
  );

  final RxBool _isLoading = true.obs;

  PdfControllerPinch? pdfControllerPinch;
  PdfController? pdfController;

  final controller = Get.find<FileBrowserController>();

  void asyncInit() async {
    if (widget.file is Future) {
      await widget.file!;
    }

    if (widget.file is Uint8List && (widget.file as Uint8List).isEmpty) return;

    if (widget.type == Type.pdf) {
      if (!Platform.isWindows) {
        pdfControllerPinch = PdfControllerPinch(
          document: PdfDocument.openData(widget.file),
        );
      } else {
        pdfController = PdfController(
          document: PdfDocument.openData(widget.file),
        );
      }

    }
    _isLoading.value = false;
  }

  @override
  void initState() {
    asyncInit();
    super.initState();
  }

  @override
  void dispose() {
    pdfControllerPinch?.dispose();
    pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double topViewPadding = MediaQuery.of(context).viewPadding.top;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: widget.isMobile
                      ? topViewPadding
                      : 50 + topViewPadding,
              ),
              child: Obx(() => !_isLoading.value ? Builder(
                builder: (BuildContext context) {
                  switch (widget.type) {
                    case Type.pdf: {
                      if (!Platform.isWindows) {
                        return PdfViewPinch(
                          controller: pdfControllerPinch!,
                          scrollDirection: Axis.vertical,
                          backgroundDecoration: backgroundDeco,
                          builders: const PdfViewPinchBuilders<DefaultBuilderOptions>(
                            options: DefaultBuilderOptions(
                              loaderSwitchDuration: Duration(milliseconds: 100),
                            ),
                          ),
                        );
                      } else {
                        return PdfView(
                          controller: pdfController!,
                          scrollDirection: Axis.vertical,
                          backgroundDecoration: backgroundDeco,
                          builders: const PdfViewBuilders<DefaultBuilderOptions>(
                            options: DefaultBuilderOptions(
                              loaderSwitchDuration: Duration(milliseconds: 100),
                            ),
                          ),
                        );
                      }
                    }
                    case Type.image: {
                      return PhotoView(
                        imageProvider: widget.file is XFile
                            ? AssetImage(widget.file!.path) : widget.file.image,
                        backgroundDecoration: backgroundDeco,
                        minScale: PhotoViewComputedScale.contained,
                      );
                    }
                    default: {
                      print("In default... type is ${widget.file.runtimeType}");
                      return Container();
                    }
                  }
                },
              ) : const Center(
                child: CircularProgressIndicator(),
              )),
            ),
            Container(
              height: 50 + topViewPadding,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[200]!,
                    width: 2,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: widget.isMobile ? topViewPadding : 8.0,
                  bottom: 8.0, left: 8.0, right: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: BackTextButton(text: 'Zurück'),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                        child: Obx(() => Text(widget.title.value,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 40.0),
                        child: PopupMenu(
                          icon: const Icon(Icons.more_horiz, color: Colors.blue),
                          onSelected: (int value) {
                            if (widget.onPopupSelected != null) {
                              widget.onPopupSelected!(value);
                            } else {
                              controller.defaultOnPopupSelected(value,
                                widget.filepath+widget.title.value, true,
                                onDone: (int value, String? newTitle) {
                                  switch (value) {
                                    case 3: {
                                      // delete
                                      Get.back();
                                    } break;
                                    case 4: {
                                      // rename
                                      if (newTitle != '' && newTitle != null) {
                                        widget.title.value = newTitle;
                                      }
                                    } break;
                                  }
                                });
                            }
                          },
                          children: widget.popupChildren ?? controller.defaultPopupItems.where(
                                  (element) => element.value != 1).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
