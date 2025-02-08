import 'package:flutter/material.dart';
import 'package:social_devs/pages/home_page.dart';
import 'package:social_devs/pages/chat_page.dart';
import 'package:social_devs/pages/calendar_page.dart';
import 'package:social_devs/pages/perfil_page.dart';
import 'package:social_devs/pages/addtask_page.dart';

class MainScreen extends StatefulWidget {
  static const String routeName = '/main';
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  final List<Widget> _pages = [
    const HomePage(),
    const ChatPage(),
    const AddtaskPage(),  
    const CalendarPage(),
    const PerfilPage(),
  ];

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
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.add_task), label: 'Nueva Tarea'), 
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendario'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Color(0xFF882ACB),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
