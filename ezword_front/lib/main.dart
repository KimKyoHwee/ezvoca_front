import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/app_state_provider.dart';
import 'providers/api_provider.dart';
import 'routes/app_router.dart';

void main() {
  runApp(const ProviderScope(child: EzVocaApp()));
}

class EzVocaApp extends ConsumerWidget {
  const EzVocaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeDataProvider);
    final router = ref.watch(appRouterProvider);
    
    // Initialize API client
    ref.watch(apiClientProvider);
    
    return MaterialApp.router(
      title: 'EzVoca - TOEFL Vocabulary',
      theme: themeData,
      routerConfig: router,
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final learningCountersAsyncValue = ref.watch(learningCountersProvider);
    final authState = ref.watch(authStateProvider);
    final isLowStimulus = ref.watch(isLowStimulusModeProvider);
    final networkState = ref.watch(networkStateProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('EzVoca'),
        actions: [
          if (!networkState)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.cloud_off, color: Colors.orange),
            ),
          IconButton(
            icon: Icon(isLowStimulus ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              ref.read(appStateProvider.notifier).toggleLowStimulusMode();
            },
            tooltip: isLowStimulus ? 'Normal Mode' : 'Focus Mode',
          ),
        ],
      ),
      body: !authState 
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 64,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '백엔드 API 연동 대기 중',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '현재 API 서버 개발 진행 중입니다.\n서버 연동 완료 후 로그인 기능이 활성화됩니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        : learningCountersAsyncValue.when(
            data: (counters) {
              final totalWords = counters['totalWords'] ?? 0;
              final learnedWords = counters['learnedWords'] ?? 0;
              
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      margin: const EdgeInsets.all(24),
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '학습 진행 상황',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      '$totalWords',
                                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      '총 단어',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '$learnedWords',
                                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      '학습 완료',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.go('/study');
                      },
                      icon: const Icon(Icons.school),
                      label: const Text('학습 시작'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 50),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        context.go('/study');
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('복습하기'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(200, 50),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('데이터 로딩 중...'),
                ],
              ),
            ),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text('데이터 로딩 오류: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(learningCountersProvider),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
