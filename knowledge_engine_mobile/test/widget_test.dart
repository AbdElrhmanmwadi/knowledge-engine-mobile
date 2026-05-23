import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_engine_mobile/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app starts on the projects route', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'hasSeenOnboarding': true,
    });

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) => const ProviderScope(
          child: KnowledgeEngineApp(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Knowledge Engine'), findsOneWidget);
    expect(find.text('Open Project'), findsOneWidget);
  });
}
