import 'package:chess/models/move.dart';
import 'package:flutter/material.dart';

class GameResultWidget extends StatelessWidget {
  final Move lastMove;
  final void Function() onPressedRematch;
  const GameResultWidget({
    super.key,
    required this.lastMove,
    required this.onPressedRematch,
  });

  @override
  Widget build(BuildContext context) {
    final isCheckmate =
        lastMove
            .isCheckmate; // For now, we're considering stalemate if not checkmate.
    final resultText = isCheckmate ? 'Checkmate' : 'Stalemate';
    final titleText =
        isCheckmate
            ? '${lastMove.piece.isWhite ? 'White' : 'Black'} wins'
            : 'Draw';
    return AlertDialog(
      title: Text(titleText),
      content: Text('by $resultText'),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            // TODO: Make dedicated game review page?
          },
          child: Text('Game Review'),
        ),
        TextButton(onPressed: onPressedRematch, child: Text('Rematch')),
      ],
    );
  }
}
