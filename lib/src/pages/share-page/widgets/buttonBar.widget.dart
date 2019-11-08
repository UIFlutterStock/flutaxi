import 'package:flutter/material.dart';

Widget buttonBar(changeDrawer, context) => Align(
      alignment: Alignment.topLeft,
      child: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: RawMaterialButton(
            onPressed: () {
              changeDrawer(context);
            },
            child: new Icon(
              Icons.sort,
              color: Colors.black,
              size: 25.0,
            ),
            shape: new CircleBorder(),
            elevation: 10.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(1.0),
          )),
    );
