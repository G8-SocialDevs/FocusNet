import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  static const String routeName = '/chat';
  final int userId;

  const ChatPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: const Center(
        child: Text(
          'Sección de Chats',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
