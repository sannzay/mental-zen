import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../config/theme.dart';
import '../../models/mood_entry.dart';
import '../../providers/mood_provider.dart';
import '../../widgets/buttons/zen_button.dart';
import '../../widgets/inputs/tag_input.dart';
import '../../widgets/inputs/zen_slider.dart';
import '../../widgets/inputs/zen_text_field.dart';
import '../../widgets/common/zen_app_bar.dart';

class AddMoodScreen extends StatefulWidget {
  final MoodEntry? entry;

  const AddMoodScreen({
    super.key,
    this.entry,
  });

  @override
  State<AddMoodScreen> createState() => _AddMoodScreenState();
}

class _AddMoodScreenState extends State<AddMoodScreen> {
  late int _moodScore;
  late TextEditingController _noteController;
  List<String> _selectedTags = [];

  static const _availableTags = [
    'Calm',
    'Anxious',
    'Grateful',
    'Stressed',
    'Excited',
    'Tired',
  ];

  @override
  void initState() {
    super.initState();
    _moodScore = widget.entry?.moodScore ?? 5;
    _noteController = TextEditingController(text: widget.entry?.note ?? '');
    _selectedTags = List<String>.from(widget.entry?.tags ?? []);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final provider = context.read<MoodProvider?>();
    if (provider == null) {
      return;
    }
    final now = DateTime.now();
    final isEditing = widget.entry != null;
    final id = widget.entry?.id ?? const Uuid().v4();
    final userId = widget.entry?.userId ?? '';
    final entry = MoodEntry(
      id: id,
      userId: userId,
      moodScore: _moodScore,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      tags: _selectedTags,
      createdAt: widget.entry?.createdAt ?? now,
    );
    if (isEditing) {
      await provider.updateMood(entry);
    } else {
      await provider.addMood(entry);
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String _emojiForScore(int score) {
    if (score >= 8) {
      return '😊';
    }
    if (score >= 6) {
      return '🙂';
    }
    if (score >= 4) {
      return '😐';
    }
    if (score >= 2) {
      return '😟';
    }
    return '😢';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxWidth = 600.0;
    final isEditing = widget.entry != null;
    final moodProvider = context.watch<MoodProvider?>();
    final loading = moodProvider?.isLoading ?? false;
    final error = moodProvider?.errorMessage;
    return Scaffold(
      appBar: ZenAppBar(
        title: isEditing ? 'Edit mood' : 'Add mood',
      ),
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.red,
                        Colors.orange,
                        Colors.green,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mood',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                          Text(
                            _emojiForScore(_moodScore),
                            style: const TextStyle(fontSize: 32),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ZenSlider(
                        value: _moodScore,
                        onChanged: (v) {
                          setState(() {
                            _moodScore = v;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ZenTextField(
                  controller: _noteController,
                  label: 'Note (optional)',
                  maxLines: 3,
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
                  label: isEditing ? 'Save changes' : 'Save mood',
                  onPressed: loading ? null : _save,
                  loading: loading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


