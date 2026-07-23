import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebsocketManager {
  final Map<String, WebSocketChannel> _clients = {};
  final Map<String, String> _clientRooms = {};
  final Set<String> _appleTapNotifiedClients = {};

  static const String _appleTapMessage = 'User tapped on the apple!';

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
        cancelOnError: true,
        onDone: () => removeClient(clientId.toString()),
        onError: (error) => removeClient(clientId.toString()),
      );
    })(request);
  }

  // receive message as Json object with a "type" field and a "data" field
  void onReceiveMessage(String clientId, String message) {
    final channel = _clients[clientId];
    if (channel == null) return;

    try {
      final Map<String, dynamic> messageJson = jsonDecode(message);
      final type = messageJson['type'];
      final data = messageJson['data'];

      if (type is! String || data is! String) {
        print('Message invalide reçu du client $clientId: $message');
        return;
      }

      if (data.startsWith('Entered tableau')) {
        _clientRooms[clientId] = type;
        print('Client $clientId est maintenant dans la salle $type');
      }

      if (data == _appleTapMessage) {
        _sendAppleTapToOneT1Client(senderClientId: clientId);
        return;
      }

      print('Message reçu du client $clientId: type=$type, data=$data');
      sendMessage(clientId, type, data);
    } catch (e) {
      print("message non JSON reçu du client $clientId: $message");
    }
  }

  void addClient(String clientId, WebSocketChannel channel) {
    _clients[clientId] = channel;
  }

  void removeClient(String clientId) {
    _clients.remove(clientId);
    _clientRooms.remove(clientId);
    _appleTapNotifiedClients.remove(clientId);
  }

  String? getClientRoom(String clientId) {
    return _clientRooms[clientId];
  }

  void broadcastMessage(String message) {
    for (var channel in _clients.values) {
      channel.sink.add(message);
    }
  }

  void sendMessage(String clientId, String type, String data) {
    final channel = _clients[clientId];
    if (channel == null) return;
    channel.sink.add(jsonEncode({'type': type, 'data': data}));
  }

  void _sendAppleTapToOneT1Client({required String senderClientId}) {
    for (final entry in _clients.entries) {
      final targetClientId = entry.key;
      if (targetClientId == senderClientId) continue;
      if (_clientRooms[targetClientId] != 'T1') continue;
      if (_appleTapNotifiedClients.contains(targetClientId)) continue;

      sendMessage(targetClientId, 'T1', _appleTapMessage);
      _appleTapNotifiedClients.add(targetClientId);
      print('Message pomme envoyé au client $targetClientId (room T1)');
      return;
    }

    print('Aucun client éligible en T1 pour recevoir le message pomme');
  }
}
