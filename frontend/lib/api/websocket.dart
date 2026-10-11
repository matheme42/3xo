import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../context/constant.dart';

class WebsocketService {
  WebSocketChannel? _channel;
  final Map<String, List<Function(String)>> _roomMessageHandlers = {};

  Future<void> connect() async {
    _channel = WebSocketChannel.connect(Uri.parse(Constants.websocketUrl));

    try {
      // Attendez que la connexion soit établie
      await _channel!.ready;
      print('WebSocket connecté à ${Constants.websocketUrl}');
      // Pour écouter les messages
      _channel!.stream.listen(onMessageReceived);
      // Pour envoyer un message
      _channel!.sink.add('Hello Server!');
    } catch (e) {
      print('Erreur lors de la connexion au WebSocket: $e');
    }
  }

  void sendMessage(String messageType, String message) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({'type': messageType, 'data': message}));
    } else {
      print('WebSocket n\'est pas connecté.');
    }
  }

  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
    }
  }

  void registerMessageHandler(String messageType, Function(String) handler) {
    if (!_roomMessageHandlers.containsKey(messageType)) {
      _roomMessageHandlers[messageType] = [];
    }
    _roomMessageHandlers[messageType]!.add(handler);
  }

  void unregisterMessageHandler(String messageType, Function(String) handler) {
    if (_roomMessageHandlers.containsKey(messageType)) {
      _roomMessageHandlers[messageType]!.remove(handler);
      if (_roomMessageHandlers[messageType]!.isEmpty) {
        _roomMessageHandlers.remove(messageType);
      }
    }
  }

  // a message is always constructed as a JSON object with a "type" field and a "data" field
  void onMessageReceived(dynamic message) {
    print('Message reçu: $message');
    try {
      final Map<String, dynamic> messageJson = jsonDecode(message);
      final messageType = messageJson['type'];
      final messageContent = messageJson['data'];
      if (_roomMessageHandlers.containsKey(messageType)) {
        for (var handler in _roomMessageHandlers[messageType]!) {
          handler(messageContent);
        }
      }
    } catch (e) {
      print('Message non JSON reçu: $message');
      return;
    }
  }
}
