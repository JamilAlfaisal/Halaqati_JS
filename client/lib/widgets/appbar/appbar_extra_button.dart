import 'package:flutter/material.dart';

class AppbarExtraButton extends StatelessWidget implements PreferredSizeWidget{
  final bool addBackButton;
  final Icon icon;
  final String text;
  final VoidCallback onPress;
  const AppbarExtraButton({
    super.key,
    required this.text,
    required this.addBackButton,
    required this.onPress,
    required this.icon
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
          }, icon: Icon(Icons.arrow_back_outlined)),
      actions: [
        IconButton(
          onPressed: onPress,
          icon: icon
        )
      ],
    )
        :AppBar(
      centerTitle: true,
      title: Text(text),
      actions: [
        IconButton(
          onPressed: onPress,
          icon: icon
        )
      ],
    );

  }
  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
