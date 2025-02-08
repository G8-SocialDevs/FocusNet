import 'package:flutter/material.dart';

class ActivityPage extends StatelessWidget {
  static const String routeName = '/activity';

  const ActivityPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividad'),
      ),
      body: const Center(
        child: Text(
          'Sección de Actividades',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
