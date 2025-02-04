import 'package:flutter/material.dart';
import 'package:focusnet/pages/login_page.dart';
import 'package:focusnet/pages/register_page.dart';
import 'package:focusnet/pages/addtask_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();

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
        LoginPage.routename: (context) => const LoginPage(),
        RegisterPage.routename: (context) => const RegisterPage(),
        AddtaskPage.routename: (context) => const AddtaskPage(),
        // '/main': (context) => const MainScreen(),
        // '/home': (context) => const HomePage(),
      },
    );
  }
}
