import 'package:flutter/material.dart';
import 'package:focusnet/pages/home_page.dart';
import 'package:focusnet/pages/chat_page.dart';
import 'package:focusnet/pages/calendar_page.dart';
import 'package:focusnet/pages/perfil_page.dart';
import 'package:focusnet/pages/addtask_page.dart';

class MainScreen extends StatefulWidget {
  static const String routeName = '/main';
  final int initialIndex;
  final int userId;

  const MainScreen({super.key, this.initialIndex = 0, required this.userId});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pasar userId a cada página
    final List<Widget> pages = [
      HomePage(userId: widget.userId),
      ChatPage(userId: widget.userId),
      AddtaskPage(userId: widget.userId),
      CalendarPage(userId: widget.userId),
      PerfilPage(userId: widget.userId),
    ];

    return Scaffold(
      body: pages[_selectedIndex], // Se usa la lista local en lugar de _pages
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_task), label: 'Nueva Tarea'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Calendario'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: const Color(0xFF882ACB),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
