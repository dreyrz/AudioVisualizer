import 'dart:async';

import 'dart:typed_data';

import 'package:audio_visualizer/mic_listener.dart';

import 'package:flutter/material.dart';

import 'gradient_sound.dart';

class AudioVisualizer extends StatefulWidget {
  const AudioVisualizer({Key? key}) : super(key: key);

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with SingleTickerProviderStateMixin {
  late IMicListener micListener;
  StreamSubscription<Uint8List>? _soundSubscription;
  final _streamController = StreamController<List<int>>.broadcast();

  @override
  void initState() {
    micListener = MicListener();
    micListener.init();

    super.initState();
  }

  Future<void> _handleRecording() async {
    if (micListener.isRecording) {
      micListener.stop();
      _soundSubscription?.cancel();
    } else {
      final a = await micListener.record();
      if (a != null) {
        _soundSubscription = a.listen(_listener);
      }
    }
    setState(() {});
  }

  List<int> _calculateWaveSamples(Uint8List samples) {
    final x = List.filled(samples.length ~/ 2, 0);
    for (int i = 0; i < x.length; i++) {
      int msb = samples[i * 2 + 1];
      int lsb = samples[i * 2];
      if (msb > 128) msb -= 255;
      if (lsb > 128) lsb -= 255;
      x[i] = (lsb + msb * 128).toInt();
    }

    return x;
  }

  void _listener(Uint8List micUint8List) async {
    final computed = _calculateWaveSamples(micUint8List);
    _streamController.add(computed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _handleRecording,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<List<int>>(
              stream: _streamController.stream,
              builder: (c, snapshot) {
                return Center(
                  child: GradientSound(
                    samples: snapshot.data ?? [],
                    isRecording: micListener.isRecording,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
