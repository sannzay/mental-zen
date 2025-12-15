import 'package:flutter/material.dart';

class ZenOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool expanded;

  const ZenOutlineButton({
    super.key,
    required this.label,
    this.onPressed,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onPressed,
      child: Text(label),
    );
    if (!expanded) {
      return button;
    }
    return SizedBox(
      width: double.infinity,
      child: button,
    );
  }
}


