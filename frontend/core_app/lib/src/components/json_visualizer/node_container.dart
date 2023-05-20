import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:core_api/core_api.dart';

import 'package:core_app/src/components/json_visualizer/dialogs/delete_dialog.dart';


class NodeContainer extends StatefulWidget {
  const NodeContainer({
    required this.depth,
    required this.data,
    required this.dbRef,
    super.key,
  });

  final int depth;
  final MapEntry<dynamic, dynamic> data;
  final DatabaseReference dbRef;

  @override
  NodeContainerState createState() => NodeContainerState();
}

class NodeContainerState extends State<NodeContainer> {
  bool _hovering = false;

  late TextEditingController _textController;
  late FocusNode _focusNode, _focusNodeKey;
  late ValueNotifier<String> _text;
  late String _oldText;


  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNodeKey = FocusNode();
    _textController = TextEditingController(text: widget.data.value.toString());
    _text = ValueNotifier<String>(_textController.text);
    _oldText = widget.data.value.toString();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _focusNodeKey.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          _hovering = true;
        });
      },
      onExit: (event) {
        setState(() {
          _hovering = false;
        });
      },
      child: RawKeyboardListener(
        focusNode: _focusNodeKey,
        onKey: (RawKeyEvent event) {
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            _focusNode.unfocus();
            _textController.text = _oldText;
            setState(() {
              _hovering = false;
            });
          }
        },
        child: Container(
          height: 35,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                (!_hovering && !_focusNode.hasFocus) || widget.depth > 1 ? Text(
                  widget.depth > 1
                      ? widget.data.key
                      : "${widget.data.key} : ${widget.data.value}",
                ) : Container(),
                (_hovering  || _focusNode.hasFocus) && !(widget.depth > 1) ? Row(
                  children: [
                    Text(
                      widget.depth > 1
                          ? widget.data.key
                          : "${widget.data.key} :",
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: ValueListenableBuilder(
                        valueListenable: _text,
                        builder: (BuildContext context, String text, Widget? child) {
                          return SizedBox(
                            width: getTextSize(text) + 50,
                            child: TextField(
                              maxLines: 1,
                              controller: _textController,
                              focusNode: _focusNode,
                              onChanged: (String val) {
                                _text.value = val;
                              },
                              onTap: () async {
                                if (!_focusNode.hasFocus) {
                                  for (var element in _focusNode.ancestors) {
                                    element.unfocus();
                                  }
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) => _focusNode.requestFocus());
                                }

                              },
                              onSubmitted: _onSubmitted,
                              cursorColor: Colors.grey,
                              decoration: InputDecoration(
                                focusColor: Theme.of(context).primaryColor,
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide:  BorderSide(color: Colors.purple),
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ) : Container(),
                _hovering ? Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 7.0),
                      child: Container(
                        height: double.infinity,
                        decoration: widget.depth > 1
                            ? BoxDecoration(
                          border:  Border.all(
                            color: Colors.grey,
                            width: 0.0,
                          ),
                        )
                            : null,
                      ),
                    ),
                    widget.depth > 1
                        ? IconButton(
                      padding: const EdgeInsets.all(0),
                      icon: const Icon(
                        CupertinoIcons.add,
                        color: Colors.black,
                        size: 15,
                      ),
                      onPressed: () {},
                    )
                        : Container(),
                    IconButton(
                      padding: const EdgeInsets.all(0),
                      icon: const Icon(
                        CupertinoIcons.xmark,
                        color: Colors.black,
                        size: 15,
                      ),
                      onPressed: _onDelete,
                    ),
                  ],
                ) : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onDelete() {
    showDialog(
      context: context,
      builder: (context) => DeleteDialog(dbRef: widget.dbRef));
  }

  void _onSubmitted(String val) async {
    dynamic castedVal = castType(val);
    widget.dbRef.update(castedVal);
    debugPrint(val);
    debugPrint("castedVal: $castedVal");
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _hovering = false;
    });
  }

  /// checks whether the given String [s] contains a leading 0
  bool leadingZero(String s) {
    return (s.length > 1 && s[0] == '0');
  }

  /// casts the original primitive type from a given String [str]
  dynamic castType(String str) {
    if (str == "true") return true;
    if (str == "false") return false;
    if (!leadingZero(str)) {
      var i = int.tryParse(str);
      if (i == null) {
        var d = double.tryParse(str);
        if (d == null) {
          return str;
        } else {
          return d;
        }
      } else {
        return i;
      }
    } else {
      return str;
    }
  }

  /// returns the rendered size of a given [text] as a Widget
  double getTextSize(String text) {
    const constraints = BoxConstraints(
      maxWidth: double.infinity,
      minHeight: 0.0,
      minWidth: 0.0,
    );

    RenderParagraph renderParagraph = RenderParagraph(
      TextSpan(
        text: text,
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );

    renderParagraph.layout(constraints);

    return renderParagraph.getMinIntrinsicWidth(20);
  }

}
