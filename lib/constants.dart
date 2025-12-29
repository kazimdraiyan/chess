// TODO: Move all the constants here

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Constants {
  static const seedColor = Colors.purple;

  static final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  );

  static final lightPieceColor =
      ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ).primary;

  static final darkPieceColor =
      ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ).onPrimary;

  static final googleFont = GoogleFonts.alfaSlabOne();
}
