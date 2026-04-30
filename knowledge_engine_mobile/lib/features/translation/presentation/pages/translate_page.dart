import 'package:flutter/material.dart';

/// Translate Page - File translation job management
class TranslatePage extends StatelessWidget {
  final int projectId;

  const TranslatePage({
    Key? key,
    required this.projectId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Translation'),
        centerTitle: false,
      ),
      body: const Center(
        child: Text('TranslatePage - Phase 6'),
      ),
    );
  }
}
