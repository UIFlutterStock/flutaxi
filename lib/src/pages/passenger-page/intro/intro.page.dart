import 'package:flutter/material.dart';
import 'package:Fluttaxi/src/infra/infra.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';

import 'widgets/pageview.widget.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final pages = [
    PageviewWidget.buildViewModel(
        'assets/images/intro/pick.png',
        'assets/images/intro/1.png',
        'Your safe and simple travel platform.'),
    PageviewWidget.buildViewModel(
        'assets/images/intro/pick.png',
        'assets/images/intro/2.png',
        'Make your travels.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: IntroViewsFlutter(pages,
          doneText: const Text(
              'OK', style: TextStyle(fontWeight: FontWeight.bold)
          ),
          showNextButton: true,
          pageButtonsColor: Colors.black,
          pageButtonTextSize: 18,
          showBackButton: true,
          nextText: const Text(
            "NEXT", style: TextStyle(fontWeight: FontWeight.bold),),
          skipText: const Text(
              "SKIP", style: TextStyle(fontWeight: FontWeight.bold)),
          backText: const Text(
              "BACK", style: TextStyle(fontWeight: FontWeight.bold)),
          onTapSkipButton: () => NavigationPagesRace.goToAccount(context),
          onTapDoneButton: () => NavigationPagesRace.goToAccount(context),
          pageButtonTextStyles: const TextStyle(color: Colors.black)),
    ); //Material App
  }
}
