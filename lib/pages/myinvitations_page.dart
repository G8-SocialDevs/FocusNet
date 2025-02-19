import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MyinvitationsPage extends StatefulWidget {
  static const String routeName = '/myinvitations';
  final int userId;

  const MyinvitationsPage({super.key, required this.userId});

  @override
  _MyinvitationsPageState createState() => _MyinvitationsPageState();
}

class _MyinvitationsPageState extends State<MyinvitationsPage> {
  int selectedIndex = 0; // 0: Recibidos, 1: Pendientes

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SafeArea(
          child: Stack(
            children: [
              // Título centrado
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                color: Color(0xFF882ACB),
                child: const Center(
                  child: Text(
                    "Mis invitaciones",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Botón de retroceso alineado a la izquierda
              Positioned(
                left: 10, // Ajusta la posición izquierda
                top: 10, // Ajusta la posición superior
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
        // MenuBar con "Recibidos" y "Pendientes"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMenuItem("Recibidos", 0),
            _buildMenuItem("Pendientes", 1),
          ],
        ),
        // Contenido dinámico según la opción seleccionada
        Expanded(
          child: selectedIndex == 0 ? _recibidosView() : _pendientesView(),
        ),
      ],
    ));
  }

  Widget _buildMenuItem(String title, int index) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Color(0xFF882ACB) : Colors.black,
            ),
          ),
          SizedBox(height: 4),
          Container(
            width: 80,
            height: 3,
            color: isSelected ? Color(0xFF882ACB) : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _recibidosView() {
    return Center(
      child: Text(
        "Contenido de Recibidos",
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _pendientesView() {
    return Center(
      child: Text(
        "Contenido de Pendientes",
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
