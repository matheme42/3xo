import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_hotreload/shelf_hotreload.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'websocket.dart';

void main() async {
  withHotreload(() => createServer());
}

Future<HttpServer> createServer() {
  final router = Router();
  final websocketManager = WebsocketManager();
  websocketManager.addwsRoute(router);

  final handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler(router.call);

  print('Serveur Dev en ligne avec Hot Reload !');

  return io.serve(handler, '0.0.0.0', 8080);
}
