import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

import 'localization.dart';
import 'models.dart';

class WaitingPage extends StatefulWidget {
  WaitingPageState page;

  @override
  WaitingPageState createState() {
    return page = WaitingPageState();
  }
}

class WaitingPageState extends State<WaitingPage> {
  int state = 0;
  Artboard artboard;
  RiveAnimationController controller;

  @override
  void initState() {
    super.initState();
    rootBundle.load('anims/islam-logo.riv').then(animLoaded);
  }

  animLoaded(ByteData data) async {
    await Localization.change(context, Prefs.locale);
    final file = RiveFile();
    if (file.import(data)) {
      artboard = file.mainArtboard;
      artboard.addController(SimpleAnimation('start'));
      artboard.addController(SimpleAnimation('idle'));
      Future.delayed(const Duration(milliseconds: 500), () => state = 2);
      state = 1;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: state < 1
            ? const SizedBox()
            : Rive(
                artboard: artboard,
                fit: BoxFit.none,
              ),
      ),
    );
  }

  void end(Function onFinish) {
    artboard.addController(SimpleAnimation('end'));
    Future.delayed(const Duration(milliseconds: 700), () {
      state = 3;
      onFinish();
    });
  }
}

/* class CallbackAnimation extends SimpleAnimation {
  CallbackAnimation(
    String animationName, {
    @required this.callback,
    double mix,
  }) : super(animationName, mix: mix);

  final Function callback;

  @override
  void apply(RuntimeArtboard artboard, double elapsedSeconds) {
    print(animationName);
    // Apply the animation to the artboard with the appropriate level of mix
    instance.animation.apply(instance.time, coreContext: artboard, mix: mix);
    // If false, the animation has ended (it doesn't loop)
    if (!instance.advance(elapsedSeconds)) {
      // _onCompleted(callback);
      callback();
    }
  }
} */
