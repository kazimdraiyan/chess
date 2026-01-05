import 'package:chess/models/move.dart';
import 'package:chess/models/piece.dart';
import 'package:chess/models/piece_placement.dart';
import 'package:chess/models/square.dart';

class BoardAnalyzer {
  final PiecePlacement _piecePlacement;

  const BoardAnalyzer(this._piecePlacement);

  List<Square> attackedSquares(bool isWhitePerspective) {
    final opponentPieceContainingSquares = _piecePlacement
        .certainColorPieceContainingSquares(!isWhitePerspective);

    final result = <Square>[];
    for (final opponentPieceContainingSquare
        in opponentPieceContainingSquares) {
      result.addAll(attackSquares(opponentPieceContainingSquare));
    }

    return result;
  }

  bool hasLegalMoves(
    bool isWhite, {
    required bool hasKingMoved,
    required List<bool> hasRooksMoved,
    required Move? lastMove,
  }) {
    final currentColorPieceContainingSquares = _piecePlacement
        .certainColorPieceContainingSquares(isWhite);
    for (final currentColorPieceContainingSquare
        in currentColorPieceContainingSquares) {
      if (legalMoves(
        currentColorPieceContainingSquare,
        hasKingMoved: hasKingMoved,
        hasRooksMoved: hasRooksMoved,
        lastMove: lastMove,
      ).isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  List<Square> legalMoves(
    Square square, {
    bool? hasKingMoved,
    List<bool>? hasRooksMoved,
    required Move? lastMove,
  }) {
    final piece = _piecePlacement.pieceAt(square)!;

    final filteredMoves = this.filteredMoves(square, lastMove);

    final result = <Square>[];
    for (final filteredMove in filteredMoves) {
      final testingBoardAnalyzer = BoardAnalyzer(
        _piecePlacement.movePiece(
          Move(
            square,
            filteredMove,
            piece: piece,
            isEnPassantMove: filteredMove.isEnPassantTargetSquare,
          ),
        ),
      );
      if (!testingBoardAnalyzer.isKingInCheck(piece.isWhite)) {
        // King would not be in check
        result.add(filteredMove);
      }
    }
    if (piece.pieceType == PieceType.king && !hasKingMoved!) {
      // hasKingMoved is non-null for sure, because a value is passed from BoardManager if the piece is a king
      // Selected piece is a king and it hasn't moved yet
      result.addAll(_kingCastleSquares(piece.isWhite, hasRooksMoved!));
    }

    return result;
  }

  // Attack squares should include blocking friendly pieces. Attack squares should not include en passant target squares.
  List<Square> attackSquares(Square square) {
    final piece = _piecePlacement.pieceAt(square);
    if (piece == null) {
      return [];
    } else if (piece.pieceType == PieceType.rook) {
      return _rookFilteredMoves(
        square,
        shouldIncludeBlockingFriendlyPiece: true,
      );
    } else if (piece.pieceType == PieceType.bishop) {
      return _bishopFilteredMoves(
        square,
        shouldIncludeBlockingFriendlyPiece: true,
      );
    } else if (piece.pieceType == PieceType.queen) {
      return _queenFilteredMoves(
        square,
        shouldIncludeBlockingFriendlyPiece: true,
      );
    } else if (piece.pieceType == PieceType.knight) {
      return square.knightSquares;
    } else if (piece.pieceType == PieceType.king) {
      return square.kingSquares;
    } else {
      return _pawnAttackSquares(square);
    }
  }

  /// filteredMoves doesn't account for pinned pieces, so some moves might leave the king in check.
  /// lastMove is needed to determine en passant rights.
  List<Square> filteredMoves(Square square, Move? lastMove) {
    final piece = _piecePlacement.pieceAt(square);
    if (piece == null) {
      return [];
    } else if (piece.pieceType == PieceType.rook) {
      return _rookFilteredMoves(square);
    } else if (piece.pieceType == PieceType.bishop) {
      return _bishopFilteredMoves(square);
    } else if (piece.pieceType == PieceType.queen) {
      return _queenFilteredMoves(square);
    } else if (piece.pieceType == PieceType.knight) {
      return _knightFilteredMoves(square);
    } else if (piece.pieceType == PieceType.pawn) {
      return _pawnFilteredMoves(square, lastMove);
    } else {
      // King
      return _kingFilteredMoves(square);
    }
  }

  List<Square> _rookFilteredMoves(
    Square square, {
    shouldIncludeBlockingFriendlyPiece = false,
  }) {
    final piece = _piecePlacement.pieceAt(square);

    final orthogonalSquares = square.orthogonalSquares;

    return traverseTillBlockage(
      orthogonalSquares,
      piece!.isWhite,
      shouldIncludeBlockingFriendlyPiece: shouldIncludeBlockingFriendlyPiece,
    );
  }

  List<Square> _bishopFilteredMoves(
    Square square, {
    shouldIncludeBlockingFriendlyPiece = false,
  }) {
    final piece = _piecePlacement.pieceAt(square);

    final diagonalSquares = square.diagonalSquares;

    return traverseTillBlockage(
      diagonalSquares,
      piece!.isWhite,
      shouldIncludeBlockingFriendlyPiece: shouldIncludeBlockingFriendlyPiece,
    );
  }

  List<Square> _queenFilteredMoves(
    Square square, {
    shouldIncludeBlockingFriendlyPiece = false,
  }) {
    final piece = _piecePlacement.pieceAt(square);

    final orthogonalSquares = square.orthogonalSquares;
    final diagonalSquares = square.diagonalSquares;
    final allDirectionalSquares = [...orthogonalSquares, ...diagonalSquares];

    return traverseTillBlockage(
      allDirectionalSquares,
      piece!.isWhite,
      shouldIncludeBlockingFriendlyPiece: shouldIncludeBlockingFriendlyPiece,
    );
  }

  List<Square> _knightFilteredMoves(Square square) {
    final piece = _piecePlacement.pieceAt(square)!;
    final knightSquares = square.knightSquares;

    return filterBlockageByFriendlyPieces(knightSquares, piece.isWhite);
  }

  List<Square> _kingFilteredMoves(Square square) {
    final piece = _piecePlacement.pieceAt(square)!;
    final kingSquares = square.kingSquares;

    return filterBlockageByFriendlyPieces(kingSquares, piece.isWhite);
  }

  List<Square> _kingCastleSquares(bool isWhite, List<bool> hasRooksMoved) {
    final result = <Square>[];

    if (!isKingInCheck(isWhite)) {
      final rank = isWhite ? 1 : 8;

      final emptyTestingFiles = [
        [2, 3, 4],
        [6, 7],
      ]; // [Queen side, King side]
      final attackTestingFiles = [
        [3, 4],
        [6, 7],
      ]; // [Queen side, King side]

      // i = 0 for Queen side, i = 1 for King side
      for (var i = 0; i < 2; i++) {
        if (hasRooksMoved[i]) continue;
        // Rook of the side we're dealing with hasn't moved yet.

        var areAllFilesBetweenEmpty = true;
        for (final file in emptyTestingFiles[i]) {
          if (!_piecePlacement.isEmpty(Square(file, rank))) {
            areAllFilesBetweenEmpty = false;
            break;
          }
        }
        var areAllFilesThroughThePathKingTravelsNonAttacked = true;
        final attackedSquares = this.attackedSquares(isWhite);
        for (final file in attackTestingFiles[i]) {
          if (attackedSquares.contains(Square(file, rank))) {
            areAllFilesThroughThePathKingTravelsNonAttacked = false;
            break;
          }
        }

        if (areAllFilesBetweenEmpty &&
            areAllFilesThroughThePathKingTravelsNonAttacked) {
          final fileStep = i == 0 ? -2 : 2;
          result.add(Square(5 + fileStep, rank));
        }
      }
    }
    return result;
  }

  List<Square> _pawnFilteredMoves(Square square, Move? lastMove) {
    final pawnSquares = <Square>[];
    final pawnCapturableSquares = <Square>[];

    final piece = _piecePlacement.pieceAt(square)!;

    final rankStep = piece.isWhite ? 1 : -1;

    // 1-step to the front
    pawnSquares.add(Square(square.file, square.rank + rankStep));

    // 2-step to the front if the pawn is at its starting position.
    if ((piece.isWhite && square.rank == 2) ||
        (!piece.isWhite && square.rank == 7)) {
      pawnSquares.add(Square(square.file, square.rank + rankStep * 2));
    }

    // 1-step diagonal to the front if there's enemy pieces
    for (final testingSquare in _pawnAttackSquares(square)) {
      if (isOccupiedByEnemyPiece(testingSquare, piece.isWhite)) {
        pawnCapturableSquares.add(testingSquare);
      }
    }

    // En passant target squares
    if (square.rank == (piece.isWhite ? 5 : 4) &&
        lastMove != null &&
        lastMove.piece.pieceType == PieceType.pawn) {
      if ((lastMove.from.file - square.file).abs() == 1 &&
          (lastMove.from.rank - lastMove.to.rank).abs() == 2) {
        pawnCapturableSquares.add(
          Square(
            lastMove.from.file,
            lastMove.from.rank + rankStep * (-1),
            isEnPassantTargetSquare: true,
          ),
        );
      }
    }

    return [
      ...singleDirectionTraverseTillBlockage(
        pawnSquares,
        piece.isWhite,
        shouldIncludeBlockingEnemyPiece: false,
      ),
      ...pawnCapturableSquares,
    ];
  }

  List<Square> _pawnAttackSquares(Square square) {
    final result = <Square>[];
    final rankStep = _piecePlacement.pieceAt(square)!.isWhite ? 1 : -1;

    final testingRank = square.rank + rankStep;
    for (var fileStep = -1; fileStep <= 1; fileStep++) {
      if (fileStep == 0) continue;

      final testingFile = square.file + fileStep;
      if (testingFile < 1 || testingFile > 8) continue;

      final testingSquare = Square(testingFile, testingRank);
      result.add(testingSquare);
    }
    return result;
  }

  List<Square> filterBlockageByFriendlyPieces(
    List<Square> testingSquares,
    bool isOriginalPieceWhite,
  ) {
    final result = <Square>[];
    for (final testingSquare in testingSquares) {
      if (!isOccupiedByFriendlyPiece(testingSquare, isOriginalPieceWhite)) {
        result.add(testingSquare);
      }
    }
    return result;
  }

  List<Square> traverseTillBlockage(
    List<List<Square>> directionalSquares,
    bool isOriginalPieceWhite, {
    shouldIncludeBlockingFriendlyPiece = false,
  }) {
    final result = <Square>[];

    for (final singleDirectionSquares in directionalSquares) {
      result.addAll(
        singleDirectionTraverseTillBlockage(
          singleDirectionSquares,
          isOriginalPieceWhite,
          shouldIncludeBlockingFriendlyPiece:
              shouldIncludeBlockingFriendlyPiece,
        ),
      );
    }
    return result;
  }

  List<Square> singleDirectionTraverseTillBlockage(
    List<Square> singleDirectionSquares,
    bool isOriginalPieceWhite, {
    bool shouldIncludeBlockingFriendlyPiece = false,
    bool shouldIncludeBlockingEnemyPiece = true,
    bool isPawn = false,
  }) {
    final result = <Square>[];

    for (final testingSquare in singleDirectionSquares) {
      if (_piecePlacement.isEmpty(testingSquare)) {
        result.add(testingSquare);
      } else {
        if ((isOccupiedByFriendlyPiece(testingSquare, isOriginalPieceWhite) &&
                shouldIncludeBlockingFriendlyPiece) ||
            (isOccupiedByEnemyPiece(testingSquare, isOriginalPieceWhite) &&
                shouldIncludeBlockingEnemyPiece)) {
          result.add(testingSquare);
        }
        break;
      }
    }

    return result;
  }

  bool isOccupiedByFriendlyPiece(
    Square testingSquare,
    bool isOriginalPieceWhite,
  ) {
    return (_piecePlacement.isOccupiedByWhite(testingSquare) &&
            isOriginalPieceWhite) ||
        (_piecePlacement.isOccupiedByBlack(testingSquare) &&
            !isOriginalPieceWhite);
  }

  bool isOccupiedByEnemyPiece(Square testingSquare, bool isOriginalPieceWhite) {
    return !_piecePlacement.isEmpty(testingSquare) &&
        !isOccupiedByFriendlyPiece(testingSquare, isOriginalPieceWhite);
  }

  bool isKingInCheck(bool isWhite) {
    return attackedSquares(
      isWhite,
    ).contains(_piecePlacement.kingSquare(isWhite));
  }
}
