import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:focusnet/pages/login_page.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:focusnet/services/auth_service.dart';
import 'package:flutter/services.dart';

class RegisterPage extends StatefulWidget {
  static const String routename = '/register';

  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  // final AuthService _authService = AuthService();

  static const IconData currency_exchange_outlined = IconData(
    0xf05d6,
    fontFamily: 'MaterialIcons',
  );

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      String username = _nameController.text;
      String phonenumber = _phoneController.text;
      String email = _emailController.text;
      String password = _passwordController.text;

      // Aca va el código para el registro dele
      /*
      User? user = await _authService.registerWithEmailPassword(email, password);
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error en el registro')),
        );
      }
      */

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registro exitoso: Bienvenido $username')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 30, color: Color(0xFF882ACB)),
          onPressed: () {
            Navigator.pushReplacementNamed(context, LoginPage.routename);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Image.asset('assets/images/focusnet_logo.png',
                      width: 200, height: 200)),
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Registro',
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF882ACB)),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Crea una cuenta y comienza a mejorar tu productividad',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de usuario',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese un nombre de usuario';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Número de teléfono',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      maxLength: 9,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese su número de teléfono';
                        } else if (!RegExp(r'^\d{9}$').hasMatch(value)) {
                          return 'Debe contener exactamente 9 dígitos';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Correo',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese su correo electrónico';
                        } else if (!RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                            .hasMatch(value)) {
                          return 'Ingrese un correo válido';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText, // Se controla con el estado
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock), // Ícono del candado
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText
                              ? Icons.visibility_off
                              : Icons
                                  .visibility), // Cambia el icono dinámicamente
                          onPressed: () {
                            setState(() {
                              _obscureText =
                                  !_obscureText; // Alternar visibilidad
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese una contraseña';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF882ACB),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text(
                          'Crear cuenta',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    children: [
                      const TextSpan(text: '¿Ya tienes cuenta? '),
                      TextSpan(
                        text: 'Iniciar sesión',
                        style: const TextStyle(
                          color: Color(0xFF882ACB),
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
