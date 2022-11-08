import 'dart:typed_data';

import 'package:mic_stream/mic_stream.dart';

abstract class IMicListener {
  Future<void> init();
  Future<Stream<Uint8List>?> record();
  void stop();

  bool get isRecording;
}

class MicListener implements IMicListener {
  static const audioFormat = AudioFormat.ENCODING_PCM_16BIT;

  bool _isRecording = false;

  @override
  bool get isRecording => _isRecording;

  @override
  Future<void> init() async {
    MicStream.shouldRequestPermission(true);
  }

  @override
  Future<Stream<Uint8List>?> record() async {
    final stream = await MicStream.microphone(
      audioSource: AudioSource.DEFAULT,
      sampleRate: 16000,
      channelConfig: ChannelConfig.CHANNEL_IN_MONO,
      audioFormat: AudioFormat.ENCODING_PCM_16BIT,
    );
    _isRecording = true;

    return stream;
  }

  @override
  void stop() {
    _isRecording = false;
  }
}
