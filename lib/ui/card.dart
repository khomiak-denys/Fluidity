import 'package:flutter/material.dart';

/// Основна Card з rounded corners та border
class AppCard extends StatelessWidget {
  final Widget? child;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Border? border;
  final List<Widget>? children;

  const AppCard({
    super.key,
    this.child,
    this.color,
    this.padding,
    this.borderRadius,
    this.border,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget content = child ?? (children != null 
      ? Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children!,
        )
      : const SizedBox.shrink());

    return Container(
      decoration: BoxDecoration(
        color: color ?? theme.cardTheme.color ?? theme.cardColor,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: border ?? Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: content,
    );
  }
}

/// Card Header з title та optional description
class CardHeader extends StatelessWidget {
  final Widget? title;
  final Widget? description;
  final Widget? action;
  final EdgeInsetsGeometry? padding;
  final bool hasBorderBottom;

  const CardHeader({
    super.key,
    this.title,
    this.description,
    this.action,
    this.padding,
    this.hasBorderBottom = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.fromLTRB(24, 24, 24, 0),
      decoration: hasBorderBottom ? BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) title!,
                if (description != null) ...[
                  const SizedBox(height: 6),
                  description!,
                ],
                if (hasBorderBottom) const SizedBox(height: 24),
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 16),
            action!,
          ],
        ],
      ),
    );
  }
}

/// Card Title - заголовок картки
class CardTitle extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const CardTitle({
    super.key,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: style ?? theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1,
      ),
    );
  }
}

/// Card Description - підзаголовок/опис
class CardDescription extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const CardDescription({
    super.key,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: style ?? theme.textTheme.bodyMedium?.copyWith(
        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
      ),
    );
  }
}

/// Card Content - основний вміст картки
class CardContent extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool isLast;

  const CardContent({
    super.key,
    required this.child,
    this.padding,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.fromLTRB(
        24,
        24,
        24,
        isLast ? 24 : 0,
      ),
      child: child,
    );
  }
}

/// Card Footer - футер картки
class CardFooter extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool hasBorderTop;

  const CardFooter({
    super.key,
    required this.child,
    this.padding,
    this.hasBorderTop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.fromLTRB(
        24,
        hasBorderTop ? 24 : 0,
        24,
        24,
      ),
      decoration: hasBorderTop ? BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ) : null,
      child: child,
    );
  }
}

/// Card Action - дії в header (іконки, кнопки)
class CardAction extends StatelessWidget {
  final Widget child;

  const CardAction({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}