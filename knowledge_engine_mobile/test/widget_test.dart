import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_engine_mobile/app.dart';

void main() {
  testWidgets('app starts on the projects route', (WidgetTester tester) async {
    await tester.pumpWidget(const KnowledgeEngineApp());
    await tester.pumpAndSettle();

    expect(find.text('Knowledge Engine'), findsOneWidget);
    expect(find.text('ProjectsPage - Phase 3'), findsOneWidget);
  });
}
