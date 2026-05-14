import 'dart:typed_data';

/// Outcome of `POST /api/v1/voice/tts` (WAV bytes on success, structured failure otherwise).
sealed class TtsResult {
  const TtsResult();

  bool get isSuccess => this is TtsSuccess;
  bool get isFailure => this is TtsFailure;
}

class TtsSuccess extends TtsResult {
  const TtsSuccess({required this.bytes});

  final Uint8List bytes;
}

class TtsFailure extends TtsResult {
  const TtsFailure({
    required this.message,
    this.signal,
  });

  final String message;
  final String? signal;
}
