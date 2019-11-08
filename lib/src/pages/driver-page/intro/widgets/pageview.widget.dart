import 'package:flutter/material.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';

class PageviewWidget {
  static PageViewModel buildViewModel(
          String bubble, String urlImage, String text) =>
      PageViewModel(
          pageColor: Colors.white,
          bubbleBackgroundColor: Colors.amber.withOpacity(0.1),
          bubble: Image.asset(bubble),
          body: Center(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(""),
          mainImage: Image.asset(
            urlImage,
            alignment: Alignment.center,
            width: 400,
          ));
}
