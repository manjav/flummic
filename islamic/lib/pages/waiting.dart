import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

import '../utils/localization.dart';
import '../models.dart';

class WaitingPage extends StatefulWidget {
  late WaitingPageState page;

  @override
  WaitingPageState createState() => page = WaitingPageState();
}

class WaitingPageState extends State<WaitingPage> {
  int state = 0;
  late Artboard artboard;
  late RiveAnimationController controller;
  bool errorMode = false;
  Function? onRreload;

  @override
  void initState() {
    super.initState();
    rootBundle.load('anims/islam-logo.riv').then(animLoaded);
  }

  animLoaded(ByteData data) async {
    await Localization.change(context, Prefs.locale);
    final riveData = RiveFile.import(data);
    artboard = riveData.mainArtboard;
    artboard.addController(SimpleAnimation('start'));
    artboard.addController(SimpleAnimation('idle'));
    Future.delayed(const Duration(milliseconds: 500), () => state = 2);
    state = 1;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(alignment: Alignment.center, children: [
      state < 1
          ? const SizedBox()
          : Rive(
              artboard: artboard,
              fit: BoxFit.none,
            ),
      errorMode
          ? Positioned(
              bottom: 64,
              child: Column(children: [
                Text("net_alert".l()),
                TextButton(
                    child: Row(
                      children: [
                        Icon(Icons.sync_outlined),
                        SizedBox(width: 10),
                        Text("reload_l".l())
                      ],
                    ),
                    onPressed: onPressed)
              ]))
          : SizedBox()
    ]));
  }

  void end(Function onFinish) {
    artboard.addController(SimpleAnimation('end'));
    Future.delayed(const Duration(milliseconds: 700), () {
      state = 3;
      onFinish();
    });
  }

  void error(Function onRreload) {
    this.onRreload = onRreload;
    setState(() => errorMode = true);
  }

  void onPressed() {
    setState(() => errorMode = false);
    onRreload?.call();
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
