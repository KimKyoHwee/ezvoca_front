import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/app_state_provider.dart';
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
    final learnedCount = ref.watch(learnedCountProvider);
    final isLowStimulus = ref.watch(isLowStimulusModeProvider);
    final isOffline = ref.watch(isOfflineProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('EzVoca'),
        actions: [
          if (isOffline)
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
      body: Center(
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
                      '학습한 단어',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$learnedCount',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '개',
                      style: Theme.of(context).textTheme.titleMedium,
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
      ),
    );
  }
}
