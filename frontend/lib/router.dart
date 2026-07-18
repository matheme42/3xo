import 'package:flutter/material.dart';
import 'package:frontend/context/context.dart';
import 'package:frontend/views/t0view.dart';
import 'package:provider/provider.dart';
import 'views/t1view.dart';

class AppRouter extends StatelessWidget {
  static const String initialRoute = '/';

  const AppRouter({super.key});

  static Map<String, WidgetBuilder> get routes {
    return {'/T1': (context) => const Tableau1()};
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppContext>(
      builder: (context, appContext, child) {
        return Navigator(
          pages: [
            if (appContext.currentRoute == 'T1')
              MaterialPage(child: const Tableau1()),
            if (appContext.currentRoute == 'T0')
              MaterialPage(child: const Tableau0()),
          ],
          onPopPage: (route, result) {
            if (!route.didPop(result)) {
              return false;
            }
            return true;
          },
        );
      },
    );
  }
}
