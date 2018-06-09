import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gift_list/components/loading_stack.dart';
import 'package:gift_list/components/spinning_logo.dart';
import 'package:gift_list/services/auth_service.dart';
import 'package:gift_list/services/loader.dart';

final AuthService _authService = AuthService.instance;

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => new _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  AnimationController _logoAnimationController;
  AnimationController _opacityAnimationController;
  Animation _opacityAnimation;
  AnimationController _progressAnimationController;
  Animation _progressAnimation;
  double _startProgress;
  double _targetProgress;

  void _setProgress(double progress) {
    _startProgress = _targetProgress == null
        ? 0.0
        : (((_targetProgress - _startProgress) * _progressAnimation.value) +
            _startProgress);
    _targetProgress = progress;
    if (_startProgress != _targetProgress)
      _progressAnimationController.forward(from: 0.0);
  }

  void _load(FirebaseUser user) async {
    print("Loading as ${user.displayName}...");

    await for (double progress in load()) {
      setState(() => _setProgress(progress));
    }
  }

  @override
  void initState() {
    super.initState();
    _logoAnimationController = new AnimationController(
        duration: const Duration(seconds: 4), vsync: this)
      ..repeat();
    _opacityAnimationController = new AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _opacityAnimation = new CurvedAnimation(
        parent: _opacityAnimationController, curve: Curves.easeInOut)
      ..addListener(() {
        setState(() {});
      });
    _progressAnimationController = new AnimationController(
        duration: const Duration(seconds: 1), vsync: this);
    _progressAnimation = new CurvedAnimation(
        parent: _progressAnimationController, curve: Curves.easeOut)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && _targetProgress == 1.0) {
          print("Loaded!");
          NavigatorState navigator = Navigator.of(context);
          navigator.popUntil((_) => !navigator.canPop());
          navigator.pushReplacementNamed("/");
        }
      });

    _authService.currentUser().then((user) {
      if (user != null) {
        _load(user);
      } else {
        _opacityAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _opacityAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  void _signIn(UserSignInHandler signInHandler) async {
    _opacityAnimationController.reverse();
    FirebaseUser user = await signInHandler();
    if (user != null) {
      print("Signed in as ${user.email}!");
      _load(user);
    } else {
      _opacityAnimationController.forward();
      print("Unable to sign in!");
    }
  }

  Widget _buildSignInButton(String provider, VoidCallback onPressed) {
    return new Container(
      constraints: const BoxConstraints(maxWidth: 250.0),
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: new RaisedButton(
        color: Colors.white,
        onPressed: onPressed,
        child: new Row(
          children: <Widget>[
            new Image.asset(
              "assets/${provider.toLowerCase()}.png",
              width: 24.0,
              height: 24.0,
            ),
            new Expanded(
              child: new Text(
                "Sign in with $provider",
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSignInArea() {
    double progress;
    if (_targetProgress != null) {
      progress =
          ((_targetProgress - _startProgress) * _progressAnimation.value) +
              _startProgress;
    }

    return new LoadingStack(
      opacityAnimation: _opacityAnimation,
      progress: progress,
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildSignInButton(
              "Google",
              _opacityAnimation.value > 0
                  ? () => _signIn(_authService.signInWithGoogle)
                  : null),
          _buildSignInButton(
              "Facebook",
              _opacityAnimation.value > 0
                  ? () => _signIn(_authService.signInWithFacebook)
                  : null),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        child: new Center(
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new SpinningLogo(animation: _logoAnimationController),
              _buildSignInArea()
            ],
          ),
        ),
      ),
    );
  }
}
