import 'package:flutter/material.dart';

class WaitingPage extends StatefulWidget {
  bool onLoop = false;
  Artboard artboard;
  RiveAnimationController controller;

  @override
  WaitingPageState createState() => WaitingPageState();
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
