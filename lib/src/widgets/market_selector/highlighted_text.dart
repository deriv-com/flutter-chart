import 'package:flutter/material.dart';

class HighLightedText extends StatelessWidget {
  const HighLightedText(
    this.text, {
    Key key,
    this.highlightText = '',
    this.style = const TextStyle(fontSize: 14, color: Color(0xFFC2C2C2)),
    this.highlightStyle = const TextStyle(
      fontSize: 14,
      color: Color(0xFFC2C2C2),
      fontWeight: FontWeight.bold,
    ),
  }) : super(key: key);

  final String text;
  final String highlightText;
  final TextStyle style;
  final TextStyle highlightStyle;

  @override
  Widget build(BuildContext context) {
    final highlightIndex =
        text.toLowerCase().indexOf(highlightText.toLowerCase());
    if (highlightText.isEmpty || highlightIndex == -1) {
      return Text(text, style: style);
    }

    return RichText(
      text: TextSpan(
        text: text.substring(0, highlightIndex),
        style: style,
        children: <TextSpan>[
          TextSpan(
            text: text.substring(
              highlightIndex,
              highlightIndex + highlightText.length,
            ),
            style: highlightStyle,
          ),
          TextSpan(text: text.substring(highlightIndex + highlightText.length)),
        ],
      ),
    );
  }
}
