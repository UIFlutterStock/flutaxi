import 'package:flutter/material.dart';
import 'package:Fluttaxi/src/pages/driver-page/pages.dart';

final routesRaceConfig = <String, WidgetBuilder>{
  "/intro": (BuildContext context) => IntroPage(),
  "/account": (BuildContext context) => AccountPage(),
  "/recoverypass": (BuildContext context) => RecoveryPassPage(),
  "/hometab": (BuildContext context) => HomeTabPage(),
};

class NavigationPagesRace {
  static void goToIntroReplacementNamed(BuildContext context) {
    Navigator.pushReplacementNamed(context, "/intro");
  }

  static void goToAccount(BuildContext context) {
    Navigator.pushReplacementNamed(context, "/account");
  }

  static void goToRecoveryPass(BuildContext context) {
    Navigator.pushNamed(context, "/recoverypass");
  }

  static void goToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, "/hometab");
  }

  static void goToStartViagem(BuildContext context) {
    Navigator.pushNamed(context, "/startviagem");
  }
}
