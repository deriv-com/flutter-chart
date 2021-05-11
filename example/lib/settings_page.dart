import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';

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
          .toString() ??
      '--';
}

/// This page is used to apply necessary QA configurations for the WS connection.
/// Two fields can be set in this page 'endpoint' and 'app_id'
/// The applied values stored for future usage
class SettingsPage extends StatefulWidget {
  /// Login Setting Page Constructor
  const SettingsPage({
    @required this.defaultAppID,
    @required this.defaultEndpoint,
    Key key,
  }) : super(key: key);

  /// Default app ID.
  final String defaultAppID;

  /// Default endpoint.
  final String defaultEndpoint;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop<bool>(true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Setting')),
        body: PreferencePage(
          <Widget>[
            PreferenceTitle('Endpoint'),
            TextFieldPreference(
              'Endpoint',
              'endpoint',
              defaultVal: widget.defaultEndpoint,
              validator: (String value) =>
                  hasOnlySmallLettersAndNumberInput(value)
                      ? null
                      : 'Invalid endpoint',
            ),
            TextFieldPreference(
              'AppID',
              'appID',
              defaultVal: widget.defaultAppID,
              validator: (String value) =>
                  hasOnlyNumberInput(value) ? null : 'Invalid AppID',
            ),
          ],
        ),
      ));
}
