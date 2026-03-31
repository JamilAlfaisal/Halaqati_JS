import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class EmptyStateView extends StatelessWidget {
  final String? message;
  final IconData icon;

  const EmptyStateView({
    super.key,
    this.message,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 70,
                  ),

                  const SizedBox(height: 16),
                  Text(
                    message ?? "no_data".tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      // color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}