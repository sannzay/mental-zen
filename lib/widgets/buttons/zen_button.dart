import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ZenButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool expanded;

  const ZenButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.expanded = true,
  });

  @override
  State<ZenButton> createState() => _ZenButtonState();
}

class _ZenButtonState extends State<ZenButton> with SingleTickerProviderStateMixin {
  double _scale = 1;

  void _onTapDown(TapDownDetails details) {
    if (widget.loading || widget.onPressed == null) {
      return;
    }
    setState(() {
      _scale = 0.95;
    });
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.loading || widget.onPressed == null) {
      return;
    }
    setState(() {
      _scale = 1;
    });
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1;
    });
  }

  void _onTap() {
    if (widget.loading || widget.onPressed == null) {
      return;
    }
    HapticFeedback.lightImpact();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: widget.loading ? null : _onTap,
      child: widget.loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(widget.label),
    );
    final scaled = GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 80),
        child: button,
      ),
    );
    if (!widget.expanded) {
      return scaled;
    }
    return SizedBox(
      width: double.infinity,
      child: scaled,
    );
  }
}


