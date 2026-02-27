import 'package:flutter/material.dart';
import 'package:teammaker/model/data_model.dart';

class StrategyOption extends StatelessWidget {
  final GenOption option;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final Widget configWidget;

  const StrategyOption({
    super.key,
    required this.option,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.configWidget,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.secondaryContainer.withValues(alpha: 0.2)
            : null,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          RadioListTile<GenOption>(
            value: option,
            activeColor: colorScheme.secondary,
            secondary:
                Icon(icon, color: isSelected ? colorScheme.secondary : null),
            title: Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
          ),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.fromLTRB(72, 0, 16, 16),
              child: configWidget,
            ),
          const Divider(height: 1, indent: 72),
        ],
      ),
    );
  }
}
