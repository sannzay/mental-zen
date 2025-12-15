import 'package:flutter/material.dart';

class ZenSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const ZenSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.green,
            inactiveTrackColor: Colors.red.withOpacity(0.2),
            thumbColor: Colors.white,
            overlayColor: Colors.green.withOpacity(0.2),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            label: value.toString(),
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Text(
            value.toString(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}


