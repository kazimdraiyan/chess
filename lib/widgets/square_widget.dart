import 'dart:math' show pi;

import 'package:chess/constants.dart';
import 'package:chess/models/piece.dart';
import 'package:chess/models/square.dart';
import 'package:chess/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SquareWidget extends StatelessWidget {
  final Square square;
  final Piece? piece;
  final Color? highlightColor;
  final bool isDotted;
  final bool isCircled;
  final bool isPieceRotated;
  final void Function(Square square) onTapSquare;

  const SquareWidget(
    this.square, {
    this.piece,
    this.highlightColor,
    this.isDotted = false,
    this.isCircled = false,
    this.isPieceRotated = false,
    required this.onTapSquare,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tonalPalette = Utils.tonalPaletteOf(
      Theme.of(context).colorScheme.primary,
    );

    return GestureDetector(
      onTap: () => onTapSquare(square),
      child: Container(
        color:
            square.isDark
                ? Color(tonalPalette.get(65))
                : Color(tonalPalette.get(97)),
        child: Container(
          color: highlightColor,
          child: Center(
            child: Stack(
              children: [
                if (piece != null)
                  Opacity(
                    // TODO: Remove this opacity
                    opacity: 1,
                    child: PieceIconWidget(piece: piece, isPieceRotated: isPieceRotated),
                  ),
            
                if (isDotted) Center(child: Dot()),
                if (isCircled) Center(child: Circle()),
                // Center(
                //   child: Text(
                //     square.algebraicNotation,
                //     style: TextStyle(color: Colors.black),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PieceIconWidget extends StatelessWidget {
  const PieceIconWidget({
    super.key,
    required this.piece,
    required this.isPieceRotated,
  });

  final Piece? piece;
  final bool isPieceRotated;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: isPieceRotated ? pi : 0,
      child: SvgPicture.asset(
        Utils.iconSrcOf(
          piece!.pieceType,
          isWhite: piece!.isWhite,
        ), // TODO: Why ! needed?
        colorFilter: ColorFilter.mode(
          piece!.isWhite ? Constants.lightPieceColor : Constants.darkPieceColor,
          piece!.isWhite ? BlendMode.modulate : BlendMode.srcIn,
        ),
      ),
    );
  }
}

// TODO: Take colors from this into Constants
class Dot extends StatelessWidget {
  const Dot({super.key});

  @override
  Widget build(BuildContext context) {
    final tonalPalette = Utils.tonalPaletteOf(
      Theme.of(context).colorScheme.primary,
    );

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(tonalPalette.get(10)).withAlpha(50),
      ),
      width: 16,
      height: 16,
    );
  }
}

class Circle extends StatelessWidget {
  const Circle({super.key});

  @override
  Widget build(BuildContext context) {
    final tonalPalette = Utils.tonalPaletteOf(
      Theme.of(context).colorScheme.primary,
    );

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Color(tonalPalette.get(10)).withAlpha(50),
          width: 4.5,
        ),
      ),
    );
  }
}
