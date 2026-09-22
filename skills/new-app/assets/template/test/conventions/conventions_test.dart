import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the conventions `flutter analyze` cannot see.
///
/// Two reasons this exists as a test rather than prose. Some rules no linter
/// expresses — a credential reaching the plaintext store, an enum field with no
/// wire fallback. Others are bloc_lint's, and **an app without bloc_lint has
/// nothing enforcing them at all**; those are marked below, so an app that does
/// run the CLI can delete them.
///
/// Every assertion is at zero when this file ships. A failure is drift the
/// failing change introduced, not a backlog to work off.
void main() {
  final dartFiles = _dartFilesUnder(['lib']);
  final blocsAndCubits = dartFiles
      .where((f) => f.path.contains('/bloc/') || f.path.contains('/cubit/'))
      .where((f) => f.path.endsWith('_bloc.dart') || f.path.endsWith('_cubit.dart'))
      .toList();
  final models = dartFiles.where((f) => f.path.contains('/data/models/')).toList();

  test('the scan found lib, so a passing run means something', () {
    expect(dartFiles.length, greaterThan(20));
  });

  // bloc_lint: avoid_flutter_imports
  test('no Flutter import in a bloc or cubit', () {
    expect(
      _offenders(blocsAndCubits, RegExp("import 'package:flutter/(?!foundation)")),
      isEmpty,
      reason: 'use framework-agnostic types and convert at the widget boundary',
    );
  });

  // bloc_lint: avoid_public_fields
  test('a bloc or cubit keeps no mutable public field beside its state', () {
    // A public field the view reads in build has no rebuild driver of its own,
    // so it renders only while every mutation happens to sit between two emits.
    final declaration = RegExp(r'^  [A-Z]\w*[\w<>,?\s]*\s([a-z]\w*)\s*=');
    final offenders = <String>[];
    for (final file in blocsAndCubits) {
      final lines = _stripComments(file.readAsStringSync()).split('\n');
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.contains(' get ') || line.contains('final ') || line.contains('static ')) {
          continue;
        }
        if (!declaration.hasMatch(line)) continue;
        if (i > 0 && lines[i - 1].contains('@visibleForTesting')) continue;
        offenders.add('${file.path}: ${line.trim()}');
      }
    }

    expect(offenders, isEmpty, reason: 'carry the value on the state arms instead');
  });

  test('a state union is branched with its callbacks, not with is', () {
    expect(
      _offenders(blocsAndCubits, RegExp(r'\bstate is!?\s'), stripComments: true),
      isEmpty,
      reason: 'use when / maybeWhen / whenOrNull / map',
    );
  });

  test('every enum-typed model field has an unknownEnumValue fallback', () {
    // One unrecognised wire value otherwise throws inside fromJson, which the
    // repository's runner reports as a generic failure.
    final enumNames = <String>{};
    for (final file in models) {
      for (final match in RegExp(r'^enum (\w+)', multiLine: true).allMatches(file.readAsStringSync())) {
        enumNames.add(match.group(1)!);
      }
    }

    final offenders = <String>[];
    for (final file in models) {
      final source = file.readAsStringSync();
      // A model with no fromJson never decodes a wire value.
      if (!source.contains('fromJson')) continue;

      for (final declaration in source.split(RegExp(r',\s*\n'))) {
        final field = RegExp(r'\b(\w+)\??\s+\w+\s*$').firstMatch(declaration.trimRight());
        if (field == null || !enumNames.contains(field.group(1))) continue;
        if (!declaration.contains('unknownEnumValue')) {
          offenders.add('${file.path}: ${field.group(0)!.trim()}');
        }
      }
    }

    expect(offenders, isEmpty, reason: 'add @JsonKey(unknownEnumValue: X.unknown) so an unseen value degrades');
  });

  test('nothing credential-shaped is written to the plaintext store', () {
    // A heading grouping keys as non-sensitive is a claim, not a guarantee.
    final banned = RegExp(r'\b(number|pan|cvv|cvc|pin|password|accessToken|refreshToken)\b');
    final offenders = <String>[];
    for (final file in dartFiles) {
      final source = file.readAsStringSync();
      if (!source.contains('LocalDataStorage')) continue;

      for (final match in RegExp(r'\.set(String|StringList|Int|Bool)\((.{0,120})').allMatches(source)) {
        if (banned.hasMatch(match.group(2)!)) {
          offenders.add('${file.path}: ${match.group(2)}');
        }
      }
    }

    expect(offenders, isEmpty, reason: 'a credential goes to SecureLocalDataStorage');
  });

  test('no deprecated APIs', () {
    expect(_offenders(dartFiles, RegExp(r'\.withOpacity\(')), isEmpty, reason: 'use withValues(alpha:)');
    expect(_offenders(dartFiles, RegExp(r'\bWillPopScope\b')), isEmpty, reason: 'use PopScope');
  });

  // Add this app's own greppable conventions here rather than in prose. A rule
  // held by hand is held until the next hurry.
}

List<File> _dartFilesUnder(List<String> roots) => roots
    .map(Directory.new)
    .where((dir) => dir.existsSync())
    .expand((dir) => dir.listSync(recursive: true))
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .where((f) => !f.path.endsWith('.g.dart'))
    .where((f) => !f.path.endsWith('.freezed.dart'))
    .where((f) => !f.path.endsWith('.config.dart'))
    .where((f) => !f.path.endsWith('.gen.dart'))
    .toList();

List<String> _offenders(List<File> files, RegExp pattern, {bool stripComments = false}) => files
    .where((f) => pattern.hasMatch(stripComments ? _stripComments(f.readAsStringSync()) : f.readAsStringSync()))
    .map((f) => f.path)
    .toList();

/// Comments name the traps they warn about, so a rule that greps for a trap
/// has to read code only.
String _stripComments(String source) =>
    source.replaceAll(RegExp(r'^\s*//.*$', multiLine: true), '').replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');
