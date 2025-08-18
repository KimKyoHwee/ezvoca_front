import 'package:json_annotation/json_annotation.dart';

part 'card.g.dart';

enum CardState {
  @JsonValue('new')
  newCard,
  @JsonValue('learning')
  learning,
  @JsonValue('review')
  review,
  @JsonValue('starred')
  starred,
  @JsonValue('leech')
  leech,
  @JsonValue('ambiguous')
  ambiguous,
}

enum ReviewResult {
  @JsonValue('known')
  known,
  @JsonValue('unknown')
  unknown,
  @JsonValue('hard')
  hard,
}

@JsonSerializable()
class Card {
  final int id;
  final int wordId;
  final int userId;
  final CardState state;
  final double masteryScore;
  final int lapses;
  final DateTime? nextReview;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Card({
    required this.id,
    required this.wordId,
    required this.userId,
    required this.state,
    required this.masteryScore,
    required this.lapses,
    this.nextReview,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Card.fromJson(Map<String, dynamic> json) => _$CardFromJson(json);
  Map<String, dynamic> toJson() => _$CardToJson(this);

  Card copyWith({
    CardState? state,
    double? masteryScore,
    int? lapses,
    DateTime? nextReview,
    DateTime? updatedAt,
  }) {
    return Card(
      id: id,
      wordId: wordId,
      userId: userId,
      state: state ?? this.state,
      masteryScore: masteryScore ?? this.masteryScore,
      lapses: lapses ?? this.lapses,
      nextReview: nextReview ?? this.nextReview,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isLearned => masteryScore >= 0.8 && !isLeechOrAmbiguous;
  bool get isLeechOrAmbiguous => state == CardState.leech || state == CardState.ambiguous;
}