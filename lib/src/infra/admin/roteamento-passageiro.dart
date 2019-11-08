import 'package:flutter/material.dart';
import 'package:Fluttaxi/src/pages/passenger-page/pages.dart';

final routesPassageiroConfig = <String, WidgetBuilder>{
  "/intro": (BuildContext context) => IntroPage(),
  "/account": (BuildContext context) => AccountPage(),
  "/recoverypass": (BuildContext context) => RecoveryPassPage(),
  "/hometab": (BuildContext context) => HomeTabPage(),

  /* "/home": (BuildContext context) => HomeTab(),
  "/search": (BuildContext context) => SearchPage(),
  "/filter": (BuildContext context) => FilterPage(),
  "/comment": (BuildContext context) => CommentPage(),
  "/cart": (BuildContext context) => CartPage(),
  "/delivery": (BuildContext context) => DeliveryPage(),
  "/payment": (BuildContext context) => PaymentPage(),
  "/history": (BuildContext context) => HistoryPage(),
  "/history2": (BuildContext context) => HistoryPage(
    profileRedirect: true,
  ),
  "/favorites": (BuildContext context) => FavoritesPage(),
  "/address": (BuildContext context) => AddressPage(),*/
};

class NavigationPagesPassageiro {
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
