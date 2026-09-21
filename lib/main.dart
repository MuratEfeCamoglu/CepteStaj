import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/app_state.dart';
import 'screens/splash/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
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
            theme: state.isDarkTheme ? AppTheme.dark() : AppTheme.light(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(state.textScale)),
              child: child!,
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
