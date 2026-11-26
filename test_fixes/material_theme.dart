import 'package:flutter/material.dart' as material;
import 'package:ratings_plus/ratings_plus.dart';

material.Widget themedRating(
  material.ThemeExtension<RatingBarThemeData> target,
) {
  const start = RatingBarThemeData(
    itemSize: 28,
    mouseCursor: material.WidgetStatePropertyAll(
      material.SystemMouseCursors.click,
    ),
  );
  return material.MaterialApp(
    theme: material.ThemeData(extensions: [start.lerp(target, 0.5)]),
    home: material.Center(
      child: RatingBarIndicator(
        itemCount: 1,
        value: 1,
        itemBuilder: (context, index) =>
            const material.Icon(material.Icons.star),
      ),
    ),
  );
}
