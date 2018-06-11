import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  EmptyState({
    this.icon,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final width = MediaQuery.of(context).size.width;

    return new Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Icon(
              icon,
              size: 100.0,
              color: textTheme.display3.color,
            ),
            new Container(
              margin: const EdgeInsets.only(top: 8.0),
              width: width * 0.5,
              child: new Text(message,
                  textAlign: TextAlign.center,
                  style:
                      textTheme.body1.copyWith(color: textTheme.display3.color)),
            )
          ],
        ),
      ),
    );
  }
}
