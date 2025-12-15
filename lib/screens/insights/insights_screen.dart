import 'package:flutter/material.dart';

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                StatCard(
                  label: 'Average mood',
                  value: '-',
                  caption: 'Based on your recent entries',
                  icon: Icons.insights_rounded,
                ),
                SizedBox(height: 16),
                EmptyState(
                  icon: Icons.show_chart_rounded,
                  title: 'No insights yet',
                  message: 'Once you start logging moods and journaling, insights will appear here.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


