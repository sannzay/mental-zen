import 'package:flutter/material.dart';

class TagInput extends StatelessWidget {
  final List<String> availableTags;
  final List<String> selectedTags;
  final ValueChanged<List<String>> onChanged;

  const TagInput({
    super.key,
    required this.availableTags,
    required this.selectedTags,
    required this.onChanged,
  });

  void _toggleTag(String tag) {
    final tags = List<String>.from(selectedTags);
    if (tags.contains(tag)) {
      tags.remove(tag);
    } else {
      tags.add(tag);
    }
    onChanged(tags);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableTags
          .map(
            (tag) => ChoiceChip(
              label: Text(tag),
              selected: selectedTags.contains(tag),
              onSelected: (_) => _toggleTag(tag),
            ),
          )
          .toList(),
    );
  }
}


