import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:focusnet/pages/CustomAppBar.dart';
import 'package:focusnet/pages/PostDetailPage.dart';
import 'package:focusnet/pages/comment_dialog.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/home';
  final int userId;

  const HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> publications = [];
  bool isLoading = true;

  final String getApiUrl =
      "https://focusnet-social-service-194080380757.southamerica-west1.run.app/publication/get_publications/";
  final String postApiUrl =
      "https://focusnet-social-service-194080380757.southamerica-west1.run.app/publication/users/{userId}/create_publication/";

  @override
  void initState() {
    super.initState();
    fetchPublications();
  }

  Future<void> fetchPublications() async {
    try {
      final response = await http.get(Uri.parse(getApiUrl));
      if (response.statusCode == 200) {
        setState(() {
          publications = json.decode(response.body);
          isLoading = false;
        });
      } else {
        print("Error al obtener publicaciones: ${response.statusCode}");
      }
    } catch (e) {
      print("Error en la solicitud: $e");
    }
  }

  Future<void> createPublication(String content, String imageUrl) async {
    final String fullPostApiUrl =
        "https://focusnet-social-service-194080380757.southamerica-west1.run.app/publication/users/${widget.userId}/create_publication/";

    try {
      final response = await http.post(
        Uri.parse(fullPostApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "UserID": widget.userId,
          "ContentPubli": content,
          "ImagePubli": imageUrl.isNotEmpty ? imageUrl : null,
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Publicación creada con éxito");
        fetchPublications();
        setState(() {}); // Refrescar la pantalla
      } else {
        print("❌ Error al crear publicación: ${response.body}");
      }
    } catch (e) {
      print("❌ Error en la solicitud: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        titleWidget: Text(
          'Publicaciones',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : publications.isEmpty
              ? const Center(child: Text("No hay publicaciones disponibles"))
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: publications.length,
                  itemBuilder: (context, index) {
                    var post = publications[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailPage(
                              username: 'Usuario ${post['UserID']}',
                              profileImage: 'assets/images/profile.jpg',
                              time: post['Date'],
                              postText: post['ContentPubli'],
                              postImage: post['ImagePubli'],
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: const CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/images/profile.jpg'),
                              ),
                              title: Text(
                                'Usuario ${post['UserID']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(post['Date']),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text(post['ContentPubli']),
                            ),
                            _buildPostImage(post['ImagePubli']),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chat_bubble_outline,
                                        color: Colors.purple),
                                    onPressed: () {
                                      showCommentDialog(context);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.thumb_up_alt_outlined,
                                        color: Colors.purple),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text('Publicar', style: TextStyle(color: Colors.white)),
        onPressed: () {
          _showCreatePostDialog();
        },
      ),
    );
  }

  void _showCreatePostDialog() {
    TextEditingController contentController = TextEditingController();
    TextEditingController imageUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40), // Espacio para centrar el título
                  const Text(
                    'Crear Publicación',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  hintText: 'Escribe tu publicación...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  hintText: 'URL de la imagen (opcional)',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
                onPressed: () {
                  if (contentController.text.isNotEmpty) {
                    createPublication(
                        contentController.text, imageUrlController.text);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Publicar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostImage(String? imageUrl) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Image.network(
        imageUrl ?? '',
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/post.jpg',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}
