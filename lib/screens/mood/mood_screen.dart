import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../config/theme.dart';
import '../../models/mood_entry.dart';
import '../../providers/mood_provider.dart';
import '../../widgets/cards/mood_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/zen_app_bar.dart';
import '../../widgets/inputs/zen_slider.dart';
import '../mood/add_mood_screen.dart';
import '../mood/mood_history_screen.dart';

class MoodScreen extends StatelessWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxWidth = 600.0;
    return Scaffold(
      appBar: const ZenAppBar(title: 'Mood'),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: size.width < maxWidth ? size.width : maxWidth,
            ),
            child: const _MoodContent(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'moodFab',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddMoodScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MoodContent extends StatefulWidget {
  const _MoodContent();

  @override
  State<_MoodContent> createState() => _MoodContentState();
}

class _MoodContentState extends State<_MoodContent> {
  int _quickMood = 5;

  @override
  Widget build(BuildContext context) {
    final moodProvider = context.watch<MoodProvider?>();
    final todaysMood = moodProvider?.todaysMood;
    final entries = moodProvider?.entries ?? [];
    final weeklyAverage = moodProvider?.weeklyAverage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  todaysMood != null ? 'Today\'s mood' : 'How are you feeling today?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (todaysMood != null)
                  Row(
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
                        child: Text(
                          todaysMood.note?.isNotEmpty == true ? todaysMood.note! : 'Logged for today',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ZenSlider(
                        value: _quickMood,
                        onChanged: (v) {
                          setState(() {
                            _quickMood = v;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          final provider = context.read<MoodProvider?>();
                          if (provider == null) {
                            return;
                          }
                          final now = DateTime.now();
                          final entry = MoodEntry(
                            id: const Uuid().v4(),
                            userId: '',
                            moodScore: _quickMood,
                            createdAt: now,
                          );
                          provider.addMood(entry);
                        },
                        child: const Text('Quick log'),
                      ),
                    ],
                  ),
                if (weeklyAverage != null) ...[
                  const SizedBox(height: 12),
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
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent moods',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MoodHistoryScreen(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View history',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (entries.isEmpty)
          const EmptyState(
            icon: Icons.mood_rounded,
            title: 'No mood entries yet',
            message: 'Start by logging how you feel today.',
          )
        else
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: entries.length > 5 ? 5 : entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return MoodCard(
                entry: entry,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddMoodScreen(entry: entry),
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
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

