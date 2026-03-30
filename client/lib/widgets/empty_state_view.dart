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
          physics: const AlwaysScrollableScrollPhysics(), // 🔥 allows pull-to-refresh
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// 🔹 Icon
                  Icon(
                    icon,
                    size: 70,
                    // color: Colors.grey[400],
                  ),

                  const SizedBox(height: 16),

                  /// 🔹 Message
                  Text(
                    message ?? "No data available",
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