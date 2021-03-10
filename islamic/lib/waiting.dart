import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class WaitingPage extends StatefulWidget {
  bool onLoop = false;
  Artboard artboard;
  RiveAnimationController controller;

  @override
  WaitingPageState createState() => WaitingPageState();

  void finish(Function onFinish) {
    artboard.addController(
        controller = CallbackAnimation('end', callback: onFinish));
  }
}

class WaitingPageState extends State<WaitingPage> {

  @override
  void initState() {
    super.initState();
    rootBundle.load('anims/islam-logo.riv').then(
      (data) async {
        final file = RiveFile();
        if (file.import(data)) {
          widget.artboard = file.mainArtboard;
          widget.artboard.addController(CallbackAnimation('start', callback:()=>widget.onLoop = true));
          widget.artboard.addController(widget.controller = SimpleAnimation('idle'));
          setState(() {});
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: widget.artboard == null
            ? const SizedBox()
            : Rive(
                artboard: widget.artboard,
                fit: BoxFit.none,
              ),
      ),
    );
  }
}

class CallbackAnimation extends SimpleAnimation {
  CallbackAnimation(
    String animationName, {
    @required this.callback,
    double mix,
  }) : super(animationName, mix: mix);

  final Function callback;

  @override
  void apply(RuntimeArtboard artboard, double elapsedSeconds) {
    // Apply the animation to the artboard with the appropriate level of mix
    instance.animation.apply(instance.time, coreContext: artboard, mix: mix);
    // If false, the animation has ended (it doesn't loop)
    if (!instance.advance(elapsedSeconds)) {
      // _onCompleted(callback);
      callback();
    }
  }
}
