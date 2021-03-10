// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static m0(text) => "No results for \"${text}\"";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "informNoResult" : m0,
    "labelBandsCount" : MessageLookupByLibrary.simpleMessage("Bands Count"),
    "labelBaseLinePeriod" : MessageLookupByLibrary.simpleMessage("Base Line Period"),
    "labelChannelFill" : MessageLookupByLibrary.simpleMessage("Channel Fill"),
    "labelConversionLinePeriod" : MessageLookupByLibrary.simpleMessage("Conversion Line Period"),
    "labelField" : MessageLookupByLibrary.simpleMessage("Field"),
    "labelHighPeriod" : MessageLookupByLibrary.simpleMessage("High Period"),
    "labelLaggingSpanOffset" : MessageLookupByLibrary.simpleMessage("Lagging Span Offset"),
    "labelLowPeriod" : MessageLookupByLibrary.simpleMessage("Low Period"),
    "labelOffset" : MessageLookupByLibrary.simpleMessage("Offset"),
    "labelPeriod" : MessageLookupByLibrary.simpleMessage("Period"),
    "labelSearchAssets" : MessageLookupByLibrary.simpleMessage("Search assets"),
    "labelShift" : MessageLookupByLibrary.simpleMessage("Shift"),
    "labelShiftType" : MessageLookupByLibrary.simpleMessage("Shift Type"),
    "labelSpanBPeriod" : MessageLookupByLibrary.simpleMessage("Leading Span B Period"),
    "labelStandardDeviation" : MessageLookupByLibrary.simpleMessage("Standard Deviation"),
    "labelType" : MessageLookupByLibrary.simpleMessage("Type"),
    "warnCheckAssetSearchingText" : MessageLookupByLibrary.simpleMessage("Try checking your spelling or use a different term")
  };
}
