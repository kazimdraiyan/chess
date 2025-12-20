import 'package:chess/pages/home_page.dart';
import 'package:chess/pages/pass_and_play_page.dart';
import 'package:chess/pages/play_a_bot_page.dart';
import 'package:chess/pages/play_a_friend_page.dart';
import 'package:chess/pages/play_a_stranger_page.dart';
import 'package:chess/pages/play_local_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
      routes: {
        PlayAStrangerPage.route: (context) => const PlayAStrangerPage(),
        PlayAFriendPage.route: (context) => const PlayAFriendPage(),
        PlayABotPage.route: (context) => const PlayABotPage(),
        PlayLocalPage.route: (context) => const PlayLocalPage(),
        PassAndPlayPage.route: (context) => const PassAndPlayPage(),
      },
    );
  }
}
