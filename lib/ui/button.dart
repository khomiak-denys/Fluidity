import 'package:flutter/material.dart';

enum ButtonVariant { 
  primary, 
  destructive, 
  outline, 
  secondary, 
  ghost, 
  link 
}

enum ButtonSize { 
  small, 
  medium, 
  large, 
  icon 
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final bool isDisabled;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final (bgColor, fgColor, borderColor) = _getColors(context);
    final (padding, fontSize) = _getSize();

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: TextButton(
        onPressed: isDisabled ? null : onPressed,
        style: TextButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: borderColor != null ? BorderSide(color: borderColor) : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, size: fontSize + 2),
            if (icon != null) const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  (Color?, Color?, Color?) _getColors(BuildContext context) {
    final theme = Theme.of(context);
    switch (variant) {
      case ButtonVariant.primary:
        return (theme.colorScheme.primary, theme.colorScheme.onPrimary, null);
      case ButtonVariant.destructive:
        return (Colors.red, Colors.white, null);
      case ButtonVariant.outline:
        return (Colors.transparent, theme.colorScheme.onBackground, theme.dividerColor);
      case ButtonVariant.secondary:
        return (theme.colorScheme.secondaryContainer, theme.colorScheme.onSecondaryContainer, null);
      case ButtonVariant.ghost:
        return (Colors.transparent, theme.colorScheme.onSurface, null);
      case ButtonVariant.link:
        return (Colors.transparent, theme.colorScheme.primary, null);
    }
  }

  (EdgeInsets, double) _getSize() {
    switch (size) {
      case ButtonSize.small:
        return (const EdgeInsets.symmetric(horizontal: 12, vertical: 8), 13);
      case ButtonSize.medium:
        return (const EdgeInsets.symmetric(horizontal: 16, vertical: 10), 14);
      case ButtonSize.large:
        return (const EdgeInsets.symmetric(horizontal: 20, vertical: 12), 16);
      case ButtonSize.icon:
        return (const EdgeInsets.all(10), 14);
    }
  }
}
