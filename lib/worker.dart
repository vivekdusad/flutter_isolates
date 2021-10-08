import 'dart:async';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:isolates_learning/post.dart';

String url = "https://jsonplaceholder.typicode.com/posts";

class Worker {
  late Isolate _isolate;
  late SendPort _sendPort;

  Completer<List<Post>>? completer;

  final _isolateReady = Completer<void>();

  Future<void> get isReady => _isolateReady.future;

  void dispose() {
    _isolate.kill();
  }

  Worker() {
    init();
  }

  Future<List<Post>> fetchPost() async {
    _sendPort.send(url);
    completer = Completer<List<Post>>();
    return completer!.future;
  }

  void init() async {
    ReceivePort receivePort = ReceivePort();
    ReceivePort errorPort = ReceivePort();
    errorPort.listen(print);

    receivePort.listen(_handleMessage);

    _isolate = await Isolate.spawn(isolateEntry, receivePort.sendPort);
    
  }

  void _handleMessage(dynamic message) {
    if (message is SendPort) {
      _sendPort = message;
      _isolateReady.complete();
      return;
    }
    if (message is List<Post>) {
      completer!.complete(message);
      completer = null;
      return;
    }
    throw UnimplementedError("Undefined message");
  }

  static isolateEntry(dynamic message) {
    late SendPort sendPort;
    final recivePort = ReceivePort();
    recivePort.listen((message) async {
      assert(message is String);
      final url = message;
      final dio = Dio();
      try {
        sendPort.send(await _fetchPosts(dio: dio, url: url));
      } finally {
        dio.close();
      }
    });
    if (message is SendPort) {
      sendPort = message;
      sendPort.send(recivePort.sendPort);
      return;
    }
  }

  static Future<List<Post>> _fetchPosts(
      {required Dio dio, required String url}) async {
    try {
      Response response = await dio.get(url);
      final list = response.data as List;
      return list.map((e) => Post.fromMap(e)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
