import 'package:flutter_test/flutter_test.dart';

import 'package:realtime_api/realtime_api.dart';

void main() {
  test('performs db set', () async {
    final rdb = RealtimeDatabase("todo");

    rdb.reference().child("jaa").child("hello").set("hallo");
  });

  /*test('performs db update', () async {
    final rdb = RealtimeDatabase("todo");

    rdb.reference().child("jaa").child("hello").update(1111);
  });*/

  /*test('performs db remove', () async {
    final rdb = RealtimeDatabase("todo");

    rdb.reference().child("brate").remove();
  });*/

  /*
  test('performs db listen', () async {
    final rdb = RealtimeDatabase("todo");

    rdb.reference().onValue().listen((event) {
      print(event);
    });
  });

*/
/*
  test('performs db get', () async {
    final rdb = RealtimeDatabase("todo");
    
    var result = await rdb.reference().get();
    print(result);
    print(result.runtimeType);
  });*/

}
