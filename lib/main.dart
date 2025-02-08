import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:social_devs/pages/activity_page.dart';
import 'package:social_devs/pages/calendar_page.dart';
import 'package:social_devs/pages/chat_page.dart';
import 'package:social_devs/pages/login_page.dart';
import 'package:social_devs/pages/perfil_page.dart';
import 'package:social_devs/pages/register_page.dart';
import 'package:social_devs/pages/addtask_page.dart';
import 'package:social_devs/pages/home_page.dart';

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
      routes: {
        // WelcomePage.routename: (context) => const WelcomePage(),
        HomePage.routeName: (context) => const HomePage(),
        LoginPage.routename: (context) => const LoginPage(),
        RegisterPage.routename: (context) => const RegisterPage(),
        AddtaskPage.routename: (context) => const AddtaskPage(),
        ActivityPage.routeName: (context) => const ActivityPage(),
        ChatPage.routeName: (context) => const ChatPage(),
        CalendarPage.routeName: (context) => const CalendarPage(),
        PerfilPage.routeName: (context) => const PerfilPage(),
        // '/main': (context) => const MainScreen(),
        // '/home': (context) => const HomePage(),
      },
    );
  }
}
