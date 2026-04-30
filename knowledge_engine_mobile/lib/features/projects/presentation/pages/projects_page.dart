import 'package:flutter/material.dart';

/// Projects Page - First screen for project selection
class ProjectsPage extends StatelessWidget {
  const ProjectsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Engine'),
        centerTitle: false,
      ),
      body: const Center(
        child: Text('ProjectsPage - Phase 3'),
      ),
    );
  }
}
