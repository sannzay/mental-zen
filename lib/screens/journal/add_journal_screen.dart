import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../config/theme.dart';
import '../../models/journal_entry.dart';
import '../../providers/journal_provider.dart';
import '../../widgets/buttons/zen_button.dart';
import '../../widgets/inputs/tag_input.dart';
import '../../widgets/inputs/zen_slider.dart';
import '../../widgets/inputs/zen_text_field.dart';
import '../../widgets/common/zen_app_bar.dart';

class AddJournalScreen extends StatefulWidget {
  final JournalEntry? entry;

  const AddJournalScreen({
    super.key,
    this.entry,
  });

  @override
  State<AddJournalScreen> createState() => _AddJournalScreenState();
}

class _AddJournalScreenState extends State<AddJournalScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  int? _moodScore;
  bool _isFavorite = false;
  List<String> _selectedTags = [];

  static const _availableTags = [
    'Gratitude',
    'Reflection',
    'Stress',
    'Wins',
    'Relationships',
    'Work',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController = TextEditingController(text: widget.entry?.content ?? '');
    _moodScore = widget.entry?.moodScore;
    _isFavorite = widget.entry?.isFavorite ?? false;
    _selectedTags = List<String>.from(widget.entry?.tags ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final provider = context.read<JournalProvider?>();
    if (provider == null) {
      return;
    }
    final now = DateTime.now();
    final isEditing = widget.entry != null;
    final id = widget.entry?.id ?? const Uuid().v4();
    final userId = widget.entry?.userId ?? '';
    final entry = JournalEntry(
      id: id,
      userId: userId,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      moodScore: _moodScore,
      tags: _selectedTags,
      isFavorite: _isFavorite,
      createdAt: widget.entry?.createdAt ?? now,
      updatedAt: now,
    );
    if (isEditing) {
      await provider.updateEntry(entry);
    } else {
      await provider.addEntry(entry);
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _delete() async {
    final provider = context.read<JournalProvider?>();
    final entry = widget.entry;
    if (provider == null || entry == null) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete entry'),
          content: const Text('Are you sure you want to delete this journal entry?'),
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
      await provider.deleteEntry(entry.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JournalProvider?>();
    final loading = provider?.isLoading ?? false;
    final error = provider?.errorMessage;
    final size = MediaQuery.of(context).size;
    final maxWidth = 600.0;
    final isEditing = widget.entry != null;
    return Scaffold(
      appBar: ZenAppBar(
        title: isEditing ? 'Edit entry' : 'New entry',
        actions: [
          if (isEditing)
            IconButton(
              onPressed: loading ? null : _delete,
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
                  ZenTextField(
                    controller: _titleController,
                    label: 'Title',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  ZenTextField(
                    controller: _contentController,
                    label: 'Entry',
                    maxLines: 6,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Entry content is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mood (optional)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Switch(
                        value: _moodScore != null,
                        onChanged: (on) {
                          setState(() {
                            _moodScore = on ? (_moodScore ?? 5) : null;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_moodScore != null)
                    ZenSlider(
                      value: _moodScore!,
                      onChanged: (v) {
                        setState(() {
                          _moodScore = v;
                        });
                      },
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Favorite',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Switch(
                        value: _isFavorite,
                        onChanged: (value) {
                          setState(() {
                            _isFavorite = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tags',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TagInput(
                    availableTags: _availableTags,
                    selectedTags: _selectedTags,
                    onChanged: (tags) {
                      setState(() {
                        _selectedTags = tags;
                      });
                    },
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      error,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                          ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ZenButton(
                    label: isEditing ? 'Save changes' : 'Save entry',
                    onPressed: loading ? null : _save,
                    loading: loading,
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


