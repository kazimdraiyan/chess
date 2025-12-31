class Square {
  final int _file;
  final int _rank;
  final bool isEnPassantTargetSquare;

  const Square(this._file, this._rank, {this.isEnPassantTargetSquare = false});

  factory Square.fromId(int id) {
    if (id < 0 || id > 63) {
      throw ArgumentError('Square id must be between 0 and 63');
    }

    final file = (id % 8) + 1;
    final rank = (id ~/ 8) + 1;

    return Square(file, rank);
  }

  factory Square.fromAlgebraicNotation(String algebraicNotation) {
    if (algebraicNotation.length != 2) {
      throw ArgumentError('Algebraic notation must contain two letters');
    }

    final fileName = algebraicNotation.substring(0, 1).toLowerCase();
    // Convert ASCII: 'a' = 97, so subtract 96 to get 1 for 'a'
    final file = fileName.codeUnitAt(0) - 'a'.codeUnitAt(0) + 1;
    if (file < 1 || file > 8) {
      throw ArgumentError('File must be a letter between a and h');
    }

    final rank = int.parse(algebraicNotation[1]);
    if (rank < 1 || rank > 8) {
      throw ArgumentError('Rank must be a number between 1 and 8');
    }

    return Square(file, rank);
  }

  int get file => _file;
  int get rank => _rank;

  bool get isDark => (_file + _rank) % 2 == 0;

  int get id => (_rank - 1) * 8 + (_file - 1);

  String get algebraicNotation {
    String fileLetter = String.fromCharCode('a'.codeUnitAt(0) + _file - 1);
    return '$fileLetter$_rank';
  }

  /// [[Top], [Right], [Bottom], [Left]]
  List<List<Square>> get orthogonalSquares {
    final result = <List<Square>>[];

    List<Square> singleOrthogonalDirectionSquares(bool isSameFile, int step) {
      final singleDirectionSquaresTemp = <Square>[];
      for (
        var i = step + (isSameFile ? rank : file);
        step == 1 ? i <= 8 : i >= 1;
        i += step
      ) {
        singleDirectionSquaresTemp.add(
          Square(isSameFile ? file : i, isSameFile ? i : rank),
        );
      }
      return singleDirectionSquaresTemp;
    }

    result.add(singleOrthogonalDirectionSquares(true, 1)); // Top
    result.add(singleOrthogonalDirectionSquares(false, 1)); // Right
    result.add(singleOrthogonalDirectionSquares(true, -1)); // Bottom
    result.add(singleOrthogonalDirectionSquares(false, -1)); // Left

    return result;
  }

  /// [[TopRight], [BottomRight], [BottomLeft], [TopLeft]]
  List<List<Square>> get diagonalSquares {
    final result = <List<Square>>[];

    List<Square> singleDiagonalDirectionSquares(int fileStep, int rankStep) {
      final singleDirectionSquaresTemp = <Square>[];

      var testingFile = file + fileStep;
      var testingRank = rank + rankStep;
      while (isFileRankValid(testingFile, testingRank)) {
        singleDirectionSquaresTemp.add(Square(testingFile, testingRank));
        testingFile += fileStep;
        testingRank += rankStep;
      }

      return singleDirectionSquaresTemp;
    }

    result.add(singleDiagonalDirectionSquares(1, 1)); // TopRight
    result.add(singleDiagonalDirectionSquares(1, -1)); // BottomRight
    result.add(singleDiagonalDirectionSquares(-1, -1)); // BottomLeft
    result.add(singleDiagonalDirectionSquares(-1, 1)); // TopLeft

    return result;
  }

  List<Square> get knightSquares {
    final result = <Square>[];
    for (var fileStep = -2; fileStep <= 2; fileStep++) {
      if (fileStep == 0) continue;
      for (var rankStep = -2; rankStep <= 2; rankStep++) {
        if (rankStep == 0 || fileStep.abs() == rankStep.abs()) continue;

        final testingFile = file + fileStep;
        final testingRank = rank + rankStep;
        if (Square.isFileRankValid(testingFile, testingRank)) {
          result.add(Square(testingFile, testingRank));
        }
      }
    }
    return result;
  }

  List<Square> get kingSquares {
    final result = <Square>[];
    for (var fileStep = -1; fileStep <= 1; fileStep++) {
      for (var rankStep = -1; rankStep <= 1; rankStep++) {
        final testingFile = file + fileStep;
        final testingRank = rank + rankStep;
        if (fileStep == 0 && rankStep == 0) continue;

        if (Square.isFileRankValid(testingFile, testingRank)) {
          result.add(Square(testingFile, testingRank));
        }
      }
    }
    return result;
  }

  static bool isSquareIdValid(int squareId) {
    return squareId >= 0 && squareId <= 63; // TODO: Use this function instead
  }

  static bool isFileRankValid(int file, int rank) {
    return 1 <= file && file <= 8 && 1 <= rank && rank <= 8;
  }

  @override
  String toString() {
    return algebraicNotation;
  }

  @override
  bool operator ==(Object other) {
    if (other is Square) {
      return other._file == _file && other._rank == _rank;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => _file * 31 + _rank; // TODO: Understand this
}
