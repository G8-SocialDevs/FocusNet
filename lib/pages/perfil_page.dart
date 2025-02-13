import 'package:flutter/material.dart';
import 'package:focusnet/pages/login_page.dart';

class PerfilPage extends StatelessWidget {
  static const String routeName = '/perfil';
  final int userId;

  const PerfilPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, LoginPage.routename),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Sección de Perfil',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
