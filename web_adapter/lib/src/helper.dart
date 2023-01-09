import 'package:flutter/material.dart';

/// Gets [Color] instance from hex code
Color getColorFromHex(String hexColor) =>
    Color(int.parse(hexColor.replaceAll('#', '0xff')));
