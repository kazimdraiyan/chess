import 'package:flutter/material.dart';

import 'package:chess/pages/home_page.dart';
import 'package:chess/pages/pass_and_play_page.dart';
import 'package:chess/pages/play_a_friend_page.dart';
import 'package:chess/pages/play_a_stranger_page.dart';
import 'package:chess/pages/play_a_bot_page.dart';
import 'package:chess/pages/play_local_page.dart';
import 'package:google_fonts/google_fonts.dart';

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
          seedColor: Colors.pink,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: GoogleFonts.alfaSlabOne().fontFamily,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
      routes: {
        PassAndPlayPage.route: (context) => const PassAndPlayPage(),
        PlayAFriendPage.route: (context) => const PlayAFriendPage(),
        PlayAStrangerPage.route: (context) => const PlayAStrangerPage(),
        PlayABotPage.route: (context) => const PlayABotPage(),
        PlayLocalPage.route: (context) => const PlayLocalPage(),
      },
    );
  }
}
