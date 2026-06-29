library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'context/context.dart';
import 'package:provider/provider.dart';
import 'views/home.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class Root extends StatefulWidget {
  final AppContext appContext;

  const Root({super.key, required this.appContext});

  @override
  State<StatefulWidget> createState() => _RootState();

  static Future<void> create() async {
    AppContext appContext = AppContext();
    WidgetsFlutterBinding.ensureInitialized();
    await appContext.init();
    runApp(
      MaterialApp(
        title: "3ox",
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(useMaterial3: true),
        scrollBehavior: AppScrollBehavior(),
        debugShowCheckedModeBanner: false,
        home: Root(appContext: appContext),
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
    return ChangeNotifierProvider<AppContext>(
      create: (context) => widget.appContext,
      child: HomeView(),
    );
  }
}
