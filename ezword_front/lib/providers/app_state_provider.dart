import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppTheme {
  light,
  dark,
  lowStimulus, // 저자극 모드
}

class AppState {
  final AppTheme theme;
  final bool isOffline;
  final int learnedCount;
  final int totalCount;

  const AppState({
    required this.theme,
    required this.isOffline,
    required this.learnedCount,
    required this.totalCount,
  });

  AppState copyWith({
    AppTheme? theme,
    bool? isOffline,
    int? learnedCount,
    int? totalCount,
  }) {
    return AppState(
      theme: theme ?? this.theme,
      isOffline: isOffline ?? this.isOffline,
      learnedCount: learnedCount ?? this.learnedCount,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState(
    theme: AppTheme.light,
    isOffline: false,
    learnedCount: 0,
    totalCount: 0,
  ));

  void setTheme(AppTheme theme) {
    state = state.copyWith(theme: theme);
  }

  void toggleLowStimulusMode() {
    final newTheme = state.theme == AppTheme.lowStimulus 
        ? AppTheme.light 
        : AppTheme.lowStimulus;
    state = state.copyWith(theme: newTheme);
  }

  void setOfflineStatus(bool isOffline) {
    state = state.copyWith(isOffline: isOffline);
  }

  void updateLearnedCount(int count) {
    state = state.copyWith(learnedCount: count);
  }

  void updateTotalCount(int count) {
    state = state.copyWith(totalCount: count);
  }
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) => AppStateNotifier(),
);

// Theme provider for MaterialApp
final themeDataProvider = Provider<ThemeData>((ref) {
  final appTheme = ref.watch(appStateProvider).theme;
  
  switch (appTheme) {
    case AppTheme.light:
      return ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      );
    case AppTheme.dark:
      return ThemeData.dark(useMaterial3: true);
    case AppTheme.lowStimulus:
      return ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
          brightness: Brightness.light,
        ).copyWith(
          primary: Colors.grey.shade600,
          secondary: Colors.grey.shade400,
        ),
        useMaterial3: true,
        // Minimize animations and visual distractions
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      );
  }
});

// Computed providers
final isLowStimulusModeProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).theme == AppTheme.lowStimulus;
});

final isOfflineProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isOffline;
});

final learnedCountProvider = Provider<int>((ref) {
  return ref.watch(appStateProvider).learnedCount;
});