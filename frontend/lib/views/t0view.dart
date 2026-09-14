// Le tableau 0 représente un tableau qui souvre

import 'package:flutter/material.dart';
import 'package:frontend/tableau/tableau.dart';
import 'package:frontend/tableau/t0.dart';
import 'package:rive/rive.dart';

class Tableau0 extends StatefulWidget {
  const Tableau0({super.key});

  @override
  State<StatefulWidget> createState() => Tableau0State();
}

class Tableau0State extends State<StatefulWidget>
    with TickerProviderStateMixin, Tableau, T0 {
  @override
  String get tableauName => 'T0';

  @override
  Widget build(BuildContext context) {
    if (!tableauInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return GestureDetector(
      onTap: handleTap,
      child: RiveWidget(
        controller: appleRiveController!,
        fit: Fit.cover,
        layoutScaleFactor: 1 / 3,
        drawOrder: 0,
      ),
    );
  }
}
