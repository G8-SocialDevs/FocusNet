import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:focusnet/pages/calendar_page.dart';
import 'package:focusnet/pages/chat_page.dart';
import 'package:focusnet/pages/login_page.dart';
import 'package:focusnet/pages/perfil_page.dart';
import 'package:focusnet/pages/register_page.dart';
import 'package:focusnet/pages/addtask_page.dart';
import 'package:focusnet/pages/home_page.dart';
import 'package:focusnet/pages/mainScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FocusNet',
      initialRoute: LoginPage.routename,
      onGenerateRoute: (settings) {
        final args = settings.arguments
            as Map<String, dynamic>?; // Extraemos los argumentos generales
        final int userId =
            args?['userId'] ?? 0; // Si no se proporciona, asignamos 0

        switch (settings.name) {
          case HomePage.routeName:
            return MaterialPageRoute(
              builder: (context) => HomePage(userId: userId),
            );

          case MainScreen.routeName:
            return MaterialPageRoute(
              builder: (context) => MainScreen(
                userId: userId,
                initialIndex: args?['initialIndex'] ?? 0,
              ),
            );

          case AddtaskPage.routename:
            return MaterialPageRoute(
              builder: (context) => AddtaskPage(userId: userId),
            );

          case CalendarPage.routeName:
            return MaterialPageRoute(
              builder: (context) => CalendarPage(userId: userId),
            );

          case PerfilPage.routeName:
            return MaterialPageRoute(
              builder: (context) => PerfilPage(userId: userId),
            );

          case ChatPage.routeName:
            return MaterialPageRoute(
              builder: (context) => ChatPage(userId: userId),
            );

          case LoginPage.routename:
            return MaterialPageRoute(builder: (context) => const LoginPage());

          case RegisterPage.routename:
            return MaterialPageRoute(
                builder: (context) => const RegisterPage());

          default:
            return MaterialPageRoute(builder: (context) => const LoginPage());
        }
      },
    );
  }
}
