import 'package:flutter/material.dart';


class PopupMenu extends StatelessWidget {
  final void Function(int)? onSelected;
  final List<PopupMenuItem<int>> children;
  final Widget? icon;

  const PopupMenu({
    Key? key,
    required this.onSelected,
    required this.children,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      onSelected: onSelected,
      shape: popupMenuShape,
      tooltip: 'Options',
      splashRadius: 17,
      icon: icon,
      itemBuilder: (BuildContext context) => children,
    );
  }
}

final  RoundedRectangleBorder popupMenuShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(10),
);

PopupMenuItem<int> buildPopupMenuItem(String title,
  IconData iconData, int value, bool destructive) => PopupMenuItem<int>(
  value: value,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      Icon(
        iconData,
        color: destructive ? Colors.red : Colors.black,
      ),
      const SizedBox(width: 8.0),
      Text(title, style: TextStyle(color: destructive ? Colors.red : Colors.black)),
    ],
  ),
);
