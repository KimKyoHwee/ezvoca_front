import '../models/word.dart';
import '../models/card.dart';

class SampleData {
  static final List<Word> sampleWords = [
    Word(
      id: 1,
      word: 'abandon',
      meaning: '버리다, 포기하다',
      pronunciation: '/əˈbændən/',
      partOfSpeech: 'verb',
      examples: [
        'The crew abandoned the sinking ship.',
        'She abandoned her dreams of becoming a doctor.',
      ],
      confusablePairs: [],
    ),
    Word(
      id: 2,
      word: 'abbreviate',
      meaning: '줄이다, 단축하다',
      pronunciation: '/əˈbriːvieɪt/',
      partOfSpeech: 'verb',
      examples: [
        'Please abbreviate this long document.',
        'The word "doctor" is often abbreviated as "Dr."',
      ],
      confusablePairs: [],
    ),
    Word(
      id: 3,
      word: 'abstract',
      meaning: '추상적인, 요약',
      pronunciation: '/ˈæbstrækt/',
      partOfSpeech: 'adjective',
      examples: [
        'Abstract art is difficult to understand.',
        'The concept of time is abstract.',
      ],
      confusablePairs: [],
    ),
    Word(
      id: 4,
      word: 'abundant',
      meaning: '풍부한, 많은',
      pronunciation: '/əˈbʌndənt/',
      partOfSpeech: 'adjective',
      examples: [
        'The forest is abundant with wildlife.',
        'She has abundant energy.',
      ],
      confusablePairs: [],
    ),
    Word(
      id: 5,
      word: 'accelerate',
      meaning: '가속하다, 빨라지다',
      pronunciation: '/əkˈseləreɪt/',
      partOfSpeech: 'verb',
      examples: [
        'The car began to accelerate.',
        'The economic growth is accelerating.',
      ],
      confusablePairs: [],
    ),
    Word(
      id: 6,
      word: 'accommodate',
      meaning: '수용하다, 적응시키다',
      pronunciation: '/əˈkɒmədeɪt/',
      partOfSpeech: 'verb',
      examples: [
        'The hotel can accommodate 500 guests.',
        'We need to accommodate different viewpoints.',
      ],
      confusablePairs: [],
    ),
    Word(
      id: 7,
      word: 'accumulate',
      meaning: '축적하다, 쌓이다',
      pronunciation: '/əˈkjuːmjəleɪt/',
      partOfSpeech: 'verb',
      examples: [
        'Dust began to accumulate on the shelf.',
        'He accumulated wealth over the years.',
      ],
      confusablePairs: [],
    ),
    Word(
      id: 8,
      word: 'accurate',
      meaning: '정확한, 정밀한',
      pronunciation: '/ˈækjərət/',
      partOfSpeech: 'adjective',
      examples: [
        'Please provide accurate information.',
        'The clock is very accurate.',
      ],
      confusablePairs: [],
    ),
    Word(
      id: 9,
      word: 'achieve',
      meaning: '성취하다, 달성하다',
      pronunciation: '/əˈtʃiːv/',
      partOfSpeech: 'verb',
      examples: [
        'She achieved her goal of becoming a lawyer.',
        'It\'s difficult to achieve perfection.',
      ],
      confusablePairs: [],
    ),
    Word(
      id: 10,
      word: 'acquire',
      meaning: '획득하다, 습득하다',
      pronunciation: '/əˈkwaɪər/',
      partOfSpeech: 'verb',
      examples: [
        'He acquired new skills through practice.',
        'The company acquired its competitor.',
      ],
      confusablePairs: [],
    ),
    // Confusable pairs examples
    Word(
      id: 11,
      word: 'desert',
      meaning: '사막, 버리다',
      pronunciation: '/ˈdezərt/',
      partOfSpeech: 'noun',
      examples: [
        'The Sahara is the largest desert in Africa.',
        'Don\'t desert your friends in time of need.',
      ],
      confusablePairs: [
        ConfusablePair(wordId: 12, lemma: 'dessert'),
      ],
    ),
    Word(
      id: 12,
      word: 'dessert',
      meaning: '디저트, 후식',
      pronunciation: '/dɪˈzɜːrt/',
      partOfSpeech: 'noun',
      examples: [
        'What would you like for dessert?',
        'Ice cream is my favorite dessert.',
      ],
      confusablePairs: [
        ConfusablePair(wordId: 11, lemma: 'desert'),
      ],
    ),
    Word(
      id: 13,
      word: 'affect',
      meaning: '영향을 주다',
      pronunciation: '/əˈfekt/',
      partOfSpeech: 'verb',
      examples: [
        'The weather can affect your mood.',
        'How did this decision affect the outcome?',
      ],
      confusablePairs: [
        ConfusablePair(wordId: 14, lemma: 'effect'),
      ],
    ),
    Word(
      id: 14,
      word: 'effect',
      meaning: '효과, 결과',
      pronunciation: '/ɪˈfekt/',
      partOfSpeech: 'noun',
      examples: [
        'The effect of the medicine was immediate.',
        'What was the effect of your decision?',
      ],
      confusablePairs: [
        ConfusablePair(wordId: 13, lemma: 'affect'),
      ],
    ),
    Word(
      id: 15,
      word: 'analyze',
      meaning: '분석하다',
      pronunciation: '/ˈænəlaɪz/',
      partOfSpeech: 'verb',
      examples: [
        'Scientists analyze the data carefully.',
        'Let\'s analyze the situation.',
      ],
      confusablePairs: [],
    ),
  ];

