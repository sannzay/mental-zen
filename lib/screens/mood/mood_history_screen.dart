import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/mood_entry.dart';
import '../../providers/mood_provider.dart';
import '../../widgets/cards/mood_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/zen_app_bar.dart';

class MoodHistoryScreen extends StatefulWidget {
  const MoodHistoryScreen({super.key});

  @override
  State<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends State<MoodHistoryScreen> {
  bool _calendarView = false;

  @override
  Widget build(BuildContext context) {
    final moodProvider = context.watch<MoodProvider?>();
    final entries = moodProvider?.entries ?? [];
    final size = MediaQuery.of(context).size;
    final maxWidth = 600.0;
    return Scaffold(
      appBar: ZenAppBar(
        title: 'Mood history',
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _calendarView = !_calendarView;
              });
            },
            icon: Icon(_calendarView ? Icons.list_rounded : Icons.calendar_today_rounded),
          ),
          IconButton(
            onPressed: () async {
              final now = DateTime.now();
              final initial = DateTimeRange(
                start: now.subtract(const Duration(days: 6)),
                end: now,
              );
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(now.year - 1),
                lastDate: DateTime(now.year + 1),
                initialDateRange: moodProvider?.filterRange ?? initial,
              );
              if (picked != null) {
                moodProvider?.setFilter(picked);
              } else {
                moodProvider?.setFilter(null);
              }
            },
            icon: const Icon(Icons.filter_list_rounded),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: size.width < maxWidth ? size.width : maxWidth,
            ),
            child: entries.isEmpty
                ? const EmptyState(
                    icon: Icons.mood_rounded,
                    title: 'No entries in this range',
                    message: 'Try adjusting your filters or log a new mood.',
                  )
                : _calendarView
                    ? _buildCalendar(entries)
                    : _buildList(entries),
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<MoodEntry> entries) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return MoodCard(
          entry: entry,
          onTap: () {},
        );
      },
    );
  }

  Widget _buildCalendar(List<MoodEntry> entries) {
    final byDay = <DateTime, List<MoodEntry>>{};
    for (final entry in entries) {
      final key = DateTime(entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
      byDay.putIfAbsent(key, () => []).add(entry);
    }
    final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: days.map((day) {
        final dayEntries = byDay[day]!;
        final avg = dayEntries.fold<int>(0, (acc, e) => acc + e.moodScore) / dayEntries.length;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.surface,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Text(
                avg.toStringAsFixed(1),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.green,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}


