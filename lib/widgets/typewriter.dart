import 'dart:async';

import 'package:flutter/material.dart';

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? align;
  final Duration duration;

  const TypewriterText(this.text,
      {super.key,
      this.style,
      this.align,
      this.duration = const Duration(milliseconds: 30)});

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = '';
  Timer? _timer;
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.duration, (timer) {
      if (_charIndex < widget.text.length) {
        setState(() {
          _displayedText += widget.text[_charIndex];
          _charIndex++;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.style,
      textAlign: widget.align,
    );
  }
}
