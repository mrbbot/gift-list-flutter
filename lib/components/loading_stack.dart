import 'package:flutter/material.dart';

class LoadingStack extends StatelessWidget {
  final Animation<double> opacityAnimation;
  final double progress;
  final Widget child;

  LoadingStack({
    @required this.opacityAnimation,
    this.progress,
    @required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return new Stack(
      alignment: Alignment.center,
      children: <Widget>[
        new IgnorePointer(
          ignoring: (1 - opacityAnimation.value) < 1.0,
          child: new Opacity(
              opacity: 1 - opacityAnimation.value,
              child: new CircularProgressIndicator(
                value: progress,
              )),
        ),
        new IgnorePointer(
          ignoring: opacityAnimation.value < 1.0,
          child: new Opacity(
            opacity: opacityAnimation.value,
            child: child,
          ),
        ),
      ],
    );
  }
}
