import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class PostDetailPage extends StatefulWidget {
  final int publicationId;

  const PostDetailPage({Key? key, required this.publicationId}) : super(key: key);

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  bool isLoading = true;
  Map<String, dynamic>? publicationDetails;
  final String postDetailApiUrl = 'https://focusnet-social-service-194080380757.southamerica-west1.run.app/publication/obtain_publication/';
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPublicationDetails();
  }

  Future<void> fetchPublicationDetails() async {
    try {
      final response = await http.get(Uri.parse('$postDetailApiUrl${widget.publicationId}'));
      if (response.statusCode == 200) {
        setState(() {
          publicationDetails = json.decode(response.body);
          isLoading = false;
        });
      } else {
        print("Error al obtener el detalle de la publicación: ${response.statusCode}");
      }
    } catch (e) {
      print("Error en la solicitud: $e");
    }
  }

  String _formatDate(String dateString) {
    try {
      DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, HH:mm', 'es').format(parsedDate);
    } catch (e) {
      return dateString; 
    }
  }

  Widget _buildPostImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Image.asset('assets/images/post.jpg', height: 200, width: double.infinity, fit: BoxFit.cover),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Image.network(
        imageUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset('assets/images/post.jpg', height: 200, width: double.infinity, fit: BoxFit.cover);
        },
      ),
    );
  }

  Widget _buildCommentField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: _commentController,
        decoration: InputDecoration(
          hintText: 'Escribe un comentario...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0)),
          prefixIcon: Icon(Icons.comment, color: Colors.grey),
          suffixIcon: IconButton(
            icon: Icon(Icons.send, color: Colors.blue),
            onPressed: () {
              if (_commentController.text.isNotEmpty) {
                print('Comentario enviado: ${_commentController.text}');
                _commentController.clear();  // Limpiar campo después de enviar
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('Detalle de Publicación'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : publicationDetails == null
              ? const Center(child: Text("No se encontró la publicación"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage('assets/images/profile.jpg'),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Usuario ${publicationDetails!['UserID']}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Spacer(),
                          Text(
                            _formatDate(publicationDetails!['Date']),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        publicationDetails!['ContentPubli'],
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      _buildPostImage(publicationDetails!['ImagePubli']),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(FontAwesomeIcons.comment, color: Colors.purple),
                            onPressed: () {
                              print('Mostrar comentarios');
                            },
                          ),
                          Text('${publicationDetails!['CommentCount']}'),
                          const SizedBox(width: 20),
                          IconButton(
                            icon: const Icon(FontAwesomeIcons.heart, color: Colors.purple),
                            onPressed: () {
                              print('Mostrar reacciones');
                            },
                          ),
                          Text('${publicationDetails!['ReactionCount']}'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildCommentField(),
                    ],
                  ),
                ),
    );
  }
}
