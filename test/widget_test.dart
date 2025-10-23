import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_liv/main.dart';
import 'package:flutter_liv/services/auth_service.dart';
import 'package:flutter_liv/services/user_service.dart';
import 'package:flutter_liv/services/theme_service.dart';

void main() {
  testWidgets('LIV App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthService.instance),
          ChangeNotifierProvider(create: (_) => UserService.instance),
          ChangeNotifierProvider(create: (_) => ThemeService.instance),
        ],
        child: const LIVApp(),
      ),
    );

    // Verify that the app loads
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
