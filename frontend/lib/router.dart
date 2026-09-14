import 'package:flutter/material.dart';
import 'package:frontend/context/context.dart';
import 'package:frontend/views/t0view.dart';
import 'package:provider/provider.dart';
import 'views/t1view.dart';
import 'views/t2view.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppContext>(
      builder: (context, appContext, child) {
        return Navigator(
          pages: [
            if (appContext.currentRoute == 'T2')
              MaterialPage(child: const Tableau2()),
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
