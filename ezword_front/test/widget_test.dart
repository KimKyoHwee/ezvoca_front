import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ezword_front/main.dart';

void main() {
  testWidgets('EzVoca app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: EzVocaApp()));

    // Verify that the main elements are present.
    expect(find.text('EzVoca'), findsOneWidget);
    expect(find.text('학습한 단어'), findsOneWidget);
    expect(find.text('0'), findsOneWidget); // Initial learned count
    expect(find.text('학습 시작'), findsOneWidget);
    expect(find.text('복습하기'), findsOneWidget);

    // Tap the study button and verify navigation.
    await tester.tap(find.text('학습 시작'));
    await tester.pumpAndSettle();
    
    // Should navigate to study screen
    expect(find.text('학습하기'), findsOneWidget);
    expect(find.text('남은 0개'), findsOneWidget);
  });

  testWidgets('Focus mode toggle test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: EzVocaApp()));

    // Find and tap the focus mode toggle button.
    final focusButton = find.byIcon(Icons.visibility_off);
    expect(focusButton, findsOneWidget);
    
    await tester.tap(focusButton);
    await tester.pump();

    // After toggling, the icon should change.
    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });
}
