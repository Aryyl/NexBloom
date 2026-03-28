import 'package:flutter/material.dart';

class ModernCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const ModernCard({
    super.key,
    required this.child,
    this.color,
    this.gradient,
    this.onTap,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: gradient != null
          ? Colors.transparent
          : (color ?? Theme.of(context).cardTheme.color),
      elevation: Theme.of(context).cardTheme.elevation,
      shape: Theme.of(context).cardTheme.shape,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: gradient != null
            ? BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
