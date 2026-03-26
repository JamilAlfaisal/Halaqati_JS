import 'package:flutter/material.dart';

class AppbarRemoveStudent extends StatelessWidget implements PreferredSizeWidget{
  final bool addBackButton;
  final String text;
  final VoidCallback onPress;
  const AppbarRemoveStudent({
    super.key,
    required this.text,
    required this.addBackButton,
    required this.onPress
  });

  @override
  Widget build(BuildContext context) {
    return addBackButton?
    AppBar(
      centerTitle: true,
      title: Text(text),
      leading: IconButton(
        onPressed: (){
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back_outlined)
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_remove_alt_1, color: Colors.red),
          onPressed:onPress
        )
      ],
    )
        :AppBar(
      centerTitle: true,
      title: Text(text),
      actions: [
        IconButton(
            icon: const Icon(Icons.person_remove_alt_1, color: Colors.red),
            onPressed:onPress
        )
      ],
    );

  }
  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
