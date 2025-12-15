import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/insights_provider.dart';
import '../../widgets/cards/stat_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/zen_app_bar.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxWidth = 600.0;
    return Scaffold(
      appBar: const ZenAppBar(title: 'Insights'),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: size.width < maxWidth ? size.width : maxWidth,
            ),
            child: const _InsightsContent(),
          ),
        ),
      ),
    );
  }
}

class _InsightsContent extends StatelessWidget {
  const _InsightsContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InsightsProvider>();
    final entries = provider.moodEntriesInPeriod;
    final avg = provider.averageMood;
    final distribution = provider.moodDistribution;
    final streak = provider.currentStreak;
    final bestDay = provider.bestDayOfWeek;
    final journalingDays = provider.journalingDaysCount;
    final activityByDay = provider.journalingActivityByDay;
    final bestInsight = provider.bestDayInsight;
    final improvementInsight = provider.improvementInsight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChoiceChip(
              label: const Text('Week'),
              selected: provider.period == InsightsPeriod.week,
              onSelected: (_) => provider.setPeriod(InsightsPeriod.week),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Month'),
              selected: provider.period == InsightsPeriod.month,
              onSelected: (_) => provider.setPeriod(InsightsPeriod.month),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Year'),
              selected: provider.period == InsightsPeriod.year,
              onSelected: (_) => provider.setPeriod(InsightsPeriod.year),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Average mood',
                value: avg != null ? avg.toStringAsFixed(1) : '-',
                caption: 'This period',
                icon: Icons.insights_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Entries',
                value: entries.length.toString(),
                caption: 'Mood check-ins',
                icon: Icons.mood_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Streak',
                value: streak > 0 ? '$streak days' : '-',
                caption: 'Daily logging',
                icon: Icons.local_fire_department_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Best day',
                value: bestDay ?? '-',
                caption: 'Day of the week',
                icon: Icons.calendar_today_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Mood trend',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (entries.isEmpty)
          const EmptyState(
            icon: Icons.show_chart_rounded,
            title: 'No data yet',
            message: 'Log your mood to see trends over time.',
          )
        else
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, horizontalInterval: 1),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value % 2 != 0) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          value.toInt().toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= entries.length) {
                          return const SizedBox.shrink();
                        }
                        final date = entries[index].createdAt;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${date.month}/${date.day}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                minY: 1,
                maxY: 10,
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (int i = 0; i < entries.length; i++)
                        FlSpot(i.toDouble(), entries[i].moodScore.toDouble()),
                    ],
                    isCurved: true,
                    barWidth: 3,
                    color: AppColors.primary,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.3),
                          AppColors.primary.withOpacity(0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 24),
        Text(
          'Mood distribution',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _DistributionBar(
                label: 'Low',
                value: distribution[1] ?? 0,
                color: Colors.red,
              ),
              _DistributionBar(
                label: 'Medium',
                value: distribution[2] ?? 0,
                color: Colors.orange,
              ),
              _DistributionBar(
                label: 'High',
                value: distribution[3] ?? 0,
                color: Colors.green,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Journaling activity',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (activityByDay.isEmpty)
          Text(
            'Your journaling activity will appear here.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: activityByDay.entries.map((e) {
              final count = e.value;
              final intensity = (count / 5).clamp(0.2, 1.0);
              return Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(intensity),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 24),
        Text(
          'Insights',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (bestInsight == null && improvementInsight == null)
          Text(
            'As you log more moods and entries, personal insights will appear here.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          )
        else ...[
          if (bestInsight != null) ...[
            Text(
              bestInsight,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
          ],
          if (improvementInsight != null)
            Text(
              improvementInsight,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
        ],
      ],
    );
  }
}

class _DistributionBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _DistributionBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = 100.0;
    final height = value == 0 ? 4.0 : (maxHeight * (value / 10)).clamp(8.0, maxHeight);
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 20,
            height: height,
            decoration: BoxDecoration(
              color: color.withOpacity(0.7),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

