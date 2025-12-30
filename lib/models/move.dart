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
  final PieceType? promotedToPieceType; // null means not a promotion move.

  const Move(
    this.from,
    this.to, {
    required this.piece,
    this.causesCheck = false,
    this.capturesPiece = false,
    this.isKingSideCastlingMove,
    this.promotedToPieceType,
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
    if (promotedToPieceType != null) {
      result += '=${Utils.fenInitialOf[promotedToPieceType!]!.toUpperCase()}';
    }
    if (causesCheck) {
      result += '+';
    }

    // TODO: Implement castling [DONE], promotion [DONE], en passant, checkmate, draw, disambiguating moves, etc.

    return result;
  }

  @override
  String toString() => algebraicNotation;
}
