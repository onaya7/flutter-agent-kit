import 'package:flutter/material.dart';
import 'package:kit_template_app/core/constants/app_color.dart';

/// An interactive 5-star rating row.
class RatingStars extends StatelessWidget {
  const RatingStars({
    required this.rating,
    required this.onChanged,
    this.size = 40,
    this.gap = 10,
    this.color = AppColor.warning,
    super.key,
  });

  final int rating;
  final ValueChanged<int> onChanged;
  final double size;
  final double gap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(i + 1),
            child: Padding(
              padding: EdgeInsets.only(right: gap),
              child: Icon(
                i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: color,
                size: size,
              ),
            ),
          ),
      ],
    );
  }
}
