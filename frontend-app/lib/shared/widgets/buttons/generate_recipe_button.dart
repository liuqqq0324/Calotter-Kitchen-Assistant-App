// lib/shared/widgets/buttons/generate_recipe_button.dart

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

class GenerateRecipeButton extends StatefulWidget {
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
  State<GenerateRecipeButton> createState() => _GenerateRecipeButtonState();
}

class _GenerateRecipeButtonState extends State<GenerateRecipeButton> {
  bool _isPressed = false;
  static const double _pressedTiltAngle = -0.09;
  static const double _buttonHeight = 70;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..rotateZ(_isPressed ? _pressedTiltAngle : 0.0),
        child: SizedBox(
          height: _buttonHeight,
          width: widget.isFullWidth ? double.infinity : null,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 涟漪效果背景（用 Positioned 避免撑高占位）
              Positioned.fill(
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Container(
                        width: 82 * (1 + value * 0.25),
                        height: 82 * (1 + value * 0.25),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.withOpacity(0.1 * (1 - value)),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // 按钮图片
              SizedBox(
                height: 66,
                width: widget.isFullWidth ? double.infinity : null,
                child: Image.asset(
                  'assets/images/generate_recipes_button.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
