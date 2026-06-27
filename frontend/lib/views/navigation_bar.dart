import 'package:frontend/context.dart';
import 'package:frontend/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeNavigationBar extends StatelessWidget {
  final int currentMusicIndex;
  final PageController pageController;

  const HomeNavigationBar({
    super.key,
    required this.currentMusicIndex,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppContext>(
      builder: (context, appContext, child) {
        return SizedBox(
          width: 230,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: GlassContainer(
                borderRadius: BorderRadius.zero,
                border: Border.all(color: Colors.white10, width: 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 32.0),
                      padding: const EdgeInsets.only(
                        top: 16.0,
                        left: 16.0,
                        right: 16.0,
                      ),
                      child: Text(
                        "5AD1KS // 3OX\nL'album ephemere",
                        style: TextStyle(fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: Material(
                        type: MaterialType.transparency,
                        child: ListView.builder(
                          itemCount: appContext.music.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    "${(index + 1).toString().padLeft(2, '0')} • ${appContext.music[index].title} (3:30)",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: index == currentMusicIndex
                                          ? Colors.white
                                          : Colors.white70,
                                      fontWeight: index == currentMusicIndex
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),

                                  subtitle: index == currentMusicIndex
                                      ? Container(
                                          height: 4.0,
                                          decoration: BoxDecoration(
                                            color: Colors.white30,

                                            borderRadius: BorderRadius.circular(
                                              2.0,
                                            ),
                                          ),
                                          child: FractionallySizedBox(
                                            widthFactor: 0.8,
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              height: 4.0,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(2.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.white54,
                                                    blurRadius: 4.0,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      : null,
                                  onTap: () {
                                    pageController.jumpToPage(index);
                                  },
                                ),
                                index != appContext.music.length - 1
                                    ? Align(
                                        alignment: Alignment.center,
                                        child: FractionallySizedBox(
                                          widthFactor: 0.8,
                                          child: Divider(
                                            color: Colors.white10,
                                            thickness: 1.0,
                                            height: 1.0,
                                          ),
                                        ),
                                      )
                                    : SizedBox.shrink(),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "© 2026 5AD1KS // 3OX",
                        style: TextStyle(fontSize: 10, color: Colors.white54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
