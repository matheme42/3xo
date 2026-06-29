import 'package:flutter/material.dart';
import 'package:frontend/context/context.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late AppContext appContext;
  @override
  void initState() {
    super.initState();
    appContext = Provider.of<AppContext>(context, listen: false);
  }

  void _handleTap() {
    // Exemple d'action lors du tap : envoyer un message via WebSocket
    appContext.websocket.sendMessage('User tapped on the screen!');
    appContext.player.play(
      vsync: this,
      loop: true,
      url: 'assets/filante_ambiance.mp3',
      fadeIn: true,
      restartIfAlreadyPlaying: false,
    );
  }

  void _handleTapApple() {
    // Exemple d'action lors du tap sur la pomme : envoyer un message via WebSocket
    appContext.websocket.sendMessage('User tapped on the apple!');
    appContext.bruitagePlayer.play(
      vsync: this,
      url: 'assets/bruitage1.mp3',
      loop: false,
      fadeIn: false,
      restartIfAlreadyPlaying: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('gemini_background.png'),
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
                    onTap: _handleTapApple,
                    child: RiveWidget(
                      controller: appContext.appleRiveController!,
                      fit: Fit.layout,
                      layoutScaleFactor: 1 / 3,
                      drawOrder: 0,
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
