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
      body: GameWidget(),
      resizeToAvoidBottomInset: false, // TODO: What does it do?
    );
  }
}
