library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend/router.dart';
import 'package:frontend/views/t1view.dart';
import 'context/context.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class Root extends StatefulWidget {
  final AppContext appContext;

  const Root({super.key, required this.appContext, this.child});

  final Widget? child;

  @override
  State<StatefulWidget> createState() => _RootState();

  static Future<void> create() async {
    AppContext appContext = AppContext();
    usePathUrlStrategy();
    WidgetsFlutterBinding.ensureInitialized();
    await appContext.init();
    runApp(
      MaterialApp(
        title: "3ox",
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: ChangeNotifierProvider<AppContext>(
              create: (context) => appContext,
              child: Root(appContext: appContext, child: child),
            ),
          );
        },
        initialRoute: '/',
        routes: {'/': (context) => AppRouter()},
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(useMaterial3: true),
        scrollBehavior: AppScrollBehavior(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class _RootState extends State<Root> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox.shrink();
  }
}
