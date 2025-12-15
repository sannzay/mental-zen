import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../config/theme.dart';
import '../../models/reminder.dart';
import '../../providers/reminder_provider.dart';
import '../../widgets/buttons/zen_button.dart';
import '../../widgets/common/zen_app_bar.dart';

class AddReminderScreen extends StatefulWidget {
  final Reminder? reminder;

  const AddReminderScreen({
    super.key,
    this.reminder,
  });

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _messageController;
  late TimeOfDay _time;
  List<int> _daysOfWeek = [1, 2, 3, 4, 5, 6, 0];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.reminder?.title ?? '');
    _messageController = TextEditingController(text: widget.reminder?.message ?? '');
    if (widget.reminder != null) {
      final parts = widget.reminder!.time.split(':');
      final hour = int.tryParse(parts[0]) ?? 8;
      final minute = int.tryParse(parts[1]) ?? 0;
      _time = TimeOfDay(hour: hour, minute: minute);
      _daysOfWeek = List<int>.from(widget.reminder!.daysOfWeek);
    } else {
      _time = const TimeOfDay(hour: 8, minute: 0);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) {
      setState(() {
        _time = picked;
      });
    }
  }

  void _toggleDay(int day) {
    setState(() {
      if (_daysOfWeek.contains(day)) {
        _daysOfWeek.remove(day);
      } else {
        _daysOfWeek.add(day);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _daysOfWeek = [1, 2, 3, 4, 5, 6, 0];
    });
  }

  void _selectWeekdays() {
    setState(() {
      _daysOfWeek = [1, 2, 3, 4, 5];
    });
  }

  void _selectWeekends() {
    setState(() {
      _daysOfWeek = [6, 0];
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final provider = context.read<ReminderProvider?>();
    if (provider == null) {
      return;
    }
    final timeString = _time.hour.toString().padLeft(2, '0') + ':' + _time.minute.toString().padLeft(2, '0');
    final now = DateTime.now();
    final isEditing = widget.reminder != null;
    final id = widget.reminder?.id ?? const Uuid().v4();
    final reminder = Reminder(
      id: id,
      userId: widget.reminder?.userId ?? '',
      title: _titleController.text.trim(),
      message: _messageController.text.trim().isEmpty ? 'Gentle check-in from Mental Zen' : _messageController.text.trim(),
      time: timeString,
      daysOfWeek: _daysOfWeek,
      isEnabled: widget.reminder?.isEnabled ?? true,
      createdAt: widget.reminder?.createdAt ?? now,
    );
    if (isEditing) {
      await provider.updateReminder(reminder);
    } else {
      await provider.addReminder(reminder);
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _delete() async {
    final provider = context.read<ReminderProvider?>();
    final reminder = widget.reminder;
    if (provider == null || reminder == null) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete reminder'),
          content: const Text('Are you sure you want to delete this reminder?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await provider.deleteReminder(reminder.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxWidth = 600.0;
    final isEditing = widget.reminder != null;
    final names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final previewTime = _time.format(context);
    final previewDays = _daysOfWeek.length == 7
        ? 'every day'
        : _daysOfWeek.toSet().containsAll({1, 2, 3, 4, 5})
            ? 'weekdays'
            : _daysOfWeek.toSet().containsAll({6, 0})
                ? 'weekends'
                : _daysOfWeek.map((d) => names[d % 7]).join(', ');
    return Scaffold(
      appBar: ZenAppBar(
        title: isEditing ? 'Edit reminder' : 'New reminder',
        actions: [
          if (isEditing)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline_rounded),
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Time',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        previewTime,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: _pickTime,
                        child: const Text('Change'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Days',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (int i = 0; i < 7; i++)
                        ChoiceChip(
                          label: Text(names[i]),
                          selected: _daysOfWeek.contains(i),
                          onSelected: (_) => _toggleDay(i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ActionChip(
                        label: const Text('All'),
                        onPressed: _selectAll,
                      ),
                      ActionChip(
                        label: const Text('Weekdays'),
                        onPressed: _selectWeekdays,
                      ),
                      ActionChip(
                        label: const Text('Weekends'),
                        onPressed: _selectWeekends,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Preview',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.surface,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _titleController.text.isEmpty ? 'Reminder' : _titleController.text.trim(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _messageController.text.isEmpty
                              ? 'Gentle check-in from Mental Zen'
                              : _messageController.text.trim(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$previewTime • $previewDays',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ZenButton(
                    label: isEditing ? 'Save changes' : 'Save reminder',
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


