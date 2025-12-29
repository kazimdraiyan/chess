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
      appBar: AppBar(
        title: Text(
          'New Game',
          style: TextStyle(
            fontSize: 32,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        toolbarHeight: 70,
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(25),
              ),
            ),
            SizedBox(height: 4),
            PlayModeTile(
              title: 'Play a Stranger',
              icon: Icons.person_search,
              onTap: () {
                Navigator.pushNamed(context, PlayAStrangerPage.route);
              },
            ),
            SizedBox(height: 4),
            PlayModeTile(
              title: 'Play a Friend',
              icon: Icons.face_5,
              onTap: () {
                Navigator.pushNamed(context, PlayAFriendPage.route);
              },
            ),
            SizedBox(height: 4),
            PlayModeTile(
              title: 'Play a Bot',
              icon: Icons.smart_toy_sharp,
              onTap: () {
                Navigator.pushNamed(context, PlayABotPage.route);
              },
            ),
            SizedBox(height: 4),
            PlayModeTile(
              title: 'Play Local',
              icon: Icons.bluetooth,
              onTap: () {
                Navigator.pushNamed(context, PlayLocalPage.route);
              },
            ),
            SizedBox(height: 4),
            PlayModeTile(
              title: 'Pass and Play',
              icon: Icons.computer,
              onTap: () {
                Navigator.pushNamed(context, PassAndPlayPage.route);
              },
            ),
            SizedBox(height: 4),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlayModeTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const PlayModeTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 28)),
      leading: Icon(icon, size: 48),
      onTap: onTap,
      iconColor: Theme.of(context).colorScheme.primary,
      textColor: Theme.of(context).colorScheme.primary,
      splashColor: Theme.of(context).colorScheme.primary.withAlpha(60),
      tileColor: Theme.of(context).colorScheme.onSurface.withAlpha(25),
      minTileHeight: 80,
    );
  }
}
