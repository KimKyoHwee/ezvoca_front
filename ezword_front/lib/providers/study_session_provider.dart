import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/study_session.dart';
import '../models/card.dart';
import 'database_provider.dart';

class StudySessionNotifier extends StateNotifier<StudySession?> {
  StudySessionNotifier(this.ref) : super(null);
  
  final Ref ref;

  Future<void> startDailySession() async {
    try {
      final sessionCards = await ref.read(dailyStudyCardsProvider.future);
      
      if (sessionCards.isEmpty) {
        return; // No cards to study
      }
      
      final session = StudySession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 1,
        cards: sessionCards,
        currentIndex: 0,
        revealState: RevealState.hidden,
        mode: StudyMode.normal,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      state = session;
    } catch (e) {
      // Handle error - could show snackbar or error state
      rethrow;
    }
  }

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

  Future<void> submitReview(ReviewResult result) async {
    if (state == null || state!.currentCard == null) return;
    
    final currentCard = state!.currentCard!.card;
    
    try {
      // Update card in database based on review result
      final cardsDao = ref.read(cardsDAOProvider);
      await cardsDao.updateCardAfterReview(currentCard.id, result);
      
      // Move to next card
      nextCard();
      
      // Invalidate providers to refresh learned count
      ref.invalidate(learnedCardsCountProvider);
      
    } catch (e) {
      // Handle error - could show snackbar
      rethrow;
    }
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
  (ref) => StudySessionNotifier(ref),
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