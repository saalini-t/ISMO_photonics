import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/screens/login_screen.dart';

void main() {
  Widget createWidgetUnderTest({VoidCallback? onRegister}) {
    return ProviderScope(
      child: MaterialApp(
        home: LoginScreen(onRegisterTapped: onRegister),
      ),
    );
  }

  testWidgets('Test that LoginScreen renders email & password fields and Login button', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(find.text('Don\'t have an account? Register'), findsOneWidget);
  });

  testWidgets('Test form validation triggers when empty fields are submitted', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Required'), findsNWidgets(2));
  });

  testWidgets('Test tapping "Register" navigates / triggers register callback', (WidgetTester tester) async {
    bool isRegisteredTapped = false;
    await tester.pumpWidget(createWidgetUnderTest(
      onRegister: () => isRegisteredTapped = true,
    ));

    await tester.tap(find.text('Don\'t have an account? Register'));
    await tester.pump();

    expect(isRegisteredTapped, isTrue);
  });
}
