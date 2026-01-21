// lib/widgets/generate_recipe_button.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:personal_sous_chef/core/theme/fallback_google_fonts.dart';

/// Custom clipper for torn paper edges
class TornPaperClipper extends CustomClipper<Path> {
  final int seed;

  TornPaperClipper({this.seed = 42});

  @override
  Path getClip(Size size) {
    final random = math.Random(seed);
    final Path path = Path();

    // Start from top-left with slight irregularity
    double x = 0;
    double y = 2 + random.nextDouble() * 2;
    path.moveTo(x, y);

    // Top edge (torn)
    while (x < size.width) {
      x += 8 + random.nextDouble() * 6;
      y = 1 + random.nextDouble() * 3;
      path.lineTo(x, y);
    }

    // Right edge
    x = size.width - 1 - random.nextDouble() * 2;
    y = 0;
    while (y < size.height) {
      y += 8 + random.nextDouble() * 6;
      x = size.width - 1 - random.nextDouble() * 2;
      path.lineTo(x, y);
    }

    // Bottom edge (torn)
    y = size.height - 2 - random.nextDouble() * 2;
    while (x > 0) {
      x -= 8 + random.nextDouble() * 6;
      y = size.height - 1 - random.nextDouble() * 3;
      path.lineTo(x, y);
    }

    // Left edge
    x = 1 + random.nextDouble() * 2;
    while (y > 0) {
      y -= 8 + random.nextDouble() * 6;
      x = 1 + random.nextDouble() * 2;
      path.lineTo(x, y);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class GenerateRecipeButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final bool isFullWidth;

  const GenerateRecipeButton({
    super.key,
    required this.onPressed,
    this.label = "Generate Recipes",
    this.icon = Icons.auto_awesome,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget buttonContent = Stack(
      clipBehavior: Clip.none,
      children: [
        // Main torn paper label
        ClipPath(
          clipper: TornPaperClipper(seed: 42),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              // Muted terracotta/kraft paper color
              color: const Color(0xFFD4A574), // Warm brownish-orange
              boxShadow: [
                // Subtle shadow to lift off background
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                splashColor: Colors.black.withOpacity(0.05),
                highlightColor: Colors.black.withOpacity(0.02),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: isFullWidth
                        ? MainAxisSize.max
                        : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: const Color(
                          0xFF5D4E37,
                        ), // Dark brown for contrast
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        label,
                        style: GoogleFonts.caveat(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF5D4E37), // Dark brown
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Left tape accent
        Positioned(
          left: 12,
          top: -4,
          child: Transform.rotate(
            angle: -0.05,
            child: Container(
              width: 32,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Right tape accent
        Positioned(
          right: 12,
          top: -4,
          child: Transform.rotate(
            angle: 0.05,
            child: Container(
              width: 32,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    if (!isFullWidth) {
      return buttonContent;
    }

    return buttonContent;
  }
}
