import 'package:flutter/material.dart';

/// Default auth endpoint.
const String defaultAuthEndpoint = 'oauth.deriv.com';

/// Default ws endpoint.
const String defaultEndpoint = 'blue.binaryws.com';

/// Default app id.
const String defaultAppId = '23789';

/// Parses an [endpoint] argument and generates a url that points to QA servers
/// if [endpoint] starts with `qa` or a url that points to production servers if
/// [endpoint] contains `derivws` or `binaryws` and [isAuthUrl] is `true`.
///
/// [endpoint] argument is required.
/// [isAuthUrl] is optional and has a default value of `false`.
String generateEndpointUrl({
  required String endpoint,
  bool isAuthUrl = false,
}) {
  final RegExp qaRegExp = RegExp('^(qa[0-9]{2})\$', caseSensitive: false);
  final RegExp derivRegExp =
      RegExp('(binary|deriv)ws\.(com|app)\$', caseSensitive: false);

  if (isAuthUrl && derivRegExp.hasMatch(endpoint)) {
    // Since Deriv app is under Deriv.app, the oauth url should be always `oauth.deriv.com`.
    return defaultAuthEndpoint;
  } else if (qaRegExp.hasMatch(endpoint)) {
    return '$endpoint.deriv.dev';
  }

  return endpoint;
}
