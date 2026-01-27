import 'package:flutter/material.dart';

class AppbarWithButton extends StatelessWidget implements PreferredSizeWidget{
  final bool addBackButton;
  final String text;
  const AppbarWithButton({super.key, required this.text, required this.addBackButton});

  @override
  Widget build(BuildContext context) {
    return addBackButton?
    AppBar(
      centerTitle: true,
      title: Text(text),
      leading: IconButton(onPressed: (){
        Navigator.pop(context);
      }, icon: Icon(Icons.arrow_back_outlined)),
    )
    :AppBar(
      centerTitle: true,
      title: Text(text),
    );

  }
  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
