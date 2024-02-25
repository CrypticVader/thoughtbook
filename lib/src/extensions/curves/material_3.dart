import 'package:flutter/animation.dart';

extension M3Easings on Curves {
  static const ThreePointCubic emphasized = ThreePointCubic(
    Offset(0.05, 0), Offset(0.133333, 0.06),
    Offset(0.166666, 0.4),
    Offset(0.208333, 0.82), Offset(0.25, 1),
  );

  static const Cubic emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1.0);

  static const Cubic emphasizedAccelerate = Cubic(0.3, 0.0, 0.8, 0.15);
}
