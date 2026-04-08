import 'package:flutter/material.dart';

class AppbarWithActionList extends StatelessWidget implements PreferredSizeWidget {
  final bool addBackButton;
  final List<Widget> actionList;
  final String text;

  const AppbarWithActionList({
    super.key,
    required this.text,
    required this.addBackButton,
    required this.actionList,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(text),
      // Simplified leading logic
      leading: addBackButton
          ? IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_outlined),
      )
          : null,
      actions: [
        // Only show the menu if there are actions available
        if (actionList.isNotEmpty)
          PopupMenuButton<Widget>(
            icon: const Icon(Icons.more_vert), // The "three dots" icon
            itemBuilder: (context) => actionList
                .map(
                  (widget) => PopupMenuItem<Widget>(
                enabled: false, // Set to false so the child widget (e.g., TextButton) handles the click
                child: widget,
              ),
            )
                .toList(),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}