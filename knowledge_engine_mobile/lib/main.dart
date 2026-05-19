import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable runtime fetching of Google Fonts to avoid network errors on devices
  // without internet access. Fonts should be bundled in assets for offline use.
  try {
    GoogleFonts.config.allowRuntimeFetching = false;
  } catch (_) {}

  runApp(
    const ProviderScope(
      child: KnowledgeEngineApp(),
    ),
  );
}
