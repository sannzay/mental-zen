import 'package:flutter/material.dart';

class BreathingPattern {
  final int inhale;
  final int hold;
  final int exhale;

  const BreathingPattern({
    required this.inhale,
    required this.hold,
    required this.exhale,
  });
}

const List<BreathingPattern> breathingPatterns = [
  BreathingPattern(inhale: 4, hold: 4, exhale: 4),
  BreathingPattern(inhale: 4, hold: 7, exhale: 8),
  BreathingPattern(inhale: 5, hold: 5, exhale: 5),
];

const List<String> wellnessTips = [
  'Take a short walk and notice three things you can see, hear, and feel.',
  'Write down one thing you are grateful for today.',
  'Pause and take five slow, deep breaths.',
  'Drink a glass of water and stretch your shoulders.',
  'Spend five minutes in silence away from screens.',
  'Write a kind note to yourself.',
  'Unplug from social media for 10 minutes.',
  'Notice one thing you did well today.',
  'Name one emotion you are feeling right now.',
  'Take three deep breaths before starting a new task.',
  'Go outside and notice the sky.',
  'Relax your jaw and drop your shoulders.',
  'Listen to a song that calms you.',
  'Write a list of three small wins from today.',
  'Say something kind to yourself out loud.',
  'Light a candle or notice a pleasant scent.',
  'Spend a minute focusing only on your breath.',
  'Write down one worry and one way you can respond to it.',
  'Give yourself permission to rest.',
  'Notice how your body feels from head to toe.',
];

const List<String> motivationalQuotes = [
  'You are doing better than you think.',
  'Every emotion you feel is part of being human.',
  'Rest is productive when your body and mind need it.',
  'Small steps add up to big changes over time.',
  'You do not have to be positive all the time to be worthy.',
  'Your feelings are valid, even if others do not understand them.',
  'Healing is not linear, and that is okay.',
  'You are allowed to take up space and have needs.',
  'You have survived every hard day so far.',
  'Progress, not perfection.',
  'It is okay to ask for help.',
  'You deserve kindness, especially from yourself.',
  'Breathe in calm, breathe out tension.',
  'You are more than your thoughts.',
  'You are learning and growing every day.',
  'You are not alone in how you feel.',
  'Taking care of yourself is a strength, not a weakness.',
  'Your pace is the right pace.',
  'You are enough as you are right now.',
  'One gentle step at a time.',
  'Your story is still being written.',
  'You do not have to carry everything today.',
  'Your emotions are messages, not instructions.',
  'It is okay to not be okay.',
  'You are worthy of love and care.',
  'Your effort matters, even when no one sees it.',
  'You can start again at any moment.',
  'You are allowed to feel proud of yourself.',
  'You have permission to slow down.',
  'Today is a new page.',
];

String moodDescriptor(int score) {
  if (score >= 9) {
    return 'Very positive and energized';
  }
  if (score >= 7) {
    return 'Generally positive and uplifted';
  }
  if (score >= 5) {
    return 'Neutral with some ups and downs';
  }
  if (score >= 3) {
    return 'Feeling low or worn out';
  }
  return 'Very low, needing extra care';
}

const List<String> mindfulnessCategories = [
  'Breathing',
  'Meditation',
  'Tips',
  'Quotes',
];


