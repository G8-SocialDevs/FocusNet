import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:focusnet/pages/PostDetailPage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; 
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
  File? _image;
  final picker = ImagePicker();

  final String getApiUrl =
      "https://focusnet-social-service-194080380757.southamerica-west1.run.app/publication/list_publications/";

  final String postApiUrlBase =
      "https://focusnet-social-service-194080380757.southamerica-west1.run.app/publication/users/";

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

  Future<void> createPublication(String content) async {
    if (_image == null) {
      print("Por favor, selecciona una imagen.");
      return;
    }

    String? imageUrl = await uploadImageToFirebase(_image!);
    if (imageUrl == null) {
      print("Error al obtener la URL de la imagen.");
      return;
    }

    final String fullPostApiUrl = "$postApiUrlBase${widget.userId}/create_publication/";

    try {
      final response = await http.post(
        Uri.parse(fullPostApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "UserID": widget.userId,
          "ContentPubli": content,
          "ImagePubli": imageUrl,
          "Date": DateTime.now().toIso8601String(),
          "CommentCount": 0,
          "ReactionCount": 0
        }),
      );

      if (response.statusCode == 200) {
        print("Publicación creada con éxito");
        fetchPublications();
        setState(() {
          _image = null;
        });
      } else {
        print("Error al crear publicación: ${response.body}");
      }
    } catch (e) {
      print("Error en la solicitud: $e");
    }
  }

  Future<String?> uploadImageToFirebase(File imageFile) async {
    try {
      String fileName = "publications/${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print("Error al subir imagen: $e");
      return null;
    }
  }

  Future<void> toggleLike(int publicationId, int currentReactionCount, bool isLiked) async {
    final String likeApiUrl =
        "https://focusnet-social-service-194080380757.southamerica-west1.run.app/reaction/users/${widget.userId}/publications/$publicationId/reactions/";

    try {
      if (isLiked) {
        final deleteResponse = await http.delete(
          Uri.parse(likeApiUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "UserID": widget.userId,
            "PublicationID": publicationId,
            "ReactionID": DateTime.now().millisecondsSinceEpoch,
          }),
        );

        if (deleteResponse.statusCode == 200) {
          print("Reacción eliminada con éxito");
          setState(() {
            currentReactionCount--;
          });
          fetchPublications();
        } else {
          print("Error al eliminar la reacción: ${deleteResponse.body}");
        }
      } else {
        final postResponse = await http.post(
          Uri.parse(likeApiUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "UserID": widget.userId,
            "PublicationID": publicationId,
            "ReactionID": DateTime.now().millisecondsSinceEpoch,
          }),
        );

        if (postResponse.statusCode == 200) {
          print("Reacción agregada con éxito");
          setState(() {
            currentReactionCount++;
          });
          fetchPublications();
        } else {
          print("Error al agregar la reacción: ${postResponse.body}");
        }
      }
    } catch (e) {
      print("Error en la solicitud: $e");
    }
  }

  // Función para formatear la fecha
  String formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      final DateFormat formatter = DateFormat('dd MMM yyyy, HH:mm');
      return formatter.format(date);
    } catch (e) {
      print("Error al formatear la fecha: $e");
      return dateString; // Si hay un error, devolvemos la fecha original
    }
  }

  void _showCreatePostDialog() {
    TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Crear Publicación',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: contentController,
                      decoration: const InputDecoration(hintText: 'Escribe tu publicación...'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    _image != null
                        ? Image.file(_image!, height: 150)
                        : const Text("No se ha seleccionado una imagen"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                            if (pickedFile != null) {
                              setState(() {
                                _image = File(pickedFile.path);
                              });
                            }
                          },
                          icon: const Icon(Icons.image),
                          label: const Text("Galería"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final pickedFile = await picker.pickImage(source: ImageSource.camera);
                            if (pickedFile != null) {
                              setState(() {
                                _image = File(pickedFile.path);
                              });
                            }
                          },
                          icon: const Icon(Icons.camera),
                          label: const Text("Cámara"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                      onPressed: () {
                        if (contentController.text.isNotEmpty) {
                          createPublication(contentController.text);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Publicar', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      setState(() {
        _image = null;
      });
    });
  }

  @override

Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Publicaciones')),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : publications.isEmpty
            ? const Center(child: Text("No hay publicaciones disponibles"))
            : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: publications.length,
                itemBuilder: (context, index) {
                  var post = publications[index];
                  bool isLiked = post['isLiked'] ?? false;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PostDetailPage(publicationId: post['PublicationID']),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: const CircleAvatar(
                              backgroundImage: AssetImage('assets/images/profile.jpg'),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  'Usuario ${post['UserID']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(), // Esto empuja la fecha a la derecha
                                Text(
                                  formatDate(post['Date']),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(post['ContentPubli']),
                          ),
                          _buildPostImage(post['ImagePubli']),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.comment, color: Color(0xFF882ACB)),
                                  onPressed: () {
                                    print("Comentar en la publicación");
                                  },
                                ),
                                Text('${post['CommentCount']}'),
                                const SizedBox(width: 20),
                                IconButton(
                                  icon: Icon(
                                    Icons.thumb_up,
                                    color: isLiked ? Colors.blue : Color(0xFF882ACB),
                                  ),
                                  onPressed: () {
                                    toggleLike(post['PublicationID'], post['ReactionCount'], isLiked);
                                  },
                                ),
                                Text('${post['ReactionCount']}'),
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
      backgroundColor: Colors.green,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text('Publicar', style: TextStyle(color: Colors.white)),
      onPressed: _showCreatePostDialog,
    ),
  );
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
}
