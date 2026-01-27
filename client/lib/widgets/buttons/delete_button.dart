import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DeleteButton extends StatelessWidget {
  final Function onPressed;
  const DeleteButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: ()=>onPressed(),
      icon: Icon(FontAwesomeIcons.trashCan, color: Colors.red, size: 24,),
    );
  }
}
