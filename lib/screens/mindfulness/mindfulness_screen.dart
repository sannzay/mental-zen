import 'package:flutter/material.dart';

import '../../config/constants.dart';
import '../../widgets/cards/tip_card.dart';
import '../../widgets/common/zen_app_bar.dart';
import 'breathing_exercise_screen.dart';
import 'tips_screen.dart';

class MindfulnessScreen extends StatelessWidget {
  const MindfulnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxWidth = 600.0;
    return Scaffold(
      appBar: const ZenAppBar(title: 'Mindfulness'),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: size.width < maxWidth ? size.width : maxWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _CategoryCard(
                      icon: Icons.self_improvement_rounded,
                      title: 'Breathing',
                      description: 'Guided breathing exercises to calm your mind.',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const BreathingExerciseScreen(),
                          ),
                        );
                      },
                    ),
                    _CategoryCard(
                      icon: Icons.spa_rounded,
                      title: 'Meditation',
                      description: 'Simple prompts to help you slow down.',
                      onTap: () {},
                    ),
                    _CategoryCard(
                      icon: Icons.tips_and_updates_rounded,
                      title: 'Tips',
                      description: 'Daily wellness tips you can return to.',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TipsScreen(),
                          ),
                        );
                      },
                    ),
                    _CategoryCard(
                      icon: Icons.format_quote_rounded,
                      title: 'Quotes',
                      description: 'Gentle reminders for difficult days.',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Today\'s tip',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TipCard(
                  title: 'For right now',
                  body: wellnessTips[DateTime.now().day % wellnessTips.length],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 28),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


