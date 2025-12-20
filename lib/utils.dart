import 'dart:collection';

import 'package:chess/models/piece.dart';
import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

class Utils {
  static const fenInitialOf = {
    PieceType.king: "k",
    PieceType.queen: "q",
    PieceType.rook: "r",
    PieceType.bishop: "b",
    PieceType.knight: "n",
    PieceType.pawn: "p",
  };

  static final pieceTypeNamed = LinkedHashMap.fromEntries(
    fenInitialOf.entries.map((entry) => MapEntry(entry.value, entry.key)),
  ); // Inverse of fenInitialOf

  static String iconSrcOf(PieceType pieceType, {bool isWhite = true}) {
    return 'assets/pieces_icon/${fenInitialOf[pieceType]!}${isWhite ? 'l' : 'd'}.svg';
  }

  static TonalPalette tonalPaletteOf(Color color) {
    final hct = Hct.fromInt(color.toARGB32());
    return TonalPalette.of(hct.hue, hct.chroma);
  }
}
