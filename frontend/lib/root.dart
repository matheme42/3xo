library;

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/router.dart';
import 'package:frontend/views/t1view.dart';
import 'package:web/web.dart' as html;
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
  bool isWebGLSupported = true;

  @override
  void initState() {
    super.initState();
    _checkWebGL();
  }

  void _checkWebGL() {
    if (kIsWeb) {
      try {
        final canvas = html.HTMLCanvasElement();
        // On tente d'obtenir le contexte WebGL
        final gl =
            canvas.getContext('webgl') ??
            canvas.getContext('experimental-webgl') ??
            canvas.getContext('webgl2');

        if (gl == null) {
          setState(() {
            isWebGLSupported = false;
          });
        }
      } catch (e) {
        setState(() {
          isWebGLSupported = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isWebGLSupported) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.gpp_bad_rounded, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text(
                  "WebGL est désactivé",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Cette application nécessite l'accélération matérielle pour afficher les animations.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child ?? const SizedBox.shrink();
  }
}
