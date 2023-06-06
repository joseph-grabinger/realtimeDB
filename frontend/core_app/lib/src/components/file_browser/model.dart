
import 'package:get/get.dart';

// enum Type {
//   image,
//   video,
//   pdf,
//   unknown,
// }

// class FileM implements Comparable {
//   String name;
//   DateTime modified;

//   FileM({required this.name, required this.modified});

//   factory FileM.fromJson(Map<String, dynamic> json) => FileM(
//     name: json['Name'],
//     modified: DateTime.parse(json['ModTime']),
//   );

//   @override
//   int compareTo(other) {
//     return name.toLowerCase().compareTo(other.name.toLowerCase());
//   }

//   Type get type {
//     String fileType = name.split('.').last.toLowerCase();
//     switch (fileType) {
//       case 'pdf': {
//         return Type.pdf;
//       }
//       case 'mp4': {
//         return Type.video;
//       }
//       default: {
//         if (fileType == 'jpg' || fileType == 'jpeg'
//             || fileType == 'png' || fileType == 'tiff') {
//           return Type.image;
//         } else {
//           return Type.unknown;
//         }
//       }
//     }
//   }

//   String get extension => name.split('.').last;

// }

// class FolderM implements Comparable {
//   String name;
//   List<FileM> files;
//   List<FolderM> folders;
//   DateTime modified;

//   FolderM({required this.name, required this.files,
//     required this.folders, required this.modified});

//   factory FolderM.fromJson(Map<String, dynamic> json) {
//     final folders = Map<String,dynamic>.from(json['Folders'] ?? {});

//     final listFolders = List<FolderM>.generate(
//         folders.length,
//           (index) => FolderM.fromJson(folders.values.elementAt(index) ?? {}),
//     );

//     return FolderM(
//       name: json['Name'] ?? '',
//       files: List<FileM>.from((json['Files'] ?? []).map((model)=> FileM.fromJson(model))),
//       folders: listFolders,
//       modified: DateTime.parse(json['ModTime'] ?? "2000-01-01"),
//     );
//   }

//   @override
//   int compareTo(other) {
//     return name.toLowerCase().compareTo(other.name.toLowerCase());
//   }

// }

class NavStack<E> {
  RxList list = <E>[].obs;

  void push(E value) => list.add(value);

  E pop() => list.removeLast();

  E get peek => list.last;

  bool get isEmpty => list.isEmpty;
  bool get isNotEmpty => list.isNotEmpty;

  @override
  String toString() => list.toString();
}
