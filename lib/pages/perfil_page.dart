import 'package:flutter/material.dart';
import 'package:focusnet/pages/edit_perfil_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PerfilPage extends StatefulWidget {
  static const String routeName = '/perfil';
  final int userId;

  const PerfilPage({Key? key, required this.userId}) : super(key: key);

  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> userPublications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUserPublications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 🔹 Función para obtener publicaciones del usuario
  Future<void> _fetchUserPublications() async {
    final url = Uri.parse('https://focusnet-social-service-194080380757.southamerica-west1.run.app/publication/users/${widget.userId}/list_user_publications/');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          userPublications = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Error al obtener publicaciones');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF882ACB),
                ),
              ),
              Positioned(
                top: 120,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: const CircleAvatar(
                    radius: 48,
                    backgroundImage: AssetImage('assets/images/profile.jpg'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          const Text(
            'Rafael Laos',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Trabajo | Estudio',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditPerfilPage(userId: widget.userId)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF882ACB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Editar', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem(Icons.message, '2'),
              const SizedBox(width: 30),
              _buildStatItem(Icons.thumb_up, '10'),
            ],
          ),
          const SizedBox(height: 20),
          TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF882ACB),
            labelColor: const Color(0xFF882ACB),
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Mis publicaciones'),
              Tab(text: 'Likes'),
            ],
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator()) 
                : _buildPublicationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPublicationsList() {
  if (userPublications.isEmpty) {
    return const Center(child: Text("No hay publicaciones."));
  }

  return ListView.builder(
    itemCount: userPublications.length,
    itemBuilder: (context, index) {
      final publication = userPublications[index];
      final String? imageUrl = publication['ImagePubli'];

      // Imagen para la publicación (más grande)
      final Widget imageWidget = (imageUrl != null && imageUrl.isNotEmpty)
          ? Image.network(
              imageUrl,
              width: double.infinity, // Ocupa todo el ancho
              height: 200, // Tamaño ajustado
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/post.jpg',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            )
          : Image.asset('assets/images/post.jpg', width: double.infinity, height: 200, fit: BoxFit.cover);

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: GestureDetector(
          onTap: () {
            // Acciones al hacer clic en la publicación
            print('Publicación clickeada');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  publication['ContentPubli'] ?? "Sin título",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              imageWidget, // Imagen
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.thumb_up, color: const Color(0xFF882ACB), size: 18),
                    const SizedBox(width: 8),
                    Text("${publication['ReactionCount']} Likes"),
                    const Spacer(),
                    Icon(Icons.comment, color: const Color(0xFF882ACB), size: 18),
                    const SizedBox(width: 8),
                    Text("${publication['CommentCount']} Comentarios"),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    },
  );
}

  Widget _buildStatItem(IconData icon, String count) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF882ACB), size: 28),
        Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
