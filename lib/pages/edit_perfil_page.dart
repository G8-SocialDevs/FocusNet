import 'package:flutter/material.dart';

class EditPerfilPage extends StatefulWidget {
  final int userId;

  const EditPerfilPage({Key? key, required this.userId}) : super(key: key);

  @override
  _EditPerfilPageState createState() => _EditPerfilPageState();
}

class _EditPerfilPageState extends State<EditPerfilPage> {
  final TextEditingController _usernameController = TextEditingController(text: 'SocialDevs');
  final TextEditingController _phoneController = TextEditingController(text: '+51987889999');
  final TextEditingController _firstNameController = TextEditingController(text: 'Rafael');
  final TextEditingController _lastNameController = TextEditingController(text: 'Laos');
  final TextEditingController _bioController = TextEditingController(text: 'Trabajo | Estudio');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 60),
            _buildTextField('Username', _usernameController),
            _buildTextField('Teléfono', _phoneController),
            _buildTextField('Nombres', _firstNameController),
            _buildTextField('Apellidos', _lastNameController),
            _buildTextField('Biografía', _bioController, maxLines: 3),
            const SizedBox(height: 20),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
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
        Positioned(
          top: 170,
          child: IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            onPressed: () {},
          ),
        ),
        Positioned(
          top: 50,
          left: 20,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const Positioned(
          top: 50,
          child: Text(
            'Editar Perfil',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _guardarCambios,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF882ACB),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text('Guardar', style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }

  void _guardarCambios() {
    if (_usernameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _bioController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa todos los campos.")),
      );
      return;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Perfil actualizado correctamente")),
    );
  }
}
