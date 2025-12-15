import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../config/theme.dart';
import '../../models/journal_entry.dart';
import '../../providers/journal_provider.dart';
import '../../widgets/cards/journal_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/zen_app_bar.dart';
import '../../widgets/inputs/zen_text_field.dart';
import 'add_journal_screen.dart';
import 'journal_detail_screen.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxWidth = 600.0;
    return Scaffold(
      appBar: const ZenAppBar(title: 'Journal'),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: size.width < maxWidth ? size.width : maxWidth,
            ),
            child: const _JournalContent(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddJournalScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _JournalContent extends StatefulWidget {
  const _JournalContent();

  @override
  State<_JournalContent> createState() => _JournalContentState();
}

class _JournalContentState extends State<_JournalContent> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final provider = context.read<JournalProvider?>();
    provider?.setSearchQuery(_searchController.text.trim());
  }

  void _setFilter(String value) {
    final provider = context.read<JournalProvider?>();
    setState(() {
      _filter = value;
    });
    provider?.setFavoritesOnly(value == 'favorites');
    provider?.setRecentOnly(value == 'recent');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JournalProvider?>();
    final entries = provider?.entries ?? [];
    final isLoading = provider?.isLoading ?? false;
    final error = provider?.errorMessage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ZenTextField(
          controller: _searchController,
          label: 'Search',
          hint: 'Search journal entries',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All'),
              selected: _filter == 'all',
              onSelected: (_) => _setFilter('all'),
            ),
            ChoiceChip(
              label: const Text('Favorites'),
              selected: _filter == 'favorites',
              onSelected: (_) => _setFilter('favorites'),
            ),
            ChoiceChip(
              label: const Text('Recent'),
              selected: _filter == 'recent',
              onSelected: (_) => _setFilter('recent'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isLoading)
          const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(),
            ),
          )
        else if (error != null)
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                ),
          )
        else if (entries.isEmpty)
          const EmptyState(
            icon: Icons.edit_rounded,
            title: 'No journal entries',
            message: 'Capture your thoughts and feelings in a new entry.',
          )
        else
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return JournalCard(
                entry: entry,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => JournalDetailScreen(entry: entry),
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}

