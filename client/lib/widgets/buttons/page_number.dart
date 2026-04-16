import 'package:flutter/material.dart';

class PageNumber extends StatelessWidget {
  final bool selected;
  final VoidCallback onPressed;
  final int num;

  const PageNumber({
    super.key,
    required this.onPressed,
    required this.num,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: selected ? theme.colorScheme.primary : theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: selected
            ? [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ]
            : [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          splashColor: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
          highlightColor: theme.colorScheme.onPrimary.withValues(alpha: 0.1),
          child: Center(
            child: Text(
              "$num",
              style: TextStyle(
                color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}