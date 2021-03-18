import 'package:flutter/material.dart';
class PersonPage extends StatefulWidget {
  String title = "";
  @override
  PersonPageState createState() => PersonPageState();
}

class PersonPageState extends State<PersonPage>
    with SingleTickerProviderStateMixin {
  AnimationController fabAnimController;

  @override
  void initState() {
    super.initState();
    // widget.title = AppLocalizations.of(context).fab_tafsir;
    fabAnimController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(AppLocalizations.of(context).translation_title),
            actions: [
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: () => Navigator.pop(context),
              )
            ],
            automaticallyImplyLeading: false,
          ),
          floatingActionButton: SpeedDial(
            child: AnimatedIcon(
              icon: AnimatedIcons.add_event,
              progress: fabAnimController,
            ),
            openBackgroundColor: Colors.redAccent,
            closedBackgroundColor: Colors.redAccent,
            // closedForegroundColor: Colors.black,
            // labelsStyle: /* Your label TextStyle goes here */,
            // controller: /* Your custom animation controller goes here */,
            onPressed: handleOnPressed,
            speedDialChildren: <SpeedDialChild>[
              SpeedDialChild(
                child: Icon(
                  Icons.arrow_back,
                ),
                foregroundColor: Colors.black,
                // backgroundColor: Colors.red,
                label: AppLocalizations.of(context).fab_quran,
                onPressed: () => speedChildPressed(0),
              ),
              SpeedDialChild(
                child: Icon(Icons.arrow_back),
                foregroundColor: Colors.black,
                // backgroundColor: Colors.yellow,
                label: AppLocalizations.of(context).fab_translate,
                onPressed: () => speedChildPressed(1),
              ),
              SpeedDialChild(
                child: Icon(Icons.arrow_back),
                foregroundColor: Colors.black,
                // backgroundColor: Colors.green,
                label: AppLocalizations.of(context).fab_tafsir,
                onPressed: () => speedChildPressed(2),
              ),
              //  Your other SpeeDialChildren go here.
            ],
          ),
        ));
  }

  void handleOnPressed(bool isOpen) {
    setState(() {
      isOpen ? fabAnimController.forward() : fabAnimController.reverse();
    });
  }

  void speedChildPressed(int i) {}
}
