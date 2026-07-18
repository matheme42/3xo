import 'package:web_socket_channel/web_socket_channel.dart';

class WebsocketService {
  static const host = 'localhost';
  WebSocketChannel? _channel;

  Future<void> connect() async {
    _channel = WebSocketChannel.connect(Uri.parse('ws://$host/ws'));

    try {
      // Attendez que la connexion soit établie
      await _channel!.ready;
      print('WebSocket connecté à ws://$host/ws');
      // Pour écouter les messages
      _channel!.stream.listen(onMessageReceived);
      // Pour envoyer un message
      _channel!.sink.add('Hello Server!');
    } catch (e) {
      print('Erreur lors de la connexion au WebSocket: $e');
    }
  }

  void sendMessage(String message) {
    if (_channel != null) {
      _channel!.sink.add(message);
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

  void onMessageReceived(dynamic message) {
    print('Message reçu: $message');
  }
}
