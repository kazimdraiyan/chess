import 'package:chess/models/board_manager.dart';
import 'package:chess/models/piece_placement.dart';
import 'package:chess/widgets/board_widget.dart';
import 'package:chess/widgets/move_history_widget.dart';
import 'package:flutter/material.dart';

class GameWidget extends StatefulWidget {
  const GameWidget({super.key});

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  final textEditingController = TextEditingController();
  final moveHistoryScrollController = ScrollController();

  var boardWidgetKeyValue =
      false; // This is a dummy value. It doesn't matter what it is. It's just to force the BoardWidget to reinitialize.

  var boardManager = BoardManager();

  var isWhiteToMove = true;
  var isWhitePerspective = true;

  // TODO: Optimize the dragging feature by calling setState only when and only where it's needed. We don't need to rebuild the whole GridView, if the change only affect a single square.
  // TODO: Generalize the function names so that it can describe both tapping and dragging.

  void resetToStartingPosition() {
    setState(() {
      boardManager = BoardManager();
      isWhiteToMove = true;
      isWhitePerspective = true;
      changeBoardWidgetKey();
    });
  }

  void setFen() {
    resetToStartingPosition();
    if (textEditingController.text.isNotEmpty) {
      setState(() {
        boardManager =
            BoardManager()
              ..currentPiecePlacement = PiecePlacement.fromFenPosition(
                textEditingController.text,
              );
      });
    }
  }

  /// This changes the key value to force the BoardWidget to reinitialize.
  void changeBoardWidgetKey() {
    boardWidgetKeyValue = !boardWidgetKeyValue;
  }

  void updateGameWidgetAfterMakingMove() {
    setState(() {
      isWhitePerspective = !isWhitePerspective;

      // TODO: Learn how does this work.
      // This ensures that the new move chip is added to the move history ListView before scrolling to the end.
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        moveHistoryScrollController.animateTo(
          moveHistoryScrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: TextField(
            controller: textEditingController,
            decoration: InputDecoration(
              hintText: "Set FEN",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                onPressed: resetToStartingPosition,
                child: Text('Starting'),
              ),
              OutlinedButton(onPressed: setFen, child: Text('Set')),
            ],
          ),
        ),
        MoveHistoryWidget(
          moveHistory: boardManager.moveHistory,
          scrollController: moveHistoryScrollController,
        ),
        BoardWidget(
          isWhitePerspective: isWhitePerspective,
          boardManager: boardManager,
          updateGameWidgetAfterMakingMove: updateGameWidgetAfterMakingMove,
          key: ValueKey(boardWidgetKeyValue),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: OutlinedButton(
            onPressed: () {
              print('hoit');
            },
            child: Text('Click me'),
          ),
        ),
      ],
    );
  }
}
