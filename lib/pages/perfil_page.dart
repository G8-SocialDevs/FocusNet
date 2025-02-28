import 'package:flutter/material.dart';
import 'package:focusnet/pages/edit_perfil_page.dart';

class PerfilPage extends StatefulWidget {
  static const String routeName = '/perfil';
  final int userId;

  const PerfilPage({Key? key, required this.userId}) : super(key: key);

  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(1),
                    bottomRight: Radius.circular(1),
                  ),
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
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPostList(),
                _buildLikedPosts(),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildPostList() {
    return ListView(
      children: [
        _buildPost(
          'assets/images/profile.jpg',
          'SocialDevs',
          'Mis hábitos de actividades',
          '4h',
          'assets/images/post.jpg',
        ),
        _buildPost(
          'assets/images/profile.jpg',
          'SocialDevs',
          'Otro post de prueba',
          '1d',
          'assets/images/post.jpg',
        ),
      ],
    );
  }

  Widget _buildLikedPosts() {
    return ListView(
      children: [
        _buildPost(
          'assets/images/profile.jpg',
          'Carlos Dev',
          'Explorando nuevas tecnologías',
          '2d',
          'assets/images/post.jpg',
        ),
        _buildPost(
          'assets/images/profile.jpg',
          'Mariana Code',
          'Consejos para aprender Flutter',
          '3d',
          'assets/images/post.jpg',
        ),
      ],
    );
  }

  Widget _buildPost(String avatar, String name, String content, String time, String postImage) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(backgroundImage: AssetImage(avatar)),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(content),
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            child: Image.asset(postImage, fit: BoxFit.cover, width: double.infinity, height: 180),
          ),
        ],
      ),
    );
  }
}
