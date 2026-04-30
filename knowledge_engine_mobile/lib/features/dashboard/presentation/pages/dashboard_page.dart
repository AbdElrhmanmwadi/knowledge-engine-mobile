import 'package:flutter/material.dart';

/// Dashboard Page - Project overview and navigation hub
class DashboardPage extends StatelessWidget {
  final int projectId;

  const DashboardPage({
    Key? key,
    required this.projectId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project $projectId'),
        centerTitle: false,
      ),
      body: const Center(
        child: Text('DashboardPage - Phase 3'),
      ),
    );
  }
}
