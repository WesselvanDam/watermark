import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

const Set<String> _allowedPlaceholders = {
  'folder',
  'file',
  'filename',
  'number',
  'status',
  'original',
};

const Map<String, String> _placeholderAliases = {'file': 'filename'};

class OutputTemplateIssue {
  const OutputTemplateIssue(this.message);

  final String message;
}

class OutputTemplateSegment {
  const OutputTemplateSegment.literal(this.text)
    : placeholder = null,
      isKnownPlaceholder = true;

  const OutputTemplateSegment.placeholder(
    this.text, {
    required this.placeholder,
    required this.isKnownPlaceholder,
  });

  final String text;
  final String? placeholder;
  final bool isKnownPlaceholder;

  bool get isPlaceholder => placeholder != null;
}

class OutputTemplateAnalysis {
  const OutputTemplateAnalysis({required this.segments, required this.issues});

  final List<OutputTemplateSegment> segments;
  final List<OutputTemplateIssue> issues;

  bool get isValid => issues.isEmpty;

  String? get message => issues.isEmpty ? null : issues.first.message;
}

String canonicalizeOutputTemplatePlaceholder(String name) {
  return _placeholderAliases[name] ?? name;
}

OutputTemplateAnalysis analyzeOutputTemplate(String template) {
  final issues = <OutputTemplateIssue>[];
  final segments = <OutputTemplateSegment>[];
  var index = 0;

  while (index < template.length) {
    final openIndex = template.indexOf('{', index);
    if (openIndex == -1) {
      final literal = template.substring(index);
      if (literal.isNotEmpty) {
        _validateLiteral(literal, issues);
        segments.add(OutputTemplateSegment.literal(literal));
      }
      break;
    }

    final literal = template.substring(index, openIndex);
    if (literal.isNotEmpty) {
      _validateLiteral(literal, issues);
      segments.add(OutputTemplateSegment.literal(literal));
    }

    final closeIndex = template.indexOf('}', openIndex + 1);
    if (closeIndex == -1) {
      issues.add(
        const OutputTemplateIssue(
          'Unclosed placeholder. Use {placeholder} with matching braces.',
        ),
      );
      final remainder = template.substring(openIndex);
      if (remainder.isNotEmpty) {
        _validateLiteral(remainder, issues);
        segments.add(OutputTemplateSegment.literal(remainder));
      }
      break;
    }

    final placeholderText = template
        .substring(openIndex + 1, closeIndex)
        .trim();
    if (placeholderText.isEmpty) {
      issues.add(
        const OutputTemplateIssue(
          'Empty placeholder. Use one of {folder}, {filename}, {number}, or {status}.',
        ),
      );
      segments.add(
        OutputTemplateSegment.literal(
          template.substring(openIndex, closeIndex + 1),
        ),
      );
      index = closeIndex + 1;
      continue;
    }

    if (placeholderText.contains('{') || placeholderText.contains('}')) {
      issues.add(
        const OutputTemplateIssue(
          'Malformed braces. Use {placeholder} instead of nested or stray braces.',
        ),
      );
      segments.add(
        OutputTemplateSegment.literal(
          template.substring(openIndex, closeIndex + 1),
        ),
      );
      index = closeIndex + 1;
      continue;
    }

    final canonicalPlaceholder = canonicalizeOutputTemplatePlaceholder(
      placeholderText,
    );
    final isKnownPlaceholder = _allowedPlaceholders.contains(
      canonicalPlaceholder,
    );
    if (!isKnownPlaceholder) {
      issues.add(
        OutputTemplateIssue(
          'Unknown placeholder {$placeholderText}. Use folder, filename, number, status, or original.',
        ),
      );
    }

    segments.add(
      OutputTemplateSegment.placeholder(
        template.substring(openIndex, closeIndex + 1),
        placeholder: canonicalPlaceholder,
        isKnownPlaceholder: isKnownPlaceholder,
      ),
    );
    index = closeIndex + 1;
  }

  return OutputTemplateAnalysis(segments: segments, issues: issues);
}

String renderOutputTemplate(
  String template, {
  required Map<String, String> values,
}) {
  final analysis = analyzeOutputTemplate(template);
  final buffer = StringBuffer();

  for (final segment in analysis.segments) {
    if (!segment.isPlaceholder) {
      buffer.write(segment.text);
      continue;
    }

    final placeholder = segment.placeholder!;
    var value = values[placeholder];
    if (placeholder == 'original' && value != null) {
      // Strip file extension for original placeholder.
      value = p.basenameWithoutExtension(value);
    }

    buffer.write(value ?? segment.text);
  }

  return buffer.toString();
}

TextSpan buildOutputTemplateTextSpan(
  String template, {
  required TextStyle? baseStyle,
  required Map<String, TextStyle> placeholderStyles,
  required Map<String, String> values,
  TextStyle? invalidPlaceholderStyle,
}) {
  final analysis = analyzeOutputTemplate(template);
  final children = <InlineSpan>[];

  for (final segment in analysis.segments) {
    if (!segment.isPlaceholder) {
      children.add(TextSpan(text: segment.text, style: baseStyle));
      continue;
    }
    final placeholder = segment.placeholder!;
    var renderedText = values[placeholder] ?? segment.text;
    if (placeholder == 'original' && renderedText != segment.text) {
      renderedText = p.basenameWithoutExtension(renderedText);
    }
    final style = segment.isKnownPlaceholder
        ? placeholderStyles[placeholder] ?? baseStyle
        : invalidPlaceholderStyle ??
              baseStyle?.copyWith(color: Colors.redAccent);
    children.add(TextSpan(text: renderedText, style: style));
  }

  return TextSpan(style: baseStyle, children: children);
}

void _validateLiteral(String literal, List<OutputTemplateIssue> issues) {
  for (var i = 0; i < literal.length; i++) {
    final character = literal[i];
    if (character == '{' || character == '}') {
      issues.add(
        const OutputTemplateIssue(
          'Malformed braces. Use {placeholder} with single braces for placeholders.',
        ),
      );
      return;
    }

    if (_isInvalidWindowsPathCharacter(character)) {
      issues.add(
        OutputTemplateIssue(
          'Invalid character "$character". Remove Windows path characters like <, >, :, ", |, ?, or * from literal text.',
        ),
      );
      return;
    }
  }
}

bool _isInvalidWindowsPathCharacter(String character) {
  return switch (character) {
    '<' || '>' || ':' || '"' || '|' || '?' || '*' => true,
    _ => false,
  };
}
