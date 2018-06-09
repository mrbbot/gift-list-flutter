import 'package:flutter/material.dart';

class SpacedCurve extends Curve {
  final Curve curve;
  final double curvePercent;

  SpacedCurve({@required this.curve, @required this.curvePercent});

  @override
  double transform(double t) =>
      t <= curvePercent ? curve.transform(t / curvePercent) : 1.0;
}