  static List<Card> generateSampleCards() {
    final cards = <Card>[];
    final now = DateTime.now();

    for (int i = 0; i < sampleWords.length; i++) {
      final word = sampleWords[i];
      
      CardState state;
      double masteryScore;
      int lapses;
      DateTime? nextReview;

      // Distribute cards across different states for testing
      if (i < 5) {
        // New cards
        state = CardState.newCard;
        masteryScore = 0.0;
        lapses = 0;
        nextReview = null;
      } else if (i < 8) {
        // Learning cards
        state = CardState.learning;
        masteryScore = 0.3 + (i % 3) * 0.2;
        lapses = i % 2;
        nextReview = now.add(Duration(minutes: 10 * (i % 3 + 1)));
      } else if (i < 12) {
        // Review cards (some due, some not)
        state = CardState.review;
        masteryScore = 0.8 + (i % 2) * 0.1;
        lapses = 0;
        nextReview = i % 2 == 0 
            ? now.subtract(Duration(hours: i % 6 + 1))  // Due for review
            : now.add(Duration(days: i % 3 + 1));       // Not due yet
      } else if (i < 14) {
        // Leech cards
        state = CardState.leech;
        masteryScore = 0.2;
        lapses = 5 + i % 3;
        nextReview = now.add(const Duration(hours: 1));
      } else {
        // Starred/ambiguous cards
        state = i % 2 == 0 ? CardState.starred : CardState.ambiguous;
        masteryScore = 0.6;
        lapses = 1;
        nextReview = now.add(const Duration(hours: 2));
      }

      cards.add(Card(
        id: i + 1,
        wordId: word.id,
        userId: 1,
        state: state,
        masteryScore: masteryScore,
        lapses: lapses,
        nextReview: nextReview,
        createdAt: now.subtract(Duration(days: i % 7)),
        updatedAt: now,
      ));
    }

    return cards;
  }

  // Statistics for testing
  static Map<String, int> getExpectedStats() {
    final cards = generateSampleCards();
    final learnedCount = cards.where((c) => 
      c.masteryScore >= 0.8 && 
      c.state != CardState.leech && 
      c.state != CardState.ambiguous
    ).length;
    
    return {
      'totalWords': sampleWords.length,
      'totalCards': cards.length,
      'learnedCards': learnedCount,
      'newCards': cards.where((c) => c.state == CardState.newCard).length,
      'learningCards': cards.where((c) => c.state == CardState.learning).length,
      'reviewCards': cards.where((c) => c.state == CardState.review).length,
      'leechCards': cards.where((c) => c.state == CardState.leech).length,
      'confusablePairs': sampleWords.where((w) => w.confusablePairs.isNotEmpty).length,
    };
  }
}