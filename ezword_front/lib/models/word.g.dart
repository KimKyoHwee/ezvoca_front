// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Word _$WordFromJson(Map<String, dynamic> json) => Word(
  id: (json['id'] as num).toInt(),
  word: json['word'] as String,
  meaning: json['meaning'] as String,
  pronunciation: json['pronunciation'] as String?,
  partOfSpeech: json['partOfSpeech'] as String,
  examples:
      (json['examples'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  confusablePairs:
      (json['confusablePairs'] as List<dynamic>?)
          ?.map((e) => ConfusablePair.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$WordToJson(Word instance) => <String, dynamic>{
  'id': instance.id,
  'word': instance.word,
  'meaning': instance.meaning,
  'pronunciation': instance.pronunciation,
  'partOfSpeech': instance.partOfSpeech,
  'examples': instance.examples,
  'confusablePairs': instance.confusablePairs,
};

ConfusablePair _$ConfusablePairFromJson(Map<String, dynamic> json) =>
    ConfusablePair(
      wordId: (json['wordId'] as num).toInt(),
      lemma: json['lemma'] as String,
    );

Map<String, dynamic> _$ConfusablePairToJson(ConfusablePair instance) =>
    <String, dynamic>{'wordId': instance.wordId, 'lemma': instance.lemma};
