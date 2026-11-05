import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_engine_mobile/app.dart';
import 'package:knowledge_engine_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:knowledge_engine_mobile/features/auth/presentation/providers/auth_notifier.dart';
import 'package:knowledge_engine_mobile/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('unauthenticated users land on the login route',
      (WidgetTester tester) async {
    // Build the router directly so the test does not depend on secure-storage
    // platform channels during session restore.
    final router = createRouter(
      hasSeenOnboarding: true,
      authStatus: AuthStatus.unauthenticated,
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) => MaterialApp.router(
          routerConfig: router,
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('ar')],
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(LoginPage), findsOneWidget);
  });
}
