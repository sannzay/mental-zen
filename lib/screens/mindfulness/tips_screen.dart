import 'package:flutter/material.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../widgets/common/zen_app_bar.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxWidth = 600.0;
    return Scaffold(
      appBar: const ZenAppBar(title: 'Wellness tips'),
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
                ...wellnessTips.map(
                  (tip) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.surface,
                    ),
                    child: Text(
                      tip,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


