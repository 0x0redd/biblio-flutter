import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import 'custom_button.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon = Icons.menu_book_outlined,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              CustomButton(
                label: actionLabel!,
                onPressed: onAction,
                outlined: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
