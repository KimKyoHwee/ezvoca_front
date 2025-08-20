import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ezword_front/main.dart';
import 'package:ezword_front/providers/api_provider.dart';

void main() {
  testWidgets('EzVoca app shows API waiting message', (WidgetTester tester) async {
    // Override providers for testing
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => false), // Not authenticated
        ],
        child: const EzVocaApp(),
      ),
    );

    // Wait for async operations
    await tester.pumpAndSettle();

    // Verify that the API waiting message is shown
    expect(find.text('EzVoca'), findsOneWidget);
    expect(find.text('백엔드 API 연동 대기 중'), findsOneWidget);
    expect(find.text('현재 API 서버 개발 진행 중입니다.\n서버 연동 완료 후 로그인 기능이 활성화됩니다.'), findsOneWidget);
  });

  testWidgets('App with mock auth shows learning stats', (WidgetTester tester) async {
    // Mock learning counters data
    final mockCounters = {
      'totalWords': 100,
      'learnedWords': 25,
    };

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => true), // Authenticated
          learningCountersProvider.overrideWith(
            (ref) => Future.value(mockCounters),
          ),
        ],
        child: const EzVocaApp(),
      ),
    );

    // Wait for async operations
    await tester.pumpAndSettle();

    // Verify that learning stats are shown
    expect(find.text('EzVoca'), findsOneWidget);
    expect(find.text('학습 진행 상황'), findsOneWidget);
    expect(find.text('100'), findsOneWidget); // Total words
    expect(find.text('25'), findsOneWidget);  // Learned words
    expect(find.text('학습 시작'), findsOneWidget);
    expect(find.text('복습하기'), findsOneWidget);
  });
}
