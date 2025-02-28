import 'package:flutter/material.dart';
import 'package:focusnet/pages/comment_dialog.dart';

class PostDetailPage extends StatelessWidget {
  final String username;
  final String profileImage;
  final String time;
  final String postText;
  final String postImage;

  const PostDetailPage({
    Key? key,
    required this.username,
    required this.profileImage,
    required this.time,
    required this.postText,
    required this.postImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF882ACB),
        title: const Text('Publicación', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(profileImage),
                  ),
                  title: Text(
                    username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(time),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(postText),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _buildPostImage(postImage),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline, color: Colors.purple),
                        onPressed: () {
                          showCommentDialog(context);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.thumb_up_alt_outlined, color: Colors.purple),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: AssetImage('assets/images/profile.jpg'),
                    ),
                    title: const Text('Speed', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text(
                      '"¡Organización es clave! Tener un plan claro para las tareas universitarias ayuda a evitar el estrés y mejorar el rendimiento.',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Image.asset(
        'assets/images/post.jpg',
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    Uri? uri = Uri.tryParse(imageUrl);
    if (uri != null && uri.hasScheme && (uri.scheme == "http" || uri.scheme == "https")) {
      return Image.network(
        imageUrl,
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
      );
    } else {
      return Image.asset(
        'assets/images/post.jpg',
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
  }
}
