import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class GradeCardSelector extends StatelessWidget {
  final int selectedCard;
  final ValueChanged<int> onChanged;

  const GradeCardSelector({
    super.key,
    required this.selectedCard,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'select_card'.tr(),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _CardOption(
                value: 3,
                label: 'card_perfect'.tr(),
                icon: Icons.star_rounded,
                isSelected: selectedCard == 3,
                onTap: () => onChanged(3),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _CardOption(
                value: 2,
                label: 'card_very_good'.tr(),
                icon: Icons.thumb_up_rounded,
                isSelected: selectedCard == 2,
                onTap: () => onChanged(2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _CardOption(
                value: 1,
                label: 'card_good'.tr(),
                icon: Icons.check_circle_rounded,
                isSelected: selectedCard == 1,
                onTap: () => onChanged(1),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _CardOption(
                value: 0,
                label: 'card_none'.tr(),
                icon: Icons.remove_circle_outline_rounded,
                isSelected: selectedCard == 0,
                onTap: () => onChanged(0),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CardOption extends StatelessWidget {
  final int value;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CardOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : secondaryColor.withOpacity(0.5),
            width: isSelected ? 2.0 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: isSelected ? primaryColor : secondaryColor,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? primaryColor : secondaryColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
