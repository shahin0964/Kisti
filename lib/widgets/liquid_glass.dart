import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/liquid_glass_theme.dart';

/// Animated liquid background with glowing gradient orbs
class LiquidBackground extends StatefulWidget {
  final Widget child;

  const LiquidBackground({super.key, required this.child});

  @override
  State<LiquidBackground> createState() => _LiquidBackgroundState();
}

class _LiquidBackgroundState extends State<LiquidBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final val = _controller.value;
        return Stack(
          children: [
            // Dark obsidian gradient base
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF04070D),
                    Color(0xFF090E18),
                    Color(0xFF06090F),
                  ],
                ),
              ),
            ),

            // Top-left Glowing Cyber Cyan Orb
            Positioned(
              top: -80 + (val * 40),
              left: -60 + (val * 30),
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      LiquidGlassTheme.cyberCyan.withOpacity(0.22),
                      LiquidGlassTheme.cyberCyan.withOpacity(0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Mid-Right Glowing Neon Emerald Orb
            Positioned(
              top: 220 - (val * 50),
              right: -80 - (val * 20),
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      LiquidGlassTheme.neonEmerald.withOpacity(0.20),
                      LiquidGlassTheme.neonEmerald.withOpacity(0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Bottom-Left Glowing Electric Violet Orb
            Positioned(
              bottom: -40 + (val * 60),
              left: -40 + (val * 40),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      LiquidGlassTheme.electricViolet.withOpacity(0.24),
                      LiquidGlassTheme.electricViolet.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Subdued subtle grid / ambient overlay
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.25),
              ),
            ),

            // Main Content
            widget.child,
          ],
        );
      },
    );
  }
}

/// Core Liquid Glass Card with BackdropFilter and Specular Edge
class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? glowColor;
  final double blur;
  final VoidCallback? onTap;
  final Color? customGlassColor;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 22.0,
    this.glowColor,
    this.blur = LiquidGlassTheme.glassBlur,
    this.onTap,
    this.customGlassColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            customGlassColor ?? Colors.white.withOpacity(0.09),
            customGlassColor?.withOpacity(0.5) ?? Colors.white.withOpacity(0.03),
          ],
        ),
        border: Border.all(
          width: 1.2,
          color: glowColor != null
              ? glowColor!.withOpacity(0.35)
              : Colors.white.withOpacity(0.18),
        ),
        boxShadow: [
          ...LiquidGlassTheme.glassShadow(),
          if (glowColor != null)
            BoxShadow(
              color: glowColor!.withOpacity(0.15),
              blurRadius: 28,
              spreadRadius: -4,
            ),
        ],
      ),
      child: child,
    );

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: onTap != null
              ? Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(borderRadius),
                    onTap: onTap,
                    splashColor: (glowColor ?? LiquidGlassTheme.cyberCyan)
                        .withOpacity(0.15),
                    highlightColor: Colors.white.withOpacity(0.05),
                    child: cardContent,
                  ),
                )
              : cardContent,
        ),
      ),
    );
  }
}

/// Futuristic Liquid Action Button
class LiquidButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color glowColor;
  final bool isSecondary;
  final double height;
  final double? width;

  const LiquidButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.glowColor = LiquidGlassTheme.neonEmerald,
    this.isSecondary = false,
    this.height = 52.0,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isSecondary
            ? []
            : [
                BoxShadow(
                  color: glowColor.withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: isSecondary
                      ? LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.08),
                            Colors.white.withOpacity(0.03),
                          ],
                        )
                      : LinearGradient(
                          colors: [
                            glowColor,
                            glowColor,
                          ],
                        ),
                  border: Border.all(
                    color: isSecondary
                        ? Colors.white.withOpacity(0.2)
                        : Colors.white.withOpacity(0.4),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 20,
                        color: isSecondary ? Colors.white : Colors.black,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        color: isSecondary ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Futuristic Liquid Badge
class LiquidBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const LiquidBadge({
    super.key,
    required this.label,
    this.color = LiquidGlassTheme.neonEmerald,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.18),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Futuristic Liquid Input Field
class LiquidTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const LiquidTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1.1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              validator: validator,
              style: const TextStyle(
                color: LiquidGlassTheme.textPrimary,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: label,
                labelStyle: const TextStyle(
                  color: LiquidGlassTheme.textSecondary,
                  fontSize: 13,
                ),
                hintText: hint,
                hintStyle: TextStyle(
                  color: LiquidGlassTheme.textMuted.withOpacity(0.7),
                  fontSize: 13,
                ),
                prefixIcon: prefixIcon != null
                    ? Icon(
                        prefixIcon,
                        color: LiquidGlassTheme.cyberCyan,
                        size: 20,
                      )
                    : null,
                suffix: suffix,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
