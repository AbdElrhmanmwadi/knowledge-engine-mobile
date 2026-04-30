import 'package:flutter/material.dart';

/// Ask Page - Semantic search and RAG question answering
class AskPage extends StatelessWidget {
  final int projectId;

  const AskPage({
    Key? key,
    required this.projectId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask AI'),
        centerTitle: false,
      ),
      body: const Center(
        child: Text('AskPage - Phase 5'),
      ),
    );
  }
}
