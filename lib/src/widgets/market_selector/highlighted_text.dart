// @dart=2.9

import 'package:flutter/material.dart';

/// A widget to show a highlighted substring inside a text.
///
/// This widget only highlights the first occurrence of the highlighted substring,
/// Can be improved to show all the substring if there are more than one occurrence.
class HighLightedText extends StatelessWidget {
  ///Initializes a widget to show a highlighted substring inside a text.
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

  /// The text which we want to highlight a part of.
  final String text;

  /// The part of the [text] which we want to highlight.
  final String highlightText;

  /// The text style of the non highlighted text.
  final TextStyle style;

  /// The text style of the  highlighted text.
  final TextStyle highlightStyle;

  @override
  Widget build(BuildContext context) {
    final int highlightIndex =
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
