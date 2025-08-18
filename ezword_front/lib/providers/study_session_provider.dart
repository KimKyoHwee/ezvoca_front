import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/study_session.dart';
import '../models/card.dart';

class StudySessionNotifier extends StateNotifier<StudySession?> {
  StudySessionNotifier() : super(null);

  void startSession(StudySession session) {
    state = session.copyWith(
      revealState: RevealState.hidden,
      updatedAt: DateTime.now(),
    );
  }

  void revealCard() {
    if (state == null) return;
    
    final currentRevealState = state!.revealState;
    RevealState newRevealState;
    
    switch (currentRevealState) {
      case RevealState.hidden:
        newRevealState = RevealState.peek;
        break;
      case RevealState.peek:
        newRevealState = RevealState.shown;
        break;
      case RevealState.shown:
        return; // Already fully revealed
    }
    
    state = state!.copyWith(
      revealState: newRevealState,
      updatedAt: DateTime.now(),
    );
  }

  void nextCard() {
    if (state == null || state!.isCompleted) return;
    
    state = state!.nextCard();
  }

  void submitReview(ReviewResult result) {
    if (state == null || state!.currentCard == null) return;
    
    // TODO: Send review to backend API
    // For now, just move to next card
    nextCard();
  }

  void toggleFocusMode() {
    if (state == null) return;
    
    final newMode = state!.mode == StudyMode.normal 
        ? StudyMode.focus 
        : StudyMode.normal;
        
    state = state!.copyWith(
      mode: newMode,
      updatedAt: DateTime.now(),
    );
  }

  void saveSnapshot() {
    if (state == null) return;
    
    // TODO: Save session snapshot to local database
    // This will be implemented when we add database layer
  }

  void restoreSnapshot(StudySession snapshot) {
    state = snapshot;
  }

  void endSession() {
    state = null;
  }
}

final studySessionProvider = StateNotifierProvider<StudySessionNotifier, StudySession?>(
  (ref) => StudySessionNotifier(),
);

// Computed providers for UI
final currentCardProvider = Provider<StudySessionCard?>((ref) {
  final session = ref.watch(studySessionProvider);
  return session?.currentCard;
});

final remainingCountProvider = Provider<int>((ref) {
  final session = ref.watch(studySessionProvider);
  return session?.remainingCount ?? 0;
});

final revealStateProvider = Provider<RevealState>((ref) {
  final session = ref.watch(studySessionProvider);
  return session?.revealState ?? RevealState.hidden;
});

final studyModeProvider = Provider<StudyMode>((ref) {
  final session = ref.watch(studySessionProvider);
  return session?.mode ?? StudyMode.normal;
});

final isSessionActiveProvider = Provider<bool>((ref) {
  final session = ref.watch(studySessionProvider);
  return session != null && !session.isCompleted;
});