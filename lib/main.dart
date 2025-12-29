import 'package:chess/constants.dart';
import 'package:flutter/material.dart';

import 'package:chess/pages/home_page.dart';
import 'package:chess/pages/pass_and_play_page.dart';
import 'package:chess/pages/play_a_friend_page.dart';
import 'package:chess/pages/play_a_stranger_page.dart';
import 'package:chess/pages/play_a_bot_page.dart';
import 'package:chess/pages/play_local_page.dart';

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
        colorScheme: Constants.colorScheme,
        useMaterial3: true,
        fontFamily: Constants.googleFont.fontFamily,
        appBarTheme: AppBarTheme(
          backgroundColor: Constants.colorScheme.primary,
          toolbarHeight: 70,
          centerTitle: true,
          iconTheme: IconThemeData(
            size: 36,
            color: Constants.colorScheme.onPrimary,
          ),
          titleTextStyle: Constants.googleFont.copyWith(
            fontSize: 32,
            color: Constants.colorScheme.onPrimary,
          ),
        ),
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
