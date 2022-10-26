import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:audio_visualizer/mic_listener.dart';
import 'package:audio_visualizer/wave_painter.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

List<int> _calculateWaveSamples(Uint8List samples) {
  bool first = true;
  List<int> visibleSamples = [];
  int tmp = 0;
  for (int sample in samples) {
    if (sample > 128) sample -= 255;
    if (first) {
      tmp = sample * 128;
    } else {
      tmp += sample;
      visibleSamples.add(tmp);

      tmp = 0;
    }
    first = !first;
  }

  return visibleSamples;
}

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
        _soundSubscription = a.listen(_micListener);
      }
    }
    setState(() {});
  }

  void _micListener(Uint8List micUint8List) async {
    final computed = _calculateWaveSamples(micUint8List);
    _streamController.add(computed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 9,
                child: StreamBuilder<List<int>>(
                  stream: _streamController.stream,
                  builder: (c, snapshot) {
                    if (snapshot.data == null) {
                      return const Center(
                        child: Text("Waiting"),
                      );
                    }

                    return Center(
                      child: CustomPaint(
                        painter: WavePainter(
                          context,
                          samples: snapshot.data ?? [],
                        ),
                        child: Container(
                          height: 800,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      micListener.isRecording ? Colors.red : Colors.blue,
                    ),
                  ),
                  onPressed: _handleRecording,
                  child: Text(
                    micListener.isRecording ? "Parar" : "Gravar",
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
