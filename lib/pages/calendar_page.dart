import 'package:flutter/material.dart';

class CalendarPage extends StatelessWidget {
  static const String routeName = '/calendar';

  const CalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
      ),
      body: const Center(
        child: Text(
          'Sección de Calendario',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
