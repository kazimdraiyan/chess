import 'package:chess/models/piece.dart';
import 'package:chess/models/square.dart';
import 'package:chess/utils.dart';

class Move {
  final Square from;
  final Square to;
  final Piece piece;
  final bool causesCheck;
  final bool capturesPiece;
  final bool? isKingSideCastlingMove; // null means not a castling move.

  const Move(
    this.from,
    this.to, {
    required this.piece,
    this.causesCheck = false,
    this.capturesPiece = false,
    this.isKingSideCastlingMove,
  });

  String get algebraicNotation {
    if (isKingSideCastlingMove != null) {
      return isKingSideCastlingMove! ? 'O-O' : 'O-O-O';
      // TODO: Why ! needed?
    }

    var result = '';

    if (piece.pieceType != PieceType.pawn) {
      result += Utils.fenInitialOf[piece.pieceType]!.toUpperCase();
    }
    if (capturesPiece) {
      result += 'x';
      if (piece.pieceType == PieceType.pawn) {
        result = from.algebraicNotation[0] + result;
      }
    }
    result += to.algebraicNotation;
    if (causesCheck) {
      result += '+';
    }

    // TODO: Implement castling [DONE], promotion, en passant, checkmate, draw, disambiguating moves, etc.

    return result;
  }

  @override
  String toString() => algebraicNotation;
}
