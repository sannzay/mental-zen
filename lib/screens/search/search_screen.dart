import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/journal_entry.dart';
import '../../providers/journal_provider.dart';
import '../../widgets/cards/journal_card.dart';
import '../../widgets/common/zen_app_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _recent = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final provider = context.read<JournalProvider?>();
    provider?.setSearchQuery(_controller.text.trim());
  }

  void _submit(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return;
    }
    setState(() {
      _recent.remove(trimmed);
      _recent.insert(0, trimmed);
      if (_recent.length > 5) {
        _recent.removeLast();
      }
    });
    _onSearchChanged();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JournalProvider?>();
    final entries = provider?.entries ?? [];
    final size = MediaQuery.of(context).size;
    final maxWidth = 600.0;
    return Scaffold(
      appBar: const ZenAppBar(title: 'Search journal'),
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
                TextField(
                  controller: _controller,
                  onChanged: (_) => _onSearchChanged(),
                  onSubmitted: _submit,
                  decoration: const InputDecoration(
                    labelText: 'Search entries',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                if (_recent.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Recent searches',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: _recent
                        .map(
                          (q) => ActionChip(
                            label: Text(q),
                            onPressed: () {
                              _controller.text = q;
                              _onSearchChanged();
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 16),
                if (entries.isEmpty)
                  Text(
                    'No matching entries.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _HighlightedJournalCard(
                        entry: entry,
                        query: _controller.text.trim(),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HighlightedJournalCard extends StatelessWidget {
  final JournalEntry entry;
  final String query;

  const _HighlightedJournalCard({
    required this.entry,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return JournalCard(entry: entry, onTap: () {});
    }
    final lower = entry.content.toLowerCase();
    final q = query.toLowerCase();
    final index = lower.indexOf(q);
    String before = entry.content;
    String match = '';
    String after = '';
    if (index >= 0) {
      before = entry.content.substring(0, index);
      match = entry.content.substring(index, index + q.length);
      after = entry.content.substring(index + q.length);
    }
    return JournalCard(
      entry: JournalEntry(
        id: entry.id,
        userId: entry.userId,
        title: entry.title,
        content: before + match + after,
        moodScore: entry.moodScore,
        tags: entry.tags,
        isFavorite: entry.isFavorite,
        createdAt: entry.createdAt,
        updatedAt: entry.updatedAt,
      ),
      onTap: () {},
    );
  }
}


