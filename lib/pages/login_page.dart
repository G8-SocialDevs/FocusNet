import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:focusnet/services/auth_service.dart';
import 'package:focusnet/pages/register_page.dart';

import 'package:focusnet/pages/addtask_page.dart';

class LoginPage extends StatefulWidget {
  static const String routename = '/login';

  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // final AuthService _authService = AuthService();

  static const IconData currency_exchange_outlined = IconData(
    0xf05d6,
    fontFamily: 'MaterialIcons',
  );

  Future<void> _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    // User? user = await _authService.signInWithEmailPassword(email, password);
    /*
   if (user != null) {
      Navigator.pushReplacementNamed(context, '/main'); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de autenticación')),
      );
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text(
                'TRADEGENIUS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF20344C),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFF20344C),
                child: Icon(
                  currency_exchange_outlined,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  const Text(
                    'Inicio de sesión',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Ingresa tus datos y comienza a invertir de manera inteligente',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, AddtaskPage.routename);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF20344C),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                      context, RegisterPage.routename);
                },
                child: const Text('Registrarse'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
