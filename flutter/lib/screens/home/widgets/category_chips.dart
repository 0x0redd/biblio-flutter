import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.categories,
    this.selected,
    required this.onSelected,
  });

  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('All'),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          ...categories.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(cat),
                selected: selected == cat,
                onSelected: (_) => onSelected(cat),
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
