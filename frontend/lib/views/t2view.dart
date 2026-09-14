// Le tableau 2 représente un tableau avec une pomme

import 'package:flutter/material.dart';
import 'package:frontend/tableau/tableau.dart';
import 'package:frontend/tableau/t2.dart';
import 'package:rive/rive.dart';

class Tableau2 extends StatefulWidget {
  const Tableau2({super.key});

  @override
  State<StatefulWidget> createState() => Tableau2State();
}

class Tableau2State extends State<StatefulWidget>
    with TickerProviderStateMixin, Tableau, T2 {
  final ScrollController _scrollController = ScrollController();

  @override
  String get tableauName => 'T2';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!tableauInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Material(
      child: NotificationListener(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            print(
              'Scroll ended at position: ${_scrollController.position.pixels}',
            );
          }
          print('Notification: $notification');
          return false;
        },
        child: GestureDetector(
          onTap: handleTap,
          child: Stack(
            children: [
              RiveWidget(
                controller: appleRiveController!,
                fit: Fit.cover,
                layoutScaleFactor: 1 / 3,
                drawOrder: 0,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      return Container(height: 10000, width: 1);
                    },
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
