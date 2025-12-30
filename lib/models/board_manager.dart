import 'package:chess/models/board_analyzer.dart';
import 'package:chess/models/move.dart';
import 'package:chess/models/piece.dart';
import 'package:chess/models/piece_placement.dart';
import 'package:chess/models/square.dart';

class BoardManager {
  var currentPiecePlacement = PiecePlacement.starting();
  final moveHistory = <Move>[];

  // TODO: Give these variables more meaningful names
  var hasBothColorKingMoved = [false, false]; // [White, Black]
  var hasBothColorRooksMoved = [
    [false, false],
    [false, false],
  ]; // [White[Queen side, King side], Black[Queen side, King side]]

  List<Square> legalMoves(Square square) {
    bool? hasKingMoved;
    List<bool>? hasRooksMoved;
    if (currentPiecePlacement.pieceAt(square)!.pieceType == PieceType.king) {
      hasKingMoved =
          hasBothColorKingMoved[currentPiecePlacement.pieceAt(square)!.isWhite
              ? 0
              : 1];
      hasRooksMoved =
          hasBothColorRooksMoved[currentPiecePlacement.pieceAt(square)!.isWhite
              ? 0
              : 1];
    }
    // If the piece is not king, null will be passed to the named parameters
    return BoardAnalyzer(currentPiecePlacement).legalMoves(
      square,
      hasKingMoved: hasKingMoved,
      hasRooksMoved: hasRooksMoved,
    );
  }

  List<Square> attackedSquares(bool isWhitePerspective) {
    return BoardAnalyzer(
      currentPiecePlacement,
    ).attackedSquares(isWhitePerspective);
  }

  bool isOccupiedByEnemyPiece(Square square, bool isWhitePerspective) {
    return BoardAnalyzer(
      currentPiecePlacement,
    ).isOccupiedByEnemyPiece(square, isWhitePerspective);
  }

  bool isPromotionMove(Square from, Square to) {
    final piece = currentPiecePlacement.pieceAt(from)!;
    return piece.pieceType == PieceType.pawn &&
        to.rank == (piece.isWhite ? 8 : 1);
  }

  // promotedToPieceType being null means not a promotion move.
  void movePiece(Square from, Square to, {PieceType? promotedToPieceType}) {
    // TODO: Clean this mess up by splitting the method into smaller methods
    final piece = currentPiecePlacement.pieceAt(from)!;

    if (piece.pieceType == PieceType.king &&
        from.file == 5 &&
        (to.file == 3 || to.file == 7)) {
      // Castling move
      const kingToRookFromRookTo = [
        [7, 8, 6], // King side
        [3, 1, 4], // Queen side
      ]; // (File)

      final piecePlacementAfterMovingKing = currentPiecePlacement.movePiece(
        Move(from, to, piece: piece),
      );

      final rookFromRookTo = kingToRookFromRookTo.firstWhere((element) {
        return element[0] == to.file;
      });
      final piecePlacementAfterMovingRook = piecePlacementAfterMovingKing
          .movePiece(
            Move(
              Square(rookFromRookTo[1], from.rank),
              Square(rookFromRookTo[2], from.rank),
              piece: Piece(pieceType: PieceType.rook),
            ),
          );
      currentPiecePlacement = piecePlacementAfterMovingRook;
      moveHistory.add(
        Move(
          from,
          Square(rookFromRookTo[1], from.rank),
          piece: piece,
          isKingSideCastlingMove: to.file == 7,
        ),
      ); // TODO: This move's from and to is used for highlighting only. It doesn't represent the actual from and to. Implement a better way to represent and highlight castling moves.
    } else {
      final piecePlacementAfterMoving = currentPiecePlacement.movePiece(
        Move(from, to, piece: piece, promotedToPieceType: promotedToPieceType),
      );

      final testingBoardAnalyzer = BoardAnalyzer(piecePlacementAfterMoving);

      final move = Move(
        from,
        to,
        piece: piece,
        capturesPiece: currentPiecePlacement.pieceAt(to) != null,
        causesCheck: testingBoardAnalyzer.isKingInCheck(!piece.isWhite),
        promotedToPieceType: promotedToPieceType,
      );

      if (piecePlacementAfterMoving != currentPiecePlacement) {
        // TODO: Is this if check necessary?
        currentPiecePlacement = piecePlacementAfterMoving;
        moveHistory.add(move);
      }
    }

    // Update castling rights
    final index = piece.isWhite ? 0 : 1;
    if (piece.pieceType == PieceType.king && !hasBothColorKingMoved[index]) {
      hasBothColorKingMoved[index] = true;
    } else if (piece.pieceType == PieceType.rook) {
      final queenSideRookInitialSquare = Square(1, piece.isWhite ? 1 : 8);
      final kingSideRookInitialSquare = Square(8, piece.isWhite ? 1 : 8);
      if (from == queenSideRookInitialSquare &&
          !hasBothColorRooksMoved[index][0]) {
        hasBothColorRooksMoved[index][0] = true;
      } else if (from == kingSideRookInitialSquare &&
          !hasBothColorRooksMoved[index][1]) {
        hasBothColorRooksMoved[index][1] = true;
      }
    }
    // TODO: Save captured pieces and calculate advantage
  }

  Move? get lastMove {
    if (moveHistory.isEmpty) {
      return null;
    } else {
      return moveHistory.last;
    }
  }
}
