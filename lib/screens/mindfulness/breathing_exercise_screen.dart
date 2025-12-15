import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../widgets/common/zen_app_bar.dart';

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen> with SingleTickerProviderStateMixin {
  int _patternIndex = 0;
  String _phase = 'Inhale';
  int _remaining = 0;
  Timer? _timer;
  late AnimationController _controller;

  BreathingPattern get _pattern => breathingPatterns[_patternIndex];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
      lowerBound: 0.7,
      upperBound: 1.0,
    )..repeat(reverse: true);
    _startCycle();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startCycle() {
    _timer?.cancel();
    _setPhase('Inhale', _pattern.inhale);
  }

  void _setPhase(String phase, int seconds) {
    _phase = phase;
    _remaining = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remaining -= 1;
      });
      if (_remaining <= 0) {
        timer.cancel();
        if (phase == 'Inhale') {
          _setPhase('Hold', _pattern.hold);
        } else if (phase == 'Hold') {
          _setPhase('Exhale', _pattern.exhale);
        } else {
          _setPhase('Inhale', _pattern.inhale);
        }
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxWidth = 600.0;
    return Scaffold(
      appBar: const ZenAppBar(title: 'Breathing'),
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.secondary,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: size.width < maxWidth ? size.width : maxWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Follow the circle',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          final scale = _controller.value;
                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _phase,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _remaining.toString(),
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Pattern',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: List.generate(breathingPatterns.length, (index) {
                        final p = breathingPatterns[index];
                        final selected = index == _patternIndex;
                        return ChoiceChip(
                          label: Text('${p.inhale}-${p.hold}-${p.exhale}'),
                          selected: selected,
                          onSelected: (on) {
                            if (on) {
                              setState(() {
                                _patternIndex = index;
                              });
                              _startCycle();
                            }
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


