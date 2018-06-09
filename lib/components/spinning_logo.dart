import 'package:flutter/material.dart';
import 'package:gift_list/utilities/spaced_curve.dart';
import 'package:isomer/isomer.dart' as Isomer;
import 'dart:math' as math;

class SpinningLogo extends AnimatedWidget {
  static final _tween = new CurveTween(
      curve: new SpacedCurve(curve: new _EaseInOutCurve(), curvePercent: 0.5));

  SpinningLogo({Key key, Animation<double> animation})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return new AspectRatio(
      aspectRatio: 1.0,
      child: new ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: new CustomPaint(
          painter: new _SpinningLogoPainter(
              angle: _tween.evaluate(animation) * 360.0),
        ),
      ),
    );
  }
}

final Isomer.Color _pink = new Isomer.Color(201, 26, 84);
final Isomer.Color _grey = new Isomer.Color(51, 51, 51);

const _MAGIC_ANGLE = 134.5;
const _THIRD = 1 / 3;
const _Z_OFFSET = -0.2;

bool _inRange(start, angle) => start <= angle && angle < (start + 180);

double _toRadians(degrees) => degrees * math.pi / 180;

class _EaseInOutCurve extends Curve {
  @override
  double transform(double t) {
    return t < .5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
  }
}

class _SpinningLogoPainter extends CustomPainter {
  num angle;

  _SpinningLogoPainter({this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    Isomer.Isomer iso = new Isomer.Isomer(
        canvas: canvas, size: size, scale: 40, originY: size.height * 0.8);

    var radians = _toRadians(angle);
    var rotateOrigin = new Isomer.Point(1.5, 1.5);

    var cube = () => iso.add(
        new Isomer.Shape.prism(new Isomer.Point(0, 0, _Z_OFFSET), 3, 3, 3)
            .rotateZ(rotateOrigin, radians),
        _grey);
    var back = (z) => iso.add(
        new Isomer.Shape.prism(new Isomer.Point(2, 1, z + _Z_OFFSET),
                2 - (2 * _THIRD), 1, _THIRD)
            .rotateZ(rotateOrigin, radians),
        _pink);
    var middle = (z) => iso.add(
        new Isomer.Shape.prism(new Isomer.Point(1, -_THIRD, z + _Z_OFFSET), 1,
                4 - _THIRD, _THIRD)
            .rotateZ(rotateOrigin, radians),
        _pink);
    var front = (z) => iso.add(
        new Isomer.Shape.prism(new Isomer.Point(-_THIRD, 1, z + _Z_OFFSET),
                2 - (2 * _THIRD), 1, _THIRD)
            .rotateZ(rotateOrigin, radians),
        _pink);
    var north = () => iso.add(
        new Isomer.Shape.prism(
                new Isomer.Point(1, -_THIRD, _Z_OFFSET), 1, _THIRD, 3)
            .rotateZ(rotateOrigin, radians),
        _pink);
    var south = () => iso.add(
        new Isomer.Shape.prism(new Isomer.Point(1, 3, _Z_OFFSET), 1, _THIRD, 3)
            .rotateZ(rotateOrigin, radians),
        _pink);
    var east = () => iso.add(
        new Isomer.Shape.prism(
                new Isomer.Point(-_THIRD, 1, _Z_OFFSET), _THIRD, 1, 3)
            .rotateZ(rotateOrigin, radians),
        _pink);
    var west = () => iso.add(
        new Isomer.Shape.prism(new Isomer.Point(3, 1, _Z_OFFSET), _THIRD, 1, 3)
            .rotateZ(rotateOrigin, radians),
        _pink);

    if (_inRange(_MAGIC_ANGLE, angle)) {
      front(-_THIRD);
      middle(-_THIRD);
      back(-_THIRD);
    } else {
      back(-_THIRD);
      middle(-_THIRD);
      front(-_THIRD);
    }
    if (_inRange(_MAGIC_ANGLE - 90, angle)) {
      north();
    } else {
      south();
    }
    if (_inRange(_MAGIC_ANGLE, angle)) {
      east();
    } else {
      west();
    }
    cube();
    if (_inRange(_MAGIC_ANGLE, angle)) {
      west();
    } else {
      east();
    }
    if (_inRange(_MAGIC_ANGLE - 90, angle)) {
      south();
    } else {
      north();
    }
    if (_inRange(_MAGIC_ANGLE, angle)) {
      front(3);
      middle(3);
      back(3);
    } else {
      back(3);
      middle(3);
      front(3);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    _SpinningLogoPainter painter = oldDelegate;
    return painter.angle != angle;
  }
}
