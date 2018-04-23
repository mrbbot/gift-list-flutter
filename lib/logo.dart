import 'package:flutter/material.dart';
import 'package:isomer/isomer.dart' as Isomer;
import 'dart:math' as math;

class Logo extends AnimatedWidget {
  static final _tween = new CurveTween(curve: new EaseInOutCurve());

  Logo({Key key, Animation<double> animation})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return new AspectRatio(
      aspectRatio: 1.0,
      child: new ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: new CustomPaint(
          painter: new LogoPainter(angle: _tween.evaluate(animation) * 360.0),
        ),
      ),
    );
  }
}

final Isomer.Color pink = new Isomer.Color(201, 26, 84);
final Isomer.Color grey = new Isomer.Color(51, 51, 51);

const MAGIC_ANGLE = 134.5;
const THIRD = 1 / 3;
const Z_OFFSET = -0.2;

bool inRange(start, angle) => start <= angle && angle < (start + 180);

double toRadians(degrees) => degrees * math.pi / 180;

class EaseInOutCurve extends Curve {
  @override
  double transform(double t) {
    return t < .5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
  }
}

class LogoPainter extends CustomPainter {
  num angle;

  LogoPainter({this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    Isomer.Isomer iso = new Isomer.Isomer(
        canvas: canvas, size: size, scale: 40, originY: size.height * 0.8);

    var radians = toRadians(angle);
    var rotateOrigin = new Isomer.Point(1.5, 1.5);

    var cube = () => iso.add(
        new Isomer.Shape.prism(new Isomer.Point(0, 0, Z_OFFSET), 3, 3, 3)
            .rotateZ(rotateOrigin, radians),
        grey);
    var back = (z) => iso.add(
        new Isomer.Shape.prism(
                new Isomer.Point(2, 1, z + Z_OFFSET), 2 - (2 * THIRD), 1, THIRD)
            .rotateZ(rotateOrigin, radians),
        pink);
    var middle = (z) => iso.add(
        new Isomer.Shape.prism(
                new Isomer.Point(1, -THIRD, z + Z_OFFSET), 1, 4 - THIRD, THIRD)
            .rotateZ(rotateOrigin, radians),
        pink);
    var front = (z) => iso.add(
        new Isomer.Shape.prism(new Isomer.Point(-THIRD, 1, z + Z_OFFSET),
                2 - (2 * THIRD), 1, THIRD)
            .rotateZ(rotateOrigin, radians),
        pink);
    var north = () => iso.add(
        new Isomer.Shape.prism(
                new Isomer.Point(1, -THIRD, Z_OFFSET), 1, THIRD, 3)
            .rotateZ(rotateOrigin, radians),
        pink);
    var south = () => iso.add(
        new Isomer.Shape.prism(new Isomer.Point(1, 3, Z_OFFSET), 1, THIRD, 3)
            .rotateZ(rotateOrigin, radians),
        pink);
    var east = () => iso.add(
        new Isomer.Shape.prism(
                new Isomer.Point(-THIRD, 1, Z_OFFSET), THIRD, 1, 3)
            .rotateZ(rotateOrigin, radians),
        pink);
    var west = () => iso.add(
        new Isomer.Shape.prism(new Isomer.Point(3, 1, Z_OFFSET), THIRD, 1, 3)
            .rotateZ(rotateOrigin, radians),
        pink);

    if (inRange(MAGIC_ANGLE, angle)) {
      front(-THIRD);
      middle(-THIRD);
      back(-THIRD);
    } else {
      back(-THIRD);
      middle(-THIRD);
      front(-THIRD);
    }
    if (inRange(MAGIC_ANGLE - 90, angle)) {
      north();
    } else {
      south();
    }
    if (inRange(MAGIC_ANGLE, angle)) {
      east();
    } else {
      west();
    }
    cube();
    if (inRange(MAGIC_ANGLE, angle)) {
      west();
    } else {
      east();
    }
    if (inRange(MAGIC_ANGLE - 90, angle)) {
      south();
    } else {
      north();
    }
    if (inRange(MAGIC_ANGLE, angle)) {
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
    LogoPainter painter = oldDelegate;
    return painter.angle != angle;
  }
}
