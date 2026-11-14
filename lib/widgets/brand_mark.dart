import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

class BrandMark extends StatelessWidget {
  final double size;
  final bool showWordmark;

  const BrandMark({super.key, this.size = 112, this.showWordmark = true});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: colors.primary,
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.surfaceContainerHighest,
              width: 2,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                'VF',
                style: TextStyle(
                  color: colors.onPrimary,
                  fontFamily: 'serif',
                  fontStyle: FontStyle.italic,
                  fontSize: size * 0.48,
                  letterSpacing: -size * 0.035,
                ),
              ),
              Positioned(
                top: size * 0.17,
                right: size * 0.15,
                child: Icon(
                  Icons.eco,
                  size: size * 0.16,
                  color: AppTheme.terracotta,
                ),
              ),
            ],
          ),
        ),
        if (showWordmark) ...[
          const SizedBox(height: 14),
          Text(
            'VaneFlow',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
          ),
        ],
      ],
    );
  }
}
