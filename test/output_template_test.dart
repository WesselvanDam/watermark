// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:watermarker/utils/output_template.dart';

void main() {
  test('parses and renders a valid template with status unresolved', () {
    const template = '{folder}\\{status}\\{filename}_{number}';
    final analysis = analyzeOutputTemplate(template);

    expect(analysis.isValid, isTrue);

    final rendered = renderOutputTemplate(
      template,
      values: {
        'folder': 'MySubfolderName',
        'filename': 'MyFileName',
        'number': '18',
        'status': '{status}',
      },
    );

    expect(rendered, 'MySubfolderName\\{status}\\MyFileName_18');
  });

  test('accepts the legacy file placeholder as filename', () {
    const template = '{file}_{number}';
    final analysis = analyzeOutputTemplate(template);

    expect(analysis.isValid, isTrue);

    final rendered = renderOutputTemplate(
      template,
      values: {'filename': 'MyFileName', 'number': '18'},
    );

    expect(rendered, 'MyFileName_18');
  });

  test('rejects unknown placeholders', () {
    final analysis = analyzeOutputTemplate('{folder}/{bad}');

    expect(analysis.isValid, isFalse);
    expect(analysis.message, contains('Unknown placeholder'));
  });

  test('rejects malformed braces', () {
    final analysis = analyzeOutputTemplate('{folder/{status}}');

    expect(analysis.isValid, isFalse);
    expect(analysis.message, contains('Malformed braces'));
  });

  test('builds highlighted spans for placeholders', () {
    const template = '{folder}\\{status}\\{filename}_{number}';
    final span = buildOutputTemplateTextSpan(
      template,
      baseStyle: const TextStyle(color: Colors.black),
      placeholderStyles: {
        'folder': const TextStyle(color: Colors.blue),
        'filename': const TextStyle(color: Colors.green),
        'number': const TextStyle(color: Colors.orange),
        'status': const TextStyle(color: Colors.purple),
      },
      values: const {
        'folder': 'MySubfolderName',
        'filename': 'MyFileName',
        'number': '18',
        'status': '{status}',
      },
    );

    final children = span.children!.cast<TextSpan>();
    expect(children.map((child) => child.text).toList(), [
      'MySubfolderName',
      '\\',
      '{status}',
      '\\',
      'MyFileName',
      '_',
      '18',
    ]);
    expect(children[0].style?.color, Colors.blue);
    expect(children[2].style?.color, Colors.purple);
    expect(children[4].style?.color, Colors.green);
    expect(children[6].style?.color, Colors.orange);
  });
}
