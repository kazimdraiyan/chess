import 'package:chess/pages/pass_and_play_page.dart';
import 'package:chess/pages/play_a_bot_page.dart';
import 'package:chess/pages/play_a_friend_page.dart';
import 'package:chess/pages/play_a_stranger_page.dart';
import 'package:chess/pages/play_local_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Game')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TODO: Make the buttons look better
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, PlayAStrangerPage.route);
              },
              child: Text('Play a Stranger'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, PlayAFriendPage.route);
              },
              child: Text('Play a Friend'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, PlayABotPage.route);
              },
              child: Text('Play a Bot'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, PlayLocalPage.route);
              },
              child: Text('Play Local'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, PassAndPlayPage.route);
              },
              child: Text('Pass and Play'),
            ),
          ],
        ),
      ),
    );
  }
}
