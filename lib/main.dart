import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flyweb/i18n/AppLanguage.dart';
import 'package:flyweb/i18n/i18n.dart';
import 'package:flyweb/src/enum/connectivity_status.dart';
import 'package:flyweb/src/helpers/ConnectivityService.dart';
import 'package:flyweb/src/helpers/SharedPref.dart';
import 'package:flyweb/src/models/ad_state.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/pages/SplashScreen.dart';
import 'package:flyweb/src/services/theme_manager.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Ads
  final initFuture = MobileAds.instance.initialize();

  final adState = AdState(initFuture);
  SharedPref sharedPref = SharedPref();
  Settings settings = new Settings();

  await GlobalConfiguration().loadFromAsset("configuration");
  AppLanguage appLanguage = AppLanguage();
  await appLanguage.fetchLocale();

  /*  For Enable WebRTC (Remove this comment)
  await Permission.camera.request();
  await Permission.mæicrophone.request();
  */

  try {
    var set = await sharedPref.read("settings");
    if (set != null) {
      settings = Settings.fromJson(set);
    }
  } on Exception catch (exception) {} catch (Excepetion) {}

  return runApp(ChangeNotifierProvider<ThemeNotifier>(
    create: (_) => new ThemeNotifier(),
    child: Provider.value(
        value: adState,
        builder: (context, child) =>
            MyApp(appLanguage: appLanguage, settings: settings)),
  ));
}

class MyApp extends StatelessWidget {
  final AppLanguage appLanguage;
  final Settings settings;

  MyApp({this.appLanguage, this.settings});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppLanguage>(
      create: (_) => appLanguage,
      child: Consumer<AppLanguage>(builder: (context, model, child) {
        return StreamProvider<ConnectivityStatus>(
            create: (context) =>
            ConnectivityService().connectionStatusController.stream,
            child: Consumer<ThemeNotifier>(
                builder: (context, theme, _) => MaterialApp(
                    theme: theme.getTheme(),
                    locale: model.appLocal,
                    localizationsDelegates: [
                      I18n.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                    ],
                    supportedLocales: I18n.delegate.supportedLocales,
                    debugShowCheckedModeBanner: false,
                    home: SplashScreen(settings: this.settings))));
      }),
    );
  }
}
