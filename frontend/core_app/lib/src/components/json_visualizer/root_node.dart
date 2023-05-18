import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class RootNode extends StatefulWidget {
  const RootNode({super.key});

  @override
  State<RootNode> createState() => _RootNodeState();
}

class _RootNodeState extends State<RootNode> {
  bool _hovering = false;


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
      child: Container(
        height: 35,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey),
          color: Colors.grey[300],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Root"),
              _hovering
                  ? Padding(
                    padding: const EdgeInsets.only(left: 7.0),
                    child: Container(
                      height: double.infinity,
                      decoration: BoxDecoration(
                        border:  Border.all(
                          color: Colors.grey,
                          width: 0.0,
                        ),
                      ),
                    ),
                  )
                  : Container(),
              _hovering
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
              _hovering
                  ? IconButton(
                padding: const EdgeInsets.all(0),
                icon: const Icon(
                  CupertinoIcons.xmark,
                  color: Colors.black,
                  size: 15,
                ),
                onPressed: () {},
              )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
