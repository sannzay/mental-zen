import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/reminder.dart';
import '../../providers/reminder_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/zen_app_bar.dart';
import 'add_reminder_screen.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReminderProvider?>();
    final reminders = provider?.reminders ?? [];
    final size = MediaQuery.of(context).size;
    final maxWidth = 600.0;
    return Scaffold(
      appBar: const ZenAppBar(title: 'Reminders'),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: size.width < maxWidth ? size.width : maxWidth,
            ),
            child: reminders.isEmpty
                ? const EmptyState(
                    icon: Icons.notifications_none_rounded,
                    title: 'No reminders yet',
                    message: 'Create a gentle nudge to check in with yourself.',
                  )
                : ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: reminders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final reminder = reminders[index];
                      return Dismissible(
                        key: ValueKey(reminder.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          color: AppColors.error.withOpacity(0.8),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (_) {
                          context.read<ReminderProvider?>()?.deleteReminder(reminder.id);
                        },
                        child: _ReminderTile(reminder: reminder),
                      );
                    },
                  ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddReminderScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final Reminder reminder;

  const _ReminderTile({
    required this.reminder,
  });

  String _daysText() {
    if (reminder.daysOfWeek.length == 7) {
      return 'Every day';
    }
    if (reminder.daysOfWeek.toSet().containsAll({1, 2, 3, 4, 5})) {
      return 'Weekdays';
    }
    if (reminder.daysOfWeek.toSet().containsAll({6, 0})) {
      return 'Weekends';
    }
    const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return reminder.daysOfWeek.map((d) => names[d % 7]).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ReminderProvider?>();
    return ListTile(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddReminderScreen(reminder: reminder),
          ),
        );
      },
      title: Text(reminder.title),
      subtitle: Text('${reminder.time} • ${_daysText()}'),
      trailing: Switch(
        value: reminder.isEnabled,
        onChanged: (value) {
          provider?.toggleReminder(reminder, value);
        },
      ),
    );
  }
}


