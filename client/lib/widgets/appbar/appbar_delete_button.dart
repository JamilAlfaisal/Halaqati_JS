import 'package:flutter/material.dart';

class AppbarDeleteButton extends StatelessWidget implements PreferredSizeWidget{
  final bool addBackButton;
  final String text;
  final VoidCallback onPress;
  const AppbarDeleteButton({
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
      leading: IconButton(onPressed: (){
        Navigator.pop(context);
      }, icon: Icon(Icons.arrow_back_outlined)),
      actions: [
        IconButton(onPressed: onPress, icon: Icon(Icons.delete_outline))
      ],
    )
        :AppBar(
      centerTitle: true,
      title: Text(text),
      actions: [
        IconButton(onPressed: onPress, icon: Icon(Icons.delete_outline))
      ],
    );

  }
  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
