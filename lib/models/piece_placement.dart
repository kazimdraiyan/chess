import 'package:chess/models/move.dart';
import 'package:chess/models/piece.dart';
import 'package:chess/models/square.dart';
import 'package:chess/utils.dart';

class PiecePlacement {
  /// Rank 1 (File 1-8), Rank 2 (File 1-8), ...
  late final List<List<Piece?>> pieceMatrix;

  PiecePlacement.fromPieceMatrix(this.pieceMatrix);

  PiecePlacement.fromFenPosition(String fenPosition) {
    pieceMatrix = [];

    final fenRanks = fenPosition.split('/').reversed;
    for (final fenRank in fenRanks) {
      List<Piece?> rank = [];
      final fenRankLetters = fenRank.split('');
      for (final fenRankLetter in fenRankLetters) {
        final emptySquareCount = int.tryParse(fenRankLetter);
        if (emptySquareCount == null) {
          final pieceType = Utils.pieceTypeNamed[fenRankLetter.toLowerCase()]!;
          final isWhite = fenRankLetter.toUpperCase() == fenRankLetter;
          rank.add(Piece(pieceType: pieceType, isWhite: isWhite));
        } else {
          for (var i = 0; i < emptySquareCount; i++) {
            rank.add(null);
          }
        }
      }
      pieceMatrix.add(rank);
    }
  }

  factory PiecePlacement.starting() {
    return PiecePlacement.fromFenPosition(
      'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR',
    );
  }

  PiecePlacement movePiece(Move move) {
    final pieceMatrixCopy = [
      for (final rank in pieceMatrix) [...rank],
    ];
    final piece = pieceAt(move.from);
    if (piece == null) {
      return this; // If the fromSquare contains no piece, it returns the original PiecePlacement
    }
    pieceMatrixCopy[move.from.rank - 1][move.from.file - 1] = null;
    pieceMatrixCopy[move.to.rank - 1][move.to.file - 1] = piece;
    return PiecePlacement.fromPieceMatrix(pieceMatrixCopy);
  }

  String get fenPosition {
    var result = '';
    for (final rank in pieceMatrix.reversed) {
      var emptySquareCount = 0;

      for (final piece in rank) {
        if (piece != null) {
          if (emptySquareCount != 0) result += emptySquareCount.toString();
          final fenInitial = Utils.fenInitialOf[piece.pieceType]!;
          final fenInitialWithCase =
              piece.isWhite ? fenInitial.toUpperCase() : fenInitial;
          result += fenInitialWithCase;
          emptySquareCount = 0;
        } else {
          emptySquareCount += 1;
        }
      }
      if (rank.last == null) {
        result += emptySquareCount.toString();
        emptySquareCount = 0;
      }
      result += '/';
    }

    return result.substring(
      0,
      result.length - 1,
    ); // removes the trailing '/' in the String
  }

  Piece? pieceAt(Square square) {
    final piece = pieceMatrix[square.rank - 1][square.file - 1];
    return piece;
  }

  Square kingSquare(bool isWhite) {
    for (var rank = 1; rank <= 8; rank++) {
      for (var file = 1; file <= 8; file++) {
        final square = Square(file, rank);
        if (pieceAt(square)?.pieceType == PieceType.king &&
            pieceAt(square)?.isWhite == isWhite) {
          return Square(file, rank);
        }
      }
    }
    throw Exception('King is not on the board');
  }

  List<Square> certainColorPieceContainingSquares(bool isColorWhite) {
    final result = <Square>[];
    for (var rank = 1; rank <= 8; rank++) {
      for (var file = 1; file <= 8; file++) {
        final square = Square(file, rank);
        if (pieceAt(square)?.isWhite == isColorWhite) {
          result.add(square);
        }
      }
    }
    return result;
  }

  bool isEmpty(Square square) {
    return pieceAt(square) == null;
  }

  bool isOccupiedByWhite(Square square) {
    return !isEmpty(square) && pieceAt(square)!.isWhite;
  }

  bool isOccupiedByBlack(Square square) {
    return !isEmpty(square) && !pieceAt(square)!.isWhite;
  }
}
