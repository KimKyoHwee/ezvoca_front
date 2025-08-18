import 'package:json_annotation/json_annotation.dart';
import 'word.dart';
import 'card.dart';

part 'study_session.g.dart';

enum RevealState {
  @JsonValue('hidden')
  hidden,
  @JsonValue('peek')
  peek,
  @JsonValue('shown')
  shown,
}

enum StudyMode {
  @JsonValue('normal')
  normal,
  @JsonValue('focus')
  focus,
}

@JsonSerializable()
class StudySessionCard {
  final Word word;
  final Card card;

  const StudySessionCard({
    required this.word,
    required this.card,
  });

  factory StudySessionCard.fromJson(Map<String, dynamic> json) => _$StudySessionCardFromJson(json);
  Map<String, dynamic> toJson() => _$StudySessionCardToJson(this);
}

@JsonSerializable()
class StudySession {
  final String id;
  final int userId;
  final List<StudySessionCard> cards;
  final int currentIndex;
  final RevealState revealState;
  final StudyMode mode;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudySession({
    required this.id,
    required this.userId,
    required this.cards,
    required this.currentIndex,
    required this.revealState,
    required this.mode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudySession.fromJson(Map<String, dynamic> json) => _$StudySessionFromJson(json);
  Map<String, dynamic> toJson() => _$StudySessionToJson(this);

  StudySessionCard? get currentCard {
    if (currentIndex >= 0 && currentIndex < cards.length) {
      return cards[currentIndex];
    }
    return null;
  }

  int get remainingCount => cards.length - currentIndex;
  bool get isCompleted => currentIndex >= cards.length;

  StudySession copyWith({
    int? currentIndex,
    RevealState? revealState,
    StudyMode? mode,
    DateTime? updatedAt,
  }) {
    return StudySession(
      id: id,
      userId: userId,
      cards: cards,
      currentIndex: currentIndex ?? this.currentIndex,
      revealState: revealState ?? this.revealState,
      mode: mode ?? this.mode,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  StudySession nextCard() {
    return copyWith(
      currentIndex: currentIndex + 1,
      revealState: RevealState.hidden,
      updatedAt: DateTime.now(),
    );
  }

  StudySession reveal() {
    switch (revealState) {
      case RevealState.hidden:
        return copyWith(revealState: RevealState.peek);
      case RevealState.peek:
        return copyWith(revealState: RevealState.shown);
      case RevealState.shown:
        return this;
    }
  }
}