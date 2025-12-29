import 'package:chess/models/move.dart';
import 'package:flutter/material.dart';

class MoveHistoryWidget extends StatelessWidget {
  final ScrollController scrollController;
  final List<Move> moveHistory;

  const MoveHistoryWidget({
    super.key,
    required this.moveHistory,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: moveHistory.isEmpty ? null : Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.only(left: 8),
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: scrollController,
        itemCount: moveHistory.length,
        itemBuilder: (context, i) {
          return Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (i % 2 == 0)
                  Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 0 : 24),
                    child: Text(
                      '${(i ~/ 2) + 1}.',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(200),
                        fontSize: 16,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: MoveChip(
                    moveHistory[i].algebraicNotation,
                    isHighlighted: i == moveHistory.length - 1,
                  ),
                ),
                if (i == moveHistory.length - 1) SizedBox(width: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}

class MoveChip extends StatelessWidget {
  final String moveAlgebraicNotation;
  final bool isHighlighted;

  const MoveChip(
    this.moveAlgebraicNotation, {
    this.isHighlighted = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            isHighlighted
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Text(
        moveAlgebraicNotation,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color:
              isHighlighted
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
