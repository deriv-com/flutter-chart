import 'dart:async';

import 'package:build/build.dart';
import 'package:recase/recase.dart';
import 'package:deriv_chart/extensions/string_extension.dart';



/// Generate arb file from text file
class ArbBuilder implements Builder {
  static const String _arbFilePath = '/../../lib/l10n/intl_en.arb';
  static const String _regexFormatPattern = "(.*\".*\"): (')(.*)('),?";
  static const String _regexPlaceHolderPattern =
      r"(\$)({?)(_?)(\w+)(((\.\w+)*})?)(((\.\w+)*\(.*})?)((\.\w+)*\s?(==)?\s?(\w+)?(\.\w+)*\s?\?\s?\'?\w+\'?\s?\:\s?\'?\w+\'?})*";
  static const String _regexLastQuestionMarkPattern = r"\?\'$";
  static const String _regexCapitalPattern = r"'[A-Z]+(\s[A-Z]+)*'";
  static const String _regexNumberPattern = r"[0-9]";
  static const String _regexSpecialCharacterPattern = r"['$(){}\[\]:,/\\!?@_=]";
  static const String _regexFirstSpacePattern = r"^\s";
  static const String _regexSpacePattern = r"\s+";
  static const String _regexLastUnderScorePattern = r"_$";
  static const String _regexTernaryQuestionMarkPattern = r" \? ";
  static const String _regexTernaryColonPattern = r" : ";
  static const String _regexUnderScoreSequencePattern = r"_+";
  static const String _regexFirstUnderScorePattern = r"^_";

  @override
  Future build(BuildStep buildStep) async {
    var inputId = buildStep.inputId;
    var contents = await buildStep.readAsString(inputId);
    var path = inputId.changeExtension(_arbFilePath);
    var lines = contents.split('\n');
    var bufferContent = StringBuffer();

    lines.forEach((line) {
      if (line != null && line != "") {
        var key = _generateKey(line);
        bufferContent.write("  \"$key\"" + ": $line,\n");
        bufferContent.write("  \"@$key\"" + ": {\n");
        bufferContent.write("    \"description\"" + ": \"\"\n  },\n");
      }
    });

    var formattedContent = bufferContent
        .toString()
        .replaceAllMapped(RegExp(_regexFormatPattern), (match) {
      return '${match.group(1)}: "${match.group(3).replaceAll('\\\'', '\'').replaceAll('"', r'\"')}",';
    }).replaceAllMapped(RegExp(_regexPlaceHolderPattern), (match) {
      String extra = '';
      if (match.group(5) != null && match.group(5) != '') {
        extra = match.group(5)?.replaceAll('.', '');
        extra = ReCase(extra).pascalCase;
      }
      return '{${match.group(4)}${extra == '' ? '}' : '$extra'}';
    }).replaceLast(
      toReplace: ',',
      replacement: '',
    );

    await buildStep.writeAsString(
        path, "{\n  \"@@locale\": \"en\",\n$formattedContent}\n");
  }

  @override
  final buildExtensions = const {
    '.txt': [_arbFilePath]
  };

  String _generateKey(String text) {
    if (RegExp(_regexLastQuestionMarkPattern).hasMatch(text)) {
      text = text + ' Question';
    }

    if (RegExp(_regexCapitalPattern).hasMatch(text)) {
      text = text + ' Capital';
    }

    text = text
        .replaceAllMapped(
            RegExp(_regexTernaryQuestionMarkPattern), (match) => ' ')
        .replaceAllMapped(RegExp(_regexTernaryColonPattern), (match) => ' ')
        .replaceAllMapped("...", (match) => '')
        .replaceAllMapped(".", (match) => ' ')
        .replaceAllMapped("-", (match) => ' ')
        .replaceAllMapped("/", (match) => ' ')
        .replaceAllMapped("\"", (match) => '')
        .replaceAllMapped(RegExp(_regexSpecialCharacterPattern), (match) => '_')
        .toLowerCase()
        .replaceAllMapped(RegExp(_regexNumberPattern), (match) => '_')
        .replaceAllMapped(RegExp(_regexFirstSpacePattern), (match) => '')
        .replaceAllMapped(RegExp(_regexSpacePattern), (match) => '_')
        .replaceAllMapped(
        RegExp(_regexUnderScoreSequencePattern), (match) => '_')
        .replaceAllMapped(RegExp(_regexFirstUnderScorePattern), (match) => '');

    var hash = text.hashCode.toString();
    var length = text.length <= 20 ? text.length : 20;

    return text.substring(0, length).replaceAllMapped(
            RegExp(_regexLastUnderScorePattern), (match) => '') +
        '_' +
        hash;
  }
}