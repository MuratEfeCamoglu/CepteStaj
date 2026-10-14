import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/app_info.dart';
import 'core/i18n.dart';
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
  bool? _lastDark;
  String? _lastLang;

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
  void didChangePlatformBrightness() => _state.onPlatformBrightnessChanged();

  /// Colors ([AppColors]) and strings ([t]) are read from static flags, not
  /// from an InheritedWidget, so a theme or language switch has to dirty
  /// every element itself — otherwise `const` widgets and pushed routes
  /// that don't listen to [AppState] keep the old colors/text (the dark
  /// theme used to come up half-light this way). Element state survives,
  /// so the user stays exactly where they were.
  void _rebuildAllIfAppearanceChanged(AppState state) {
    final dark = state.isDarkTheme;
    final lang = L10n.lang;
    final changed = (_lastDark != null && _lastDark != dark) || (_lastLang != null && _lastLang != lang);
    _lastDark = dark;
    _lastLang = lang;
    if (!changed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      void visit(Element e) {
        e.markNeedsBuild();
        e.visitChildren(visit);
      }

      (context as Element).visitChildren(visit);
    });
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
          _rebuildAllIfAppearanceChanged(state);
          return MaterialApp(
            title: 'Cepte Staj',
            debugShowCheckedModeBanner: false,
            locale: L10n.locale,
            supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: state.isDarkTheme ? AppTheme.dark() : AppTheme.light(),
            // AppColors flips instantly; animating the ThemeData on top of
            // that would tween stock widgets out of sync with custom ones.
            themeAnimationDuration: Duration.zero,
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
