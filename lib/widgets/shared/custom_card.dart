import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;

  const CustomCard({
    Key? key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
        side: borderColor != null
            ? BorderSide(color: borderColor!)
            : BorderSide.none,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.regular),
        child: child,
      ),
    );
  }
}
