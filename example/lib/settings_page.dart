import 'package:flutter/material.dart';
import 'package:pref/pref.dart';

/// Check if [str] input contains only a-z letters and 0-9 numbers
bool hasOnlySmallLettersAndNumberInput(String str) =>
    RegExp('^[a-z0-9.]+\$').hasMatch(str);

/// Check if [str] input contains only 0-9 numbers
bool hasOnlyNumberInput(String str) => RegExp('^[0-9]+\$').hasMatch(str);

/// Gets double value from the provided [str] and returns it as a string.
String getNumFromString(String str) {
  final RegExp doubleRegex =
      RegExp(r'-?(?:\d*\.)?\d+(.*?:[eE][+-]?\d+)?', multiLine: true);

  return doubleRegex
      .allMatches(str)
      .map<dynamic>((dynamic m) => m.group(0))
      .toString();
}

/// This page is used to apply necessary QA configurations for the WS connection
/// Two fields can be set in this page 'endpoint' and 'app_id'
/// The applied values stored for future usage
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _hasChanged = false;

  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop<bool>(_hasChanged);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Setting')),
        body: PrefPage(
          children: <Widget>[
            const PrefTitle(title: Text('Endpoint')),
            PrefText(
              label: 'Endpoint',
              pref: 'endpoint',
              validator: (String? value) {
                _hasChanged = true;
                return value != null && hasOnlySmallLettersAndNumberInput(value)
                    ? null
                    : 'Invalid endpoint';
              },
            ),
            PrefText(
                label: 'AppID',
                pref: 'appID',
                validator: (String? value) {
                  _hasChanged = true;
                  return value != null && hasOnlyNumberInput(value)
                      ? null
                      : 'Invalid AppID';
                }),
          ],
        ),
      ));
}
