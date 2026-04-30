import 'package:flutter/material.dart';

/// Files Page - File upload, processing, and indexing workflow
class FilesPage extends StatelessWidget {
  final int projectId;

  const FilesPage({
    Key? key,
    required this.projectId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Files'),
        centerTitle: false,
      ),
      body: const Center(
        child: Text('FilesPage - Phase 4'),
      ),
    );
  }
}
