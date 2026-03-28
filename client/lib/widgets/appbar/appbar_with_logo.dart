import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AppbarWithLogo extends StatelessWidget implements PreferredSizeWidget {
  final String text;
  final VoidCallback? onLogout;

  const AppbarWithLogo({
    super.key,
    required this.text,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.locale.languageCode == 'en';

    return AppBar(
      leading: Padding(
        padding: isEnglish
            ? const EdgeInsets.fromLTRB(5, 0, 0, 0)
            : const EdgeInsets.fromLTRB(0, 0, 5, 0),
        child: Image.asset('assets/images/alhamidi_logo.png'),
      ),
      centerTitle: true,
      title: Text(text),

      /// Logout button (optional)
      actions: [
        if (onLogout != null)
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: onLogout,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}