// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudySessionCard _$StudySessionCardFromJson(Map<String, dynamic> json) =>
    StudySessionCard(
      word: Word.fromJson(json['word'] as Map<String, dynamic>),
      card: Card.fromJson(json['card'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StudySessionCardToJson(StudySessionCard instance) =>
    <String, dynamic>{'word': instance.word, 'card': instance.card};

StudySession _$StudySessionFromJson(Map<String, dynamic> json) => StudySession(
  id: json['id'] as String,
  userId: (json['userId'] as num).toInt(),
  cards: (json['cards'] as List<dynamic>)
      .map((e) => StudySessionCard.fromJson(e as Map<String, dynamic>))
      .toList(),
  currentIndex: (json['currentIndex'] as num).toInt(),
  revealState: $enumDecode(_$RevealStateEnumMap, json['revealState']),
  mode: $enumDecode(_$StudyModeEnumMap, json['mode']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$StudySessionToJson(StudySession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'cards': instance.cards,
      'currentIndex': instance.currentIndex,
      'revealState': _$RevealStateEnumMap[instance.revealState]!,
      'mode': _$StudyModeEnumMap[instance.mode]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$RevealStateEnumMap = {
  RevealState.hidden: 'hidden',
  RevealState.peek: 'peek',
  RevealState.shown: 'shown',
};

const _$StudyModeEnumMap = {
  StudyMode.normal: 'normal',
  StudyMode.focus: 'focus',
};
