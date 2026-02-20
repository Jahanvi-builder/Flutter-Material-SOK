import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundService {
  static final _player = AudioPlayer();
  static Uint8List? _bytes;

  static Future<void> _load() async {
    final data = await rootBundle.load('sounds/Click 1.mp3');
    _bytes = data.buffer.asUint8List();
  }

  static Future<void> playTap() async {
    try {
      _bytes ??= await _load().then((_) => _bytes!);
      final bytes = _bytes;
      if (bytes == null) return;
      await _player.stop();
      await _player.play(BytesSource(bytes), volume: 0.8);
    } catch (_) {}
  }
}
