import 'package:chess/widgets/game_widget.dart';
import 'package:flutter/material.dart';

class PassAndPlayPage extends StatelessWidget {
  static const route = '/pass_and_play';

  const PassAndPlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pass and Play')),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: SafeArea(child: GameWidget()),
      resizeToAvoidBottomInset:
          false, // This makes sure the keyboard doesn't change the layout of the game widget.
    );
  }
}
