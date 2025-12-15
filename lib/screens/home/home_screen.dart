import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/journal_entry.dart';
import '../../models/mood_entry.dart';
import '../../providers/auth_provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/mood_provider.dart';
import '../../widgets/buttons/zen_button.dart';
import '../../widgets/cards/journal_card.dart';
import '../../widgets/cards/stat_card.dart';
import '../../widgets/cards/tip_card.dart';
import '../../widgets/common/zen_app_bar.dart';
import '../../widgets/inputs/zen_slider.dart';
import '../journal/add_journal_screen.dart';
import '../mood/add_mood_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _quickMood = 5;

  static const _quotes = [
    'Small steps every day lead to big changes over time.',
    'Your feelings are valid, and so is your need for rest.',
    'You are allowed to be a work in progress and a masterpiece at the same time.',
    'Breathe in calm, breathe out tension.',
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxWidth = 600.0;
    final auth = context.watch<AuthProvider>();
    final moodProvider = context.watch<MoodProvider?>();
    final journalProvider = context.watch<JournalProvider?>();
    final todaysMood = moodProvider?.todaysMood;
    final weeklyAverage = moodProvider?.weeklyAverage;
    final streak = _streakFromEntries(moodProvider?.entries ?? []);
    final recentJournals = (journalProvider?.entries ?? []).take(3).toList();
    final userName = auth.user?.displayName?.isNotEmpty == true
        ? auth.user!.displayName!
        : (auth.user?.email?.split('@').first ?? 'Friend');
    final dateText = DateFormat('EEEE, MMM d').format(DateTime.now());
    final quote = _quotes[DateTime.now().day % _quotes.length];
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
                  'Hi $userName',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 16),
                _buildMoodCard(context, todaysMood, weeklyAverage),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: 180,
                      child: StatCard(
                        label: 'Streak',
                        value: streak > 0 ? '$streak days' : '-',
                        caption: 'Days in a row logged',
                        icon: Icons.local_fire_department_rounded,
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: StatCard(
                        label: 'Entries this week',
                        value: _entriesThisWeek(moodProvider?.entries ?? []).toString(),
                        caption: 'Keep the habit going',
                        icon: Icons.calendar_today_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Quick actions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ZenButton(
                        label: 'Log mood',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AddMoodScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ZenButton(
                        label: 'New entry',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AddJournalScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Recent entries',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (recentJournals.isEmpty)
                  Text(
                    'Your recent reflections will appear here.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  )
                else
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: recentJournals.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final entry = recentJournals[index];
                      return JournalCard(
                        entry: entry,
                        onTap: () {},
                      );
                    },
                  ),
                const SizedBox(height: 24),
                Text(
                  'Motivational quote',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TipCard(
                  title: 'For today',
                  body: quote,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodCard(BuildContext context, MoodEntry? todaysMood, double? weeklyAverage) {
    if (todaysMood != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _moodColor(todaysMood.moodScore).withOpacity(0.15),
                ),
                alignment: Alignment.center,
                child: Text(
                  todaysMood.moodScore.toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _moodColor(todaysMood.moodScore),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s mood',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      todaysMood.note?.isNotEmpty == true ? todaysMood.note! : 'Thanks for checking in today.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (weeklyAverage != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Weekly average: ${weeklyAverage.toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'How are you feeling today?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ZenSlider(
              value: _quickMood,
              onChanged: (v) {
                setState(() {
                  _quickMood = v;
                });
              },
            ),
            const SizedBox(height: 8),
            ZenButton(
              label: 'Quick log',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddMoodScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  int _streakFromEntries(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return 0;
    }
    final byDay = <DateTime, bool>{};
    for (final entry in entries) {
      final day = DateTime(entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
      byDay[day] = true;
    }
    int streak = 0;
    var cursor = DateTime.now();
    while (true) {
      final day = DateTime(cursor.year, cursor.month, cursor.day);
      if (byDay[day] == true) {
        streak += 1;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  int _entriesThisWeek(List<MoodEntry> entries) {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 6));
    final from = DateTime(start.year, start.month, start.day);
    final to = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return entries
        .where(
          (e) => !e.createdAt.isBefore(from) && !e.createdAt.isAfter(to),
        )
        .length;
  }

  Color _moodColor(int score) {
    if (score >= 7) {
      return Colors.green;
    }
    if (score >= 4) {
      return Colors.orange;
    }
    return Colors.red;
  }
}

