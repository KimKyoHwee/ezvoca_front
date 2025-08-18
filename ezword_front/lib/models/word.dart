import 'package:json_annotation/json_annotation.dart';

part 'word.g.dart';

@JsonSerializable()
class Word {
  final int id;
  final String word;
  final String meaning;
  final String? pronunciation;
  final String partOfSpeech;
  final List<String> examples;
  final List<ConfusablePair> confusablePairs;

  const Word({
    required this.id,
    required this.word,
    required this.meaning,
    this.pronunciation,
    required this.partOfSpeech,
    this.examples = const [],
    this.confusablePairs = const [],
  });

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);
  Map<String, dynamic> toJson() => _$WordToJson(this);
}

@JsonSerializable()
class ConfusablePair {
  final int wordId;
  final String lemma;

  const ConfusablePair({
    required this.wordId,
    required this.lemma,
  });

  factory ConfusablePair.fromJson(Map<String, dynamic> json) => _$ConfusablePairFromJson(json);
  Map<String, dynamic> toJson() => _$ConfusablePairToJson(this);
}