// Le tableau 0 représente un tableau qui souvre

import 'package:flutter/material.dart';
import 'package:frontend/tableau/tableau.dart';
import 'package:frontend/tableau/t1.dart';
import 'package:rive/rive.dart';

class Tableau0 extends StatefulWidget {
  const Tableau0({super.key});

  @override
  State<StatefulWidget> createState() => Tableau0State();
}

class Tableau0State extends State<StatefulWidget>
    with TickerProviderStateMixin, Tableau, T1 {
  @override
  Widget build(BuildContext context) {
    super.build(context); // Call the build method from the Tableau mixin
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
          body: Stack(children: [
            
            ],
          ),
        ),
      ),
    );
  }
}
