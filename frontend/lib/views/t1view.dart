// Le tableau 0 représente un tableau qui souvre

import 'package:flutter/material.dart';
import 'package:frontend/tableau/tableau.dart';
import 'package:frontend/tableau/t1.dart';
import 'package:rive/rive.dart';

class Tableau1 extends StatefulWidget {
  const Tableau1({super.key});

  @override
  State<StatefulWidget> createState() => Tableau1State();
}

class Tableau1State extends State<StatefulWidget>
    with TickerProviderStateMixin, Tableau, T1 {
  @override
  String get tableauName => 'T1';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: handleTap,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: getImageFromAsset('gemini_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Positioned(
                width: 150,
                height: 150,
                bottom: MediaQuery.of(context).size.height / 3.5,
                left: MediaQuery.of(context).size.width / 4.5,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: handleTapApple,
                    child: Builder(
                      builder: (context) {
                        if (appleRiveController == null) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return RiveWidget(
                          controller: appleRiveController!,
                          fit: Fit.layout,
                          layoutScaleFactor: 1 / 3,
                          drawOrder: 0,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
