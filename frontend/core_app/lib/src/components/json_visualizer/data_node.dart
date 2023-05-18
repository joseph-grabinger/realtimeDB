import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:core_api/database_reference.dart';

import 'node_container.dart';

class DataNode extends StatefulWidget {
  const DataNode({
    required this.dataIt,
    required this.dbRef,
    super.key,
  });

  final Iterable<MapEntry<dynamic, dynamic>> dataIt;
  final DatabaseReference dbRef;

  @override
  DataNodeState createState() => DataNodeState();
}

class DataNodeState extends State<DataNode> {
  List<int> depthLst = [];
  List<Iterable<MapEntry<dynamic, dynamic>>> childData = [];
  List<bool> maximizedLst = [];
  List<String> childPaths = [];

  @override
  void initState() {
    super.initState();
    for (var _ in widget.dataIt) {
      maximizedLst.add(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("DataNode: ${widget.dataIt}");
    childPaths.clear();
    depthLst.clear();
    childData.clear();

    for (var element in widget.dataIt) {
      childPaths.add(getChild(element));
      depthLst.add(totalDepth(element));
      childData.add(genChildData(element));
    }

    debugPrint("Childdata : $childData");

    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          widget.dataIt.length, (int index) {


          return Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          height: 20,
                          width: 20,
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Colors.black),
                              bottom: BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                        index != widget.dataIt.length - 1
                            ? Container(
                          height: depthLst[index]-2 < 0 || !maximizedLst[index]
                              ? 26.0
                              : 26.0 + (depthLst[index]-1) * 50.0,
                          width: 20,
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Colors.black),
                            ),
                          ),
                        )
                            : SizedBox(
                          height: depthLst[index]-2 < 0 || !maximizedLst[index]
                              ? 26.0
                              : 26.0 + (depthLst[index]-1) * 50.0,
                          width: 20,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NodeContainer(
                            depth: depthLst[index],
                            data: widget.dataIt.elementAt(index),
                            dbRef: widget.dbRef.child(childPaths[index]),
                          ),
                          depthLst[index] > 1 && maximizedLst[index]
                              ? DataNode(
                            dataIt: childData[index],
                            dbRef: widget.dbRef.child(childPaths[index]),
                          )
                              : Container(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              collapseButton(index),
            ],
          );
        },
        ),
      ),
    );
  }

  Widget collapseButton(int index) {
    if (depthLst[index] > 1) {
      return Positioned(
        top: -6,
        left: -15,
        child: CupertinoButton(
          onPressed: () {
            setState(() {
              maximizedLst[index] = !maximizedLst[index];
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: maximizedLst[index] ? Colors.grey : Colors.black,
                ),
              ),
              Positioned(
                bottom: maximizedLst[index] ? 6 : -2,
                right: -2,
                child: Icon(
                  maximizedLst[index] ? Icons.minimize : Icons.add,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  /// generates child data of given [data]
  Iterable<MapEntry<dynamic, dynamic>> genChildData(MapEntry<dynamic, dynamic> data) {
    if (data.value is List) {
      //print("isList");
      return Iterable.generate(data.value.length, (index) {
        return MapEntry(
          data.value[index].keys.first,
          data.value[index].values.first,
        );
      });
    } else if (data.value is Map) {
      //print("isMap");
      Map m = data.value;
      return Iterable.generate(m.entries.length, (index) {
        return MapEntry(
          m.entries.elementAt(index).key,
          m.entries.elementAt(index).value,
        );
      });


    } else if (data.value is! Map){
      //print("isNotMap");
      //print(data.value.runtimeType);
      return [];
    } else {
      //print("else");
      return [];
    }
  }

  /// returns total depth of given [data]
  int totalDepth(dynamic data) {
    //print("TotalD: $data");

    int c = 0;
    if (data is Map) {
      //print("map");
      for (final i in data.entries) {
        c += totalDepth(i);
      }
      return c;

    } else if (data is MapEntry<String, dynamic> && (data.value is String || data.value is bool || data.value is int || data.value is double)) {
      //print("lastEntry");
      return 1;

    } else if (data is MapEntry) {
      //print("mapEntry");
      return totalDepth(data.value) + 1;

    } else if (data is String || data is bool ||data is int || data is double) {
      return 0;

    } else if (data is List) {
      return data.length;

    } else {
      //print("primitive");
      return 1;
    }
  }

  /// returns the first key of a given [entry]
  String getChild(MapEntry<dynamic, dynamic> entry) {
    return entry.key.toString();
  }

}