import 'dart:js_interop';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

class AudioSamples {
  final int sampleRate;
  final int channels;
  final List<double> samples;

  AudioSamples({
    required this.sampleRate,
    required this.channels,
    required this.samples,
  });
}

enum AudioFormat { wav, mp3, unknown }

class AudioReader {
  static AudioFormat detectAudioFormat(Uint8List bytes) {
    if (bytes.length < 12) return AudioFormat.unknown;

    // WAV : RIFF....WAVE
    final riff = String.fromCharCodes(bytes.sublist(0, 4));
    final wave = String.fromCharCodes(bytes.sublist(8, 12));

    if (riff == 'RIFF' && wave == 'WAVE') {
      return AudioFormat.wav;
    }

    // MP3 : ID3 tag
    final id3 = String.fromCharCodes(bytes.sublist(0, 3));

    if (id3 == 'ID3') {
      return AudioFormat.mp3;
    }

    // MP3 frame header (FF FB / FF F3 / FF F2)
    if (bytes[0] == 0xFF && (bytes[1] & 0xE0) == 0xE0) {
      return AudioFormat.mp3;
    }
    return AudioFormat.unknown;
  }

  static Future<AudioSamples> fromUrl(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception("Impossible de charger le fichier WAV");
    }

    final bytes = response.bodyBytes;

    final format = detectAudioFormat(bytes);

    if (format == AudioFormat.wav) {
      return AudioReader.parse(bytes);
    }

    if (format == AudioFormat.mp3) {
      return AudioReader.parseMp3(bytes);
    }

    throw Exception("Format audio non supporté");
  }

  static Future<AudioSamples> parseMp3(Uint8List bytes) async {
    final audioContext = web.AudioContext();

    final audioBuffer = await audioContext
        .decodeAudioData(bytes.buffer.toJS)
        .toDart;

    final sampleRate = audioBuffer.sampleRate.toInt();
    final channels = audioBuffer.numberOfChannels;
    final length = audioBuffer.length;

    // mix vers mono
    final Float32List mono = Float32List(length);

    for (int c = 0; c < channels; c++) {
      final channel = audioBuffer.getChannelData(c).toDart;

      for (int i = 0; i < length; i++) {
        mono[i] += channel[i] / channels;
      }
    }

    // normalisation 0..1
    final Float32List normalized = Float32List(length);

    for (int i = 0; i < length; i++) {
      normalized[i] = (mono[i] + 1) / 2;
    }

    return AudioSamples(
      sampleRate: sampleRate,
      channels: channels,
      samples: normalized,
    );
  }

  static AudioSamples parse(Uint8List bytes) {
    final data = ByteData.sublistView(bytes);

    final riff = String.fromCharCodes(bytes.sublist(0, 4));
    final wave = String.fromCharCodes(bytes.sublist(8, 12));

    if (riff != 'RIFF' || wave != 'WAVE') {
      throw Exception("Fichier WAV invalide");
    }

    int offset = 12;

    int sampleRate = 0;
    int channels = 0;
    int bitsPerSample = 0;
    int dataOffset = 0;
    int dataSize = 0;

    while (offset < bytes.length) {
      final chunkId = String.fromCharCodes(bytes.sublist(offset, offset + 4));
      final chunkSize = data.getUint32(offset + 4, Endian.little);

      if (chunkId == "fmt ") {
        channels = data.getUint16(offset + 10, Endian.little);
        sampleRate = data.getUint32(offset + 12, Endian.little);
        bitsPerSample = data.getUint16(offset + 22, Endian.little);
      }

      if (chunkId == "data") {
        dataOffset = offset + 8;
        dataSize = chunkSize;
        break;
      }

      offset += 8 + chunkSize;
    }

    if (bitsPerSample != 16) {
      throw Exception("Seuls les WAV 16 bits sont supportés");
    }

    final samples = <double>[];
    final sampleCount = dataSize ~/ 2;

    for (int i = 0; i < sampleCount; i++) {
      final intSample = data.getInt16(dataOffset + i * 2, Endian.little);

      // Normalisation 0 → 1
      final normalized = (intSample + 32768) / 65535.0;

      samples.add(normalized);
    }

    return AudioSamples(
      sampleRate: sampleRate,
      channels: channels,
      samples: samples,
    );
  }
}
