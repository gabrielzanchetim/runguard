import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Jura', // Certifique-se de que a fonte 'Jura' está carregada no projeto
          fontSize: 28.0,
          fontWeight: FontWeight.w500,
        ),
      ),
      centerTitle: true, // Centraliza o título
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
