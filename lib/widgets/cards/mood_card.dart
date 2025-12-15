import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../models/mood_entry.dart';

class MoodCard extends StatelessWidget {
  final MoodEntry entry;
  final VoidCallback? onTap;

  const MoodCard({
    super.key,
    required this.entry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final moodColor = entry.moodScore >= 7
        ? Colors.green
        : entry.moodScore >= 4
            ? Colors.orange
            : Colors.red;
    final dateText = TimeOfDay.fromDateTime(entry.createdAt).format(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: moodColor.withOpacity(0.15),
                ),
                alignment: Alignment.center,
                child: Text(
                  entry.moodScore.toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: moodColor,
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
                      entry.note?.isNotEmpty == true ? entry.note! : 'Mood entry',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


