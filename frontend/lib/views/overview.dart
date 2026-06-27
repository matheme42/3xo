import 'package:frontend/widgets/glass_container.dart';
import 'package:flutter/material.dart';

import '../types/musique.dart';

class MusicOverview extends StatelessWidget {
  final List<Musique> music;
  final PageController pageController;

  const MusicOverview({
    super.key,
    required this.music,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    int currentMusicIndex = pageController.hasClients
        ? pageController.page?.round() ?? 0
        : 0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          flex: 2,
          child: FractionallySizedBox(
            heightFactor: 1,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 16.0,
                  left: 16.0,
                  right: 16.0,
                ),
                child: Text(
                  "En écoute : ${music[currentMusicIndex].title} (Piste ${currentMusicIndex + 1})",
                  style: TextStyle(fontSize: 28),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 15,
          child: FractionallySizedBox(
            widthFactor: 0.8,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: GlassContainer(
                  border: BoxBorder.all(color: Colors.white10, width: 0),
                  child: Container(
                    margin: EdgeInsets.all(32.0),
                    color: Colors.transparent,
                    child: PageView(
                      key: const Key('music_overview_page_view'),
                      controller: pageController,
                      allowImplicitScrolling: true,
                      pageSnapping: true,
                      padEnds: true,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (value) => pageController.animateToPage(
                        value,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.linear,
                      ),
                      children: music.map((musique) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // si la largeur n'est pas suffissante on n'affiche que le nom et la pochette d'album
                              // le texte sera afficher comme un tooltip
                              if (constraints.maxWidth < 600) {
                                return Tooltip(
                                  message: musique.lyricsOrDescription ?? "",
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 32.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        constraints.maxHeight < 200
                                            ? SizedBox.shrink()
                                            : Text(
                                                musique.album,
                                                style: TextStyle(
                                                  fontSize: 48,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(32.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 10.0,
                                                  offset: Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(32.0),
                                              child: Image.network(
                                                musique.coverUrl,
                                                fit: BoxFit.fill,
                                                webHtmlElementStrategy:
                                                    WebHtmlElementStrategy
                                                        .prefer,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        right: 32.0,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          constraints.maxHeight < 200
                                              ? SizedBox.shrink()
                                              : Text(
                                                  musique.album,
                                                  style: TextStyle(
                                                    fontSize: 48,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(32.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black26,
                                                    blurRadius: 10.0,
                                                    offset: Offset(0, 5),
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(32.0),
                                                child: Image.network(
                                                  musique.coverUrl,
                                                  fit: BoxFit.fill,
                                                  webHtmlElementStrategy:
                                                      WebHtmlElementStrategy
                                                          .prefer,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                        ],
                                      ),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    heightFactor: 0.9,
                                    // VerticalDivider with shade gradient effect on both sides
                                    child: Container(
                                      width: 1,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.white54,
                                            Colors.white,
                                            Colors.white54,
                                            Colors.transparent,
                                          ],
                                          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: SizedBox.expand(
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 16.0,
                                          ),
                                          child: SelectableText(
                                            musique.lyricsOrDescription ?? "",
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
