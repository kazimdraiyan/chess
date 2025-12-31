import 'dart:math' show pi;

import 'package:chess/models/board_manager.dart';
import 'package:chess/models/move.dart';
import 'package:chess/models/piece.dart';
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
  Square?
  tappedSquare; // TODO: Use this global variable instead of parameter passing everywhere

  // TODO: Add a switch in settings page to toggle this.
  var shouldRotateBoard =
      false; // true means the board rotates, false means the pieces rotate.
  var isBeingDragged = false;
  var isPromotionDialogOpen = false;

  Move? lastMove;
  var legalMoveSquares = <Square>[];

  void setIsBeingDragged(bool isBeingDragged) {
    // TODO: Should I wrap this with setState?
    this.isBeingDragged = isBeingDragged;
  }

  // TODO: Clean this method.
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
        if (widget.boardManager.isPromotionMove(
          selectedSquare!,
          tappedSquare,
        )) {
          // Show promotion dialog
          setState(() {
            this.tappedSquare = tappedSquare;
            isPromotionDialogOpen = true;
          });
        } else {
          // Normal move
          widget.boardManager.movePiece(
            selectedSquare!,
            tappedSquare,
            promotedToPieceType: null,
            isEnPassantMove: tappedSquare.isEnPassantTargetSquare,
          );
          lastMove = widget.boardManager.lastMove;
          unselectSquare();
          widget.updateGameWidgetAfterMakingMove();
        }
      } else {
        // Not highlighted non-self squares
        setState(() {
          unselectSquare();
        });
      }
    }
  }

  void onTapPromotionOption(PieceType promotedToPieceType) {
    // Make promotion move
    widget.boardManager.movePiece(
      selectedSquare!,
      tappedSquare!,
      promotedToPieceType: promotedToPieceType,
    );
    lastMove = widget.boardManager.lastMove;
    unselectSquare();
    widget.updateGameWidgetAfterMakingMove();
    isPromotionDialogOpen = false;
    tappedSquare = null;
  }

  void onPromotionDialogCancel() {
    setState(() {
      isPromotionDialogOpen = false;
      tappedSquare = null;
      unselectSquare();
    });
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
    return Stack(
      children: [
        GridView.builder(
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

            var square = Square.fromId(id);
            final isEnPassantTargetSquare =
                legalMoveSquares
                    .firstWhere(
                      (legalMoveSquare) => square == legalMoveSquare,
                      orElse:
                          () => Square(0, 0, isEnPassantTargetSquare: false),
                    )
                    .isEnPassantTargetSquare; // Square(0, 0) is a dummy square that is impossible to be on a board.
            square = Square(
              square.file,
              square.rank,
              isEnPassantTargetSquare: isEnPassantTargetSquare,
            ); // Now the isEnPassantTargetSquare information is stored in the square object.

            final piece = widget.boardManager.currentPiecePlacement.pieceAt(
              square,
            );

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
                          square: square,
                          highlightColor: highlightColor,
                          isPieceRotated: isPieceRotated,
                          showFileLabel: showFileLabel,
                          showRankLabel: showRankLabel,
                          onTap: () => onTapSquare(square),
                        ),
                        child: SquareWidget(
                          square: square,
                          piece: piece,
                          highlightColor: highlightColor,
                          isDotted:
                              !isEnPassantTargetSquare &&
                              (legalMoveSquares.contains(square) &&
                                  piece == null),
                          isCircled:
                              isEnPassantTargetSquare ||
                              (legalMoveSquares.contains(square) &&
                                  isOccupiedByEnemyPiece),
                          isPieceRotated: isPieceRotated,
                          showFileLabel: showFileLabel,
                          showRankLabel: showRankLabel,
                          onTap: () => onTapSquare(square),
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
        ),
        if (isPromotionDialogOpen) DarkScrim(onTap: onPromotionDialogCancel),
        if (isPromotionDialogOpen)
          PromotionDialog(
            file: tappedSquare!.file,
            isAtBottom: !shouldRotateBoard && !widget.isWhiteToMove,
            isBoardRotated: shouldRotateBoard && !widget.isWhiteToMove,
            isWhite: widget.isWhiteToMove,
            onTapPromotionOption: onTapPromotionOption,
          ),
      ],
    );
  }
}

class DarkScrim extends StatelessWidget {
  final void Function() onTap;

  const DarkScrim({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onTap,
        child: Container(color: Colors.black.withAlpha(60)),
      ),
    );
  }
}

class PromotionDialog extends StatelessWidget {
  final int file;
  final bool isAtBottom;
  final bool isBoardRotated;
  final bool isWhite;
  final void Function(PieceType promotedToPieceType) onTapPromotionOption;

  const PromotionDialog({
    super.key,
    required this.file,
    required this.isAtBottom,
    required this.isBoardRotated,
    required this.isWhite,
    required this.onTapPromotionOption,
  });

  @override
  Widget build(BuildContext context) {
    final squareSize = MediaQuery.of(context).size.width / 8;

    return Positioned(
      left: isBoardRotated ? null : (file - 1) * squareSize,
      right: isBoardRotated ? (file - 1) * squareSize : null,
      bottom: isAtBottom ? 0 : null,
      child: Transform.rotate(
        angle: isAtBottom ? pi : 0,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                spreadRadius: 2,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              for (final pieceType in promotionOptions)
                SquareWidget(
                  size: squareSize,
                  piece: Piece(pieceType: pieceType, isWhite: isWhite),
                  onTap: () {
                    onTapPromotionOption(pieceType);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
