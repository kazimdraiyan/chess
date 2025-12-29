import 'package:chess/models/board_manager.dart';
import 'package:chess/models/move.dart';
import 'package:chess/models/square.dart';
import 'package:chess/widgets/square_widget.dart';
import 'package:flutter/material.dart';

class BoardWidget extends StatefulWidget {
  final bool isWhiteToMove;
  final BoardManager boardManager;
  final void Function() updateGameWidgetAfterMakingMove;

  const BoardWidget({
    super.key,
    required this.isWhiteToMove,
    required this.boardManager,
    required this.updateGameWidgetAfterMakingMove,
  });

  @override
  State<BoardWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget> {
  Square? selectedSquare;

  // TODO: Add a switch in settings page to toggle this.
  var shouldRotateBoard =
      false; // true means the board rotates, false means the pieces rotate.
  var isBeingDragged = false;

  Move? lastMove;
  var legalMoveSquares = <Square>[];

  void setIsBeingDragged(bool isBeingDragged) {
    // TODO: Should I wrap this with setState?
    this.isBeingDragged = isBeingDragged;
  }

  void onTapSquare(Square tappedSquare) {
    if (selectedSquare == null) {
      if (isSelfPiece(tappedSquare)) {
        // Selects after verifying tapped square has a piece of the color to move
        setState(() {
          selectSquare(tappedSquare);
        });
      }
    } else {
      if (tappedSquare == selectedSquare) {
        setState(() {
          unselectSquare();
        });
      } else if (isSelfPiece(tappedSquare)) {
        // Self pieces never get highlighted
        setState(() {
          selectSquare(tappedSquare);
        });
      } else if (legalMoveSquares.contains(tappedSquare)) {
        // If there are highlighted squares, a square must be in the selected state. So selectedSquare will not be null.
        // No need to setState here, because widget.toggleWhitePerspective will call setState in the GameWidget.
        widget.boardManager.movePiece(selectedSquare!, tappedSquare);
        lastMove = widget.boardManager.lastMove;
        unselectSquare();
        widget.updateGameWidgetAfterMakingMove();
      } else {
        // Not highlighted non-self squares
        setState(() {
          unselectSquare();
        });
      }
    }
  }

  void selectSquare(Square square) {
    selectedSquare = square;
    legalMoveSquares = widget.boardManager.legalMoves(square);
  }

  void unselectSquare() {
    selectedSquare = null;
    legalMoveSquares = [];
  }

  bool isSelfPiece(Square square) {
    final piece = widget.boardManager.currentPiecePlacement.pieceAt(square);
    return piece != null && piece.isWhite == widget.isWhiteToMove;
  }

  // TODO: Solve the dragging multiple pieces simultaneously problem.
  // TODO: Add a circle on top of the square on which a piece is being dragged on.

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
      ),
      physics: NeverScrollableScrollPhysics(),
      reverse: true,
      shrinkWrap: true,
      itemCount: 64,
      itemBuilder: (context, i) {
        final isBoardRotated = shouldRotateBoard && !widget.isWhiteToMove;
        final id = isBoardRotated ? 63 - i : i;
        final square = Square.fromId(id);
        final piece = widget.boardManager.currentPiecePlacement.pieceAt(square);

        // final isAttacked = widget.boardManager
        //     .attackedSquares(widget.isWhitePerspective)
        //     .contains(square);
        final isSelected = square == selectedSquare;
        final doesBelongToLastMove =
            square == lastMove?.from || square == lastMove?.to;

        final isOccupiedByEnemyPiece = widget.boardManager
            .isOccupiedByEnemyPiece(square, widget.isWhiteToMove);

        final Color? highlightColor;
        if (isSelected || doesBelongToLastMove) {
          highlightColor = Colors.yellow.withAlpha(100);
        } else if ((lastMove?.causesCheck ?? false) &&
            widget.boardManager.currentPiecePlacement.kingSquare(
                  widget.isWhiteToMove,
                ) ==
                square) {
          // King is in check
          highlightColor = Colors.red.withAlpha(200);
        } else {
          highlightColor = null;
        }

        final isDraggable =
            !isBeingDragged && !isOccupiedByEnemyPiece && piece != null;
        final isPieceRotated = !shouldRotateBoard && !widget.isWhiteToMove;

        final showFileLabel =
            isBoardRotated ? square.rank == 8 : square.rank == 1;
        final showRankLabel =
            isBoardRotated ? square.file == 8 : square.file == 1;

        return Stack(
          children: [
            DragTarget<Square>(
              onWillAcceptWithDetails: (_) {
                return legalMoveSquares.contains(square);
              },
              onAcceptWithDetails: (_) {
                onTapSquare(square);
              },
              builder:
                  (context, _, _) => Draggable<Square>(
                    data: square,
                    maxSimultaneousDrags: isDraggable ? 1 : 0,
                    onDragStarted: () {
                      setIsBeingDragged(true);
                      onTapSquare(square);
                    },
                    onDragEnd: (_) {
                      setIsBeingDragged(false);
                    },
                    onDraggableCanceled: (_, _) => onTapSquare(square),
                    feedback: SizedBox(
                      width: 80,
                      height: 80,
                      child: PieceIconWidget(
                        piece: piece,
                        isPieceRotated: isPieceRotated,
                      ),
                    ),
                    childWhenDragging: SquareWidget(
                      square,
                      highlightColor: highlightColor,
                      isPieceRotated: isPieceRotated,
                      showFileLabel: showFileLabel,
                      showRankLabel: showRankLabel,
                      onTapSquare: onTapSquare,
                    ),
                    child: SquareWidget(
                      square,
                      piece: piece,
                      highlightColor: highlightColor,
                      isDotted:
                          legalMoveSquares.contains(square) && piece == null,
                      isCircled:
                          legalMoveSquares.contains(square) &&
                          isOccupiedByEnemyPiece,
                      isPieceRotated: isPieceRotated,
                      showFileLabel: showFileLabel,
                      showRankLabel: showRankLabel,
                      onTapSquare: onTapSquare,
                    ),
                  ),
            ),
            // if (square == draggedOnSquare)
            //   Center(
            //     child: OverflowBox(
            //       maxWidth: 85,
            //       maxHeight: 85,
            //       child: Container(
            //         decoration: BoxDecoration(
            //           color: Colors.red.withAlpha(100),
            //           shape: BoxShape.circle,
            //         ),
            //       ),
            //     ),
            //   ),
          ],
        );
      },
    );
  }
}
