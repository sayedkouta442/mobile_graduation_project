import 'package:flutter/material.dart';
import 'package:mobile_graduation_project/login_page.dart';
import 'package:mobile_graduation_project/map_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,

        scaffoldBackgroundColor: Color(0xfff8f8fc),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xff161d38),
      ),

      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
