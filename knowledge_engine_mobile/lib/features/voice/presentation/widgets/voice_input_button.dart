import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../../../core/network/user_friendly_error.dart';
import '../../../../l10n/l10n.dart';
import '../../data/repositories/voice_repository.dart';

class VoiceInputButton extends StatefulWidget {
  const VoiceInputButton({
    super.key,
    required this.onTranscribed,
    this.onError,
    this.enabled = true,
    this.color,
    this.foregroundColor,
    this.size,
  });

  final ValueChanged<String> onTranscribed;
  final ValueChanged<String>? onError;
  final bool enabled;
  final Color? color;
  final Color? foregroundColor;
  final double? size;

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  final AudioRecorder _recorder = AudioRecorder();
  final VoiceRepository _repository = VoiceRepository();

  bool _isRecording = false;
  bool _isTranscribing = false;
  String? _recordingPath;

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (!widget.enabled && !_isRecording) {
      return;
    }
    if (_isRecording) {
      await _stopAndTranscribe();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        _emitError('Microphone permission is required to record.');
        return;
      }
      if (!await _recorder.hasPermission()) {
        _emitError('Recording is not available on this device.');
        return;
      }

      final dir = await getTemporaryDirectory();
      final filePath = p.join(
        dir.path,
        'voice_input_${DateTime.now().millisecondsSinceEpoch}.m4a',
      );
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: filePath,
      );
      if (!mounted) return;
      setState(() {
        _isRecording = true;
        _recordingPath = filePath;
      });
    } catch (error) {
      _emitError(
        UserFriendlyError.message(
          error,
          fallback: 'Could not start recording.',
        ),
      );
    }
  }

  Future<void> _stopAndTranscribe() async {
    String? path;
    try {
      path = await _recorder.stop();
    } catch (error) {
      _emitError(
        UserFriendlyError.message(error, fallback: 'Could not stop recording.'),
      );
    }

    if (!mounted) return;
    setState(() {
      _isRecording = false;
      _isTranscribing = true;
    });

    try {
      final audioPath = path ?? _recordingPath;
      if (audioPath == null || audioPath.isEmpty) {
        _emitError('No recording was captured.');
        return;
      }

      final file = File(audioPath);
      if (!await file.exists()) {
        _emitError('Audio file is missing. Record again.');
        return;
      }

      final response = await _repository.transcribe(audioFile: file);
      final text = response.text.trim();
      if (text.isEmpty) {
        _emitError('No speech was detected.');
        return;
      }
      widget.onTranscribed(text);
    } catch (error) {
      _emitError(
        UserFriendlyError.message(
          error,
          fallback: 'Speech-to-text failed. Please try again.',
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTranscribing = false;
          _recordingPath = null;
        });
      }
    }
  }

  void _emitError(String message) {
    widget.onError?.call(message);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = widget.size ?? 48.w;
    final color = _isRecording
        ? scheme.error
        : widget.color ?? scheme.secondary;
    final foregroundColor = widget.foregroundColor ?? scheme.onSecondary;
    final enabled = widget.enabled || _isRecording;

    return Tooltip(
      message: _isRecording ? context.l10n.stop : context.l10n.tapToRecord,
      child: SizedBox(
        width: size,
        height: size,
        child: Material(
          color: enabled ? color : color.withValues(alpha: 0.3),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: enabled && !_isTranscribing ? _toggleRecording : null,
            child: Center(
              child: _isTranscribing
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: foregroundColor,
                      ),
                    )
                  : Icon(
                      _isRecording
                          ? Icons.stop_rounded
                          : Icons.mic_none_rounded,
                      color: foregroundColor,
                      size: 22.w,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
