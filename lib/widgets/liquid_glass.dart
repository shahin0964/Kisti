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
            // Dynamic liquid gradient base
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    LiquidGlassTheme.activeBgDarkVoid,
                    LiquidGlassTheme.activeBgMidnight,
                    LiquidGlassTheme.activeBgDarkVoid,
                  ],
                ),
              ),
            ),

            // Top-left Glowing Orb 1
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
                      LiquidGlassTheme.activeOrb1.withOpacity(0.22),
                      LiquidGlassTheme.activeOrb1.withOpacity(0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Mid-Right Glowing Orb 2
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
                      LiquidGlassTheme.activeOrb2.withOpacity(0.20),
                      LiquidGlassTheme.activeOrb2.withOpacity(0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Bottom-Left Glowing Orb 3
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
                      LiquidGlassTheme.activeOrb3.withOpacity(0.22),
                      LiquidGlassTheme.activeOrb3.withOpacity(0.04),
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
    this.borderRadius = 18.0,
    this.glowColor,
    this.blur = LiquidGlassTheme.glassBlur,
    this.onTap,
    this.customGlassColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            customGlassColor ?? Colors.white.withOpacity(0.08),
            customGlassColor?.withOpacity(0.5) ?? Colors.white.withOpacity(0.03),
          ],
        ),
        border: Border.all(
          width: 1.1,
          color: glowColor != null
              ? glowColor!.withOpacity(0.35)
              : Colors.white.withOpacity(0.16),
        ),
        boxShadow: [
          ...LiquidGlassTheme.glassShadow(),
          if (glowColor != null)
            BoxShadow(
              color: glowColor!.withOpacity(0.15),
              blurRadius: 18,
              spreadRadius: -4,
            ),
        ],
      ),
      child: child,
    );

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 6),
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
  final EdgeInsetsGeometry? padding;

  const LiquidButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.glowColor = LiquidGlassTheme.neonEmerald,
    this.isSecondary = false,
    this.height = 44.0,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: isSecondary
            ? []
            : [
                BoxShadow(
                  color: glowColor.withOpacity(0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: isSecondary
                    ? LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.09),
                          Colors.white.withOpacity(0.04),
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
                      ? Colors.white.withOpacity(0.18)
                      : Colors.white.withOpacity(0.35),
                  width: 1.1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 16,
                      color: isSecondary ? Colors.white : Colors.black,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        color: isSecondary ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ],
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
  final ValueChanged<String>? onChanged;

  const LiquidTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffix,
    this.onChanged,
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
              onChanged: onChanged,
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

typedef LiquidGlassButton = LiquidButton;
