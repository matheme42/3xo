import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebsocketManager {
  final Map<String, WebSocketChannel> _clients = {};

  void addwsRoute(Router router) {
    router.get('/ws', handleWebSocketRequest);
  }

  FutureOr<Response> handleWebSocketRequest(Request request) {
    return webSocketHandler((webSocket) {
      IOWebSocketChannel channel = webSocket as IOWebSocketChannel;
      // Utiliser le hashCode du channel comme identifiant unique
      int clientId = channel.hashCode;
      print('Client connecté (${channel.hashCode})');
      addClient(clientId.toString(), channel);
      broadcastMessage(
        "Un nouveau client s'est connecté. Nombre de clients: ${_clients.length}",
      );
      channel.stream.listen(
        (msg) => onReceiveMessage(clientId.toString(), msg),
        onDone: () => removeClient(clientId.toString()),
        onError: (error) => removeClient(clientId.toString()),
      );
    })(request);
  }

  void onReceiveMessage(String clientId, String message) {
    final channel = _clients[clientId];
    if (channel == null) return;
    channel.sink.add("hello $message nb: clients: ${_clients.length}");
  }

  void addClient(String clientId, WebSocketChannel channel) {
    _clients[clientId] = channel;
  }

  void removeClient(String clientId) {
    _clients.remove(clientId);
  }

  void broadcastMessage(String message) {
    for (var channel in _clients.values) {
      channel.sink.add(message);
    }
  }
}
