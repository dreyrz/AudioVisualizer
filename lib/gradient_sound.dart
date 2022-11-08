import 'package:flutter/material.dart';

class GradientSound extends StatefulWidget {
  final List<int> samples;
  final bool isRecording;
  const GradientSound({
    Key? key,
    required this.samples,
    required this.isRecording,
  }) : super(key: key);

  @override
  State<GradientSound> createState() => _GradientSoundState();
}
// values
//  minor -16000 - red
//  bigger 16000 - blue

class _GradientSoundState extends State<GradientSound> {
  int get minorValue => widget.samples.isEmpty || widget.samples.first == 0
      ? 1
      : widget.samples.first;
  int get biggerValue => widget.samples.isEmpty || widget.samples.last == 0
      ? 1
      : widget.samples.last;

  static const highFreqColors = [
    Colors.limeAccent,
    Colors.yellowAccent,
    Colors.amberAccent,
    Colors.orangeAccent,
    Colors.deepOrangeAccent,
    Colors.redAccent,
    Colors.pinkAccent,
    Colors.purpleAccent,
  ];
  static const lowFreqColors = [
    Colors.lightGreenAccent,
    Colors.greenAccent,
    Colors.tealAccent,
    Colors.cyanAccent,
    Colors.blueAccent,
    Colors.lightBlueAccent,
    Colors.indigoAccent,
    Colors.deepPurpleAccent,
  ];

  Color beginColor = highFreqColors.first;
  Color endColor = lowFreqColors.first;

  void _handleBeginColor() {
    final period = 16000 / highFreqColors.length;
    int index = minorValue.abs() ~/ period;

    if (index > highFreqColors.length - 1) {
      index = highFreqColors.length - 1;
    }
    setState(() {
      beginColor = highFreqColors[index];
    });
  }

  void _handleEndColor() {
    final period = 16000 / lowFreqColors.length;
    int index = biggerValue ~/ period;
    if (index > lowFreqColors.length - 1) {
      index = lowFreqColors.length - 1;
    }

    setState(() {
      // print("end index $index");
      endColor = lowFreqColors[index];
    });
  }

  @override
  void didUpdateWidget(a) {
    widget.samples.sort();
    _handleBeginColor();
    _handleEndColor();
    super.didUpdateWidget(a);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: widget.isRecording ? MediaQuery.of(context).size.height : 100,
      width: widget.isRecording ? MediaQuery.of(context).size.width : 100,
      duration: const Duration(seconds: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.isRecording ? 0 : 100),
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [beginColor, endColor],
        ),
      ),
    );
  }
}
