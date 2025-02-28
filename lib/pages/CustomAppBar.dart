import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget titleWidget;
  final bool showBackButton; // Nueva opción para mostrar la flecha

  const CustomAppBar({Key? key, required this.titleWidget, this.showBackButton = false})
      : super(key: key);

  @override

  Widget build(BuildContext context) {
    return AppBar(
      title: Center(
        child: DefaultTextStyle.merge(
          style: const TextStyle(color: Colors.white),
          child: titleWidget,
        ),
      ),
      backgroundColor: const Color(0xFF882ACB),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white), // Asegura que los iconos sean blancos
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            )
          : null, // Si `showBackButton` es false, no muestra la flecha
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'logout') {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.exit_to_app, color: Color(0xFF20344C)),
                  SizedBox(width: 8),
                  Text('Cerrar sesión'),
                ],
              ),
            ),
          ],
          icon: const Icon(Icons.more_vert, color: Colors.white),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
