// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Card _$CardFromJson(Map<String, dynamic> json) => Card(
  id: (json['id'] as num).toInt(),
  wordId: (json['wordId'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  state: $enumDecode(_$CardStateEnumMap, json['state']),
  masteryScore: (json['masteryScore'] as num).toDouble(),
  lapses: (json['lapses'] as num).toInt(),
  nextReview: json['nextReview'] == null
      ? null
      : DateTime.parse(json['nextReview'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CardToJson(Card instance) => <String, dynamic>{
  'id': instance.id,
  'wordId': instance.wordId,
  'userId': instance.userId,
  'state': _$CardStateEnumMap[instance.state]!,
  'masteryScore': instance.masteryScore,
  'lapses': instance.lapses,
  'nextReview': instance.nextReview?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$CardStateEnumMap = {
  CardState.newCard: 'new',
  CardState.learning: 'learning',
  CardState.review: 'review',
  CardState.starred: 'starred',
  CardState.leech: 'leech',
  CardState.ambiguous: 'ambiguous',
};
