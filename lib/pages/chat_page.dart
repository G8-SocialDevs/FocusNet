import 'package:flutter/material.dart';
import 'package:focusnet/pages/ChatDetailPage.dart';

class ChatPage extends StatefulWidget {
  static const String routeName = '/chat';
  final int userId;

  const ChatPage({Key? key, required this.userId}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _friends = [];
  List<Map<String, String>> _filteredFriends = [];
  List<Map<String, String>> _friendRequests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _friends = [
      {'name': 'Speed', 'message': 'sasasasasa', 'image': 'assets/images/profile.jpg'},
      {'name': 'Delegado', 'message': 'cdcdcdcdcdcdw', 'image': 'assets/images/profile.jpg'},
      {'name': 'Beth Williams', 'message': 'dwdwdwdwdw', 'image': 'assets/images/profile.jpg'},
      {'name': 'Rev Shawn', 'message': 'dvdvdvdvdvd', 'image': 'assets/images/profile.jpg'},
    ];

    _filteredFriends = List.from(_friends);

    _friendRequests = [
      {'name': 'Paolo', 'image': 'assets/images/profile.jpg'},
      {'name': 'Profesor IA', 'image': 'assets/images/profile.jpg'},
    ];

    _searchController.addListener(_filterFriends);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterFriends() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFriends = _friends
          .where((friend) =>
              friend['name']!.toLowerCase().contains(query) ||
              friend['message']!.toLowerCase().contains(query))
          .toList();
    });
  }

  void _openChat(String name, String image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailPage(name: name, image: image),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF882ACB),
        title: const Text('Chats', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF882ACB),
            labelColor: const Color(0xFF882ACB),
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Lista de amigos'),
              Tab(text: 'Solicitudes'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFriendList(),
                _buildFriendRequests(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendList() {
    return ListView.builder(
      itemCount: _filteredFriends.length,
      itemBuilder: (context, index) {
        final friend = _filteredFriends[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(friend['image']!),
          ),
          title: Text(friend['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(friend['message']!),
          onTap: () => _openChat(friend['name']!, friend['image']!),
        );
      },
    );
  }

  Widget _buildFriendRequests() {
    return ListView.builder(
      itemCount: _friendRequests.length,
      itemBuilder: (context, index) {
        final request = _friendRequests[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(request['image']!),
            ),
            title: Text(request['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _friends.add({'name': request['name']!, 'message': 'Nuevo amigo', 'image': request['image']!});
                      _filteredFriends = List.from(_friends);
                      _friendRequests.removeAt(index);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _friendRequests.removeAt(index);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
