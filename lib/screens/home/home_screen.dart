import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../widgets/cards/stat_card.dart';
import '../../widgets/cards/tip_card.dart';
import '../../widgets/common/zen_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxWidth = 600.0;
    return Scaffold(
      appBar: const ZenAppBar(title: 'Mental Zen'),
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
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'How are you feeling today?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: const [
                    SizedBox(
                      width: 180,
                      child: StatCard(
                        label: 'Today\'s mood',
                        value: '-',
                        caption: 'Log your mood',
                        icon: Icons.mood_rounded,
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: StatCard(
                        label: 'Entries this week',
                        value: '-',
                        caption: 'Keep the streak',
                        icon: Icons.calendar_today_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Mindful tip',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const TipCard(
                  title: 'Take a slow breath',
                  body: 'Pause for a moment, inhale deeply, and exhale slowly to reset your mind.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


