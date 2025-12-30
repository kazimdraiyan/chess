// TODO: Move all the constants here

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Constants {
  static const seedColor = Colors.pink;

  static final lightColorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  );

  static final darkColorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  );

  static final lightPieceColor = darkColorScheme.primary;

  static final darkPieceColor = darkColorScheme.onPrimary;

  static final googleFont = GoogleFonts.alfaSlabOne();
}
