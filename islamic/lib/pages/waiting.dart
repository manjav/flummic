import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smartlook/flutter_smartlook.dart';
import 'package:islamic/models.dart';
import 'package:islamic/utils/localization.dart';
import 'package:rive/rive.dart';

class WaitingPage extends StatefulWidget {
  @override
  createState() => WaitingPageState();
}

class WaitingPageState extends State<WaitingPage> {
  Artboard? artboard;
  RiveAnimationController? controller;

  @override
  void initState() {
    super.initState();
    rootBundle.load('anims/islam-logo.riv').then(animLoaded);
    Configs.instance.addListener(() async {
      if (Configs.instance.state == LoadState.loaded) {
        artboard!.addController(SimpleAnimation('end'));
        await Future.delayed(const Duration(milliseconds: 700));
        Configs.instance.setState(LoadState.finalized);
      }
    });
  }

  animLoaded(ByteData data) {
    final riveData = RiveFile.import(data);
    artboard = riveData.mainArtboard;
    artboard!.addController(SimpleAnimation('start'));
    artboard!.addController(SimpleAnimation('idle'));
    // Future.delayed(const Duration(milliseconds: 500), () => state = 2);
  }

  @override
  Widget build(BuildContext context) {
    _loadServices();
    return AnimatedBuilder(
        animation: Configs.instance,
        builder: (ctx, w) => Stack(alignment: Alignment.center, children: [
              Configs.instance.state == LoadState.error
                  ? _error()
                  : _animation(),
            ]));
  }

  _loadServices() {
    if (Configs.instance.state != LoadState.none) return;
    var appsFlyerOptions = {
      "afDevKey": "YBThmUqaiHZYpiSwZ3GQz4",
      "afAppId": "com.gerantech.muslim.holy.quran",
      "isDebug": false
    };

    var appsflyerSdk = AppsflyerSdk(appsFlyerOptions);
    appsflyerSdk.initSdk(
        registerConversionDataCallback: true,
        registerOnAppOpenAttributionCallback: true,
        registerOnDeepLinkingCallback: true);

    Prefs.init(context, () {
      _initSmartlook();
      Configs.initialize();
      Configs.instance.addListener(_onConfigsStateChange);
      Settings.instance.setTheme(ThemeMode.values[Prefs.themeMode]);
    });
  }

  _initSmartlook() async {
    if (Prefs.numRuns >= 1) return;
    // Smartlook.instance.log.enableLogging();
    await Smartlook.instance.preferences
        .setProjectKey("6488995bc0e02e3d4defab25862fd68ebf40a071");
    await Smartlook.instance.start();
    // Smartlook.instance.registerIntegrationListener(CustomIntegrationListener());
    await Smartlook.instance.preferences.setWebViewEnabled(true);
  }

  _onConfigsStateChange() {
    if (Configs.instance.state == LoadState.initialized) {
      Localization.change(Prefs.locale, onDone: (l) {
        Settings.instance.setLocale(l);
        Configs.instance.load();
      });
    }
  }

  _animation() {
    if (artboard == null) return SizedBox();
    return Rive(artboard: artboard!, fit: BoxFit.none);
  }

  _error() {
    return Positioned(
        bottom: 64,
        child: Column(children: [
          Text("No internet connection!"),
          TextButton(
              child: Row(children: [
                Icon(Icons.sync),
                SizedBox(width: 10),
                Text("Try Again")
              ]),
              onPressed: () {
                Configs.instance.setState(LoadState.none);
                Configs.initialize();
              })
        ]));
  }
}
