import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/app_info.dart';
import 'data/app_state.dart';
import 'screens/splash/splash_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInfo.load();
  // Android 15+ forces edge-to-edge; opt in everywhere so older Android
  // versions draw the same (every screen already pads via SafeArea).
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // Bundled fonts are SIL OFL — the license must ship with them, so list
  // it on the "Lisansları görüntüle" page of the About dialog.
  LicenseRegistry.addLicense(() async* {
    for (final (family, file) in const [
      ('Inter', 'Inter-OFL.txt'),
      ('Bricolage Grotesque', 'BricolageGrotesque-OFL.txt'),
      ('Caveat', 'Caveat-OFL.txt'),
      ('Roboto', 'Roboto-OFL.txt'),
    ]) {
      yield LicenseEntryWithLineBreaks(
        [family],
        await rootBundle.loadString('assets/fonts/$file'),
      );
    }
  });
  runApp(const CepteStajApp());
}

class CepteStajApp extends StatefulWidget {
  const CepteStajApp({super.key});

  @override
  State<CepteStajApp> createState() => _CepteStajAppState();
}

class _CepteStajAppState extends State<CepteStajApp>
    with WidgetsBindingObserver {
  late final AppState _state;

  @override
  void initState() {
    super.initState();
    _state = AppState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Flush any pending debounced write before the OS can kill the process.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _state.saveNow();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>.value(
      value: _state,
      child: Consumer<AppState>(
        builder: (context, state, _) {
          return MaterialApp(
            title: 'Cepte Staj',
            debugShowCheckedModeBanner: false,
            locale: const Locale('tr', 'TR'),
            supportedLocales: const [Locale('tr', 'TR')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: state.isDarkTheme ? AppTheme.dark() : AppTheme.light(),
            // Most tabs have no AppBar, so nothing else sets the status /
            // nav bar icon colour — without this they stay white on the
            // light theme's cream background under Android edge-to-edge.
            builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
              value: (state.isDarkTheme
                      ? SystemUiOverlayStyle.light
                      : SystemUiOverlayStyle.dark)
                  .copyWith(
                    statusBarColor: Colors.transparent,
                    systemNavigationBarColor: Colors.transparent,
                    systemNavigationBarContrastEnforced: false,
                  ),
              child: MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(state.textScale)),
                child: child!,
              ),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
