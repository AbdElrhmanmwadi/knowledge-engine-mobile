import 'dart:convert';

/// One parsed Server-Sent Event.
///
/// [event] is the SSE `event:` name (e.g. "meta" | "delta" | "done" | "error");
/// [data] is the decoded JSON object from the `data:` line.
class SseEvent {
  const SseEvent(this.event, this.data);

  final String event;
  final Map<String, dynamic> data;
}

/// Parses a raw byte stream (an SSE-over-POST response body) into [SseEvent]s.
///
/// SSE blocks are separated by a blank line. Each block may carry an
/// `event:` name and one or more `data:` lines (concatenated with newlines).
/// Both `\n\n` and `\r\n\r\n` separators are handled.
class SseParser {
  const SseParser._();

  static Stream<SseEvent> parse(Stream<List<int>> byteStream) async* {
    var buffer = '';
    await for (final chunk in byteStream.transform(utf8.decoder)) {
      buffer += chunk.replaceAll('\r\n', '\n');
      int sep;
      while ((sep = buffer.indexOf('\n\n')) != -1) {
        final block = buffer.substring(0, sep);
        buffer = buffer.substring(sep + 2);
        final event = _parseBlock(block);
        if (event != null) {
          yield event;
        }
      }
    }

    // Flush any trailing block that wasn't newline-terminated.
    final trailing = buffer.trim();
    if (trailing.isNotEmpty) {
      final event = _parseBlock(trailing);
      if (event != null) {
        yield event;
      }
    }
  }

  static SseEvent? _parseBlock(String block) {
    String? event;
    String? data;
    for (final line in block.split('\n')) {
      if (line.startsWith('event:')) {
        event = line.substring('event:'.length).trim();
      } else if (line.startsWith('data:')) {
        final piece = line.substring('data:'.length);
        data = data == null ? piece : '$data\n$piece';
      }
    }

    if (data == null) {
      return null;
    }

    try {
      final decoded = jsonDecode(data.trim());
      if (decoded is Map<String, dynamic>) {
        return SseEvent(event ?? 'message', decoded);
      }
      return SseEvent(event ?? 'message', <String, dynamic>{'value': decoded});
    } on FormatException {
      return null;
    }
  }
}
