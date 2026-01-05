import 'package:chess/models/board_analyzer.dart';
import 'package:chess/models/move.dart';
import 'package:chess/models/piece.dart';
import 'package:chess/models/piece_placement.dart';
import 'package:chess/models/square.dart';

const _kingToRookFromRookTo = [
  [7, 8, 6], // King side
  [3, 1, 4], // Queen side
]; // (File)

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
    final piece = currentPiecePlacement.pieceAt(square)!;

    bool? hasKingMoved;
    List<bool>? hasRooksMoved;
    if (piece.pieceType == PieceType.king) {
      hasKingMoved = this.hasKingMoved(piece.isWhite);
      hasRooksMoved = this.hasRooksMoved(piece.isWhite);
    }

    // If the piece is not king, null will be passed to the named parameters
    return BoardAnalyzer(currentPiecePlacement).legalMoves(
      square,
      hasKingMoved: hasKingMoved,
      hasRooksMoved: hasRooksMoved,
      lastMove: lastMove,
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
  void movePiece(
    Square from,
    Square to, {
    PieceType? promotedToPieceType,
    bool isEnPassantMove = false,
  }) {
    // TODO: Clean this mess up by splitting the method into smaller methods
    final piece = currentPiecePlacement.pieceAt(from)!;
    Move move;
    PiecePlacement piecePlacementAfterMoving;

    final isCastlingMove =
        piece.pieceType == PieceType.king &&
        from.file == 5 &&
        (to.file == 3 || to.file == 7);

    if (isCastlingMove) {
      // Move king
      final piecePlacementAfterMovingKing = currentPiecePlacement.movePiece(
        Move(from, to, piece: piece),
      );

      // Move rook
      final rookFromRookTo = _kingToRookFromRookTo.firstWhere((element) {
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

      piecePlacementAfterMoving = piecePlacementAfterMovingRook;
      move = Move(
        from,
        Square(rookFromRookTo[1], from.rank),
        piece: piece,
        capturesPiece: false,
        isKingSideCastlingMove: to.file == 7,
      ); // This move's from and to is used for highlighting only. It doesn't represent the actual from and to.
    } else if (isEnPassantMove) {
      // En passant move
      move = Move(
        from,
        to,
        piece: piece,
        capturesPiece: true,
        isEnPassantMove: isEnPassantMove,
      );
      piecePlacementAfterMoving = currentPiecePlacement.movePiece(move);
    } else {
      // Normal move and promotion move
      move = Move(
        from,
        to,
        piece: piece,
        capturesPiece: currentPiecePlacement.pieceAt(to) != null,
        promotedToPieceType: promotedToPieceType,
      );
      piecePlacementAfterMoving = currentPiecePlacement.movePiece(move);
    }

    final testingBoardAnalyzer = BoardAnalyzer(piecePlacementAfterMoving);

    // Checks if the move causes check to the opponent king
    final causesCheck = testingBoardAnalyzer.isKingInCheck(!piece.isWhite);

    // Check if the move causes checkmate or stalemate
    final hasKingMoved = this.hasKingMoved(!piece.isWhite);
    final hasRooksMoved = this.hasRooksMoved(!piece.isWhite);
    final opponentHasLegalMoves = testingBoardAnalyzer.hasLegalMoves(
      !piece.isWhite,
      hasKingMoved: hasKingMoved,
      hasRooksMoved: hasRooksMoved,
      lastMove: lastMove,
    );
    final isCheckmate = causesCheck && !opponentHasLegalMoves;
    final isStalemate = !causesCheck && !opponentHasLegalMoves;

    final finalMove = move.copyWith(
      causesCheck: causesCheck,
      isCheckmate: isCheckmate,
      isStalemate: isStalemate,
    );

    // Update piece placement and move history
    currentPiecePlacement = piecePlacementAfterMoving;
    moveHistory.add(finalMove);

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

  bool hasKingMoved(bool isWhite) {
    return hasBothColorKingMoved[isWhite ? 0 : 1];
  }

  List<bool> hasRooksMoved(bool isWhite) {
    return hasBothColorRooksMoved[isWhite ? 0 : 1];
  }

  bool get hasGameEnded {
    return (lastMove?.isCheckmate ?? false) || (lastMove?.isStalemate ?? false);
  }
}
