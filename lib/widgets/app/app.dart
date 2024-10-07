import 'package:flutter/material.dart';
import 'package:navigation_history_observer/navigation_history_observer.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../constants/theme.dart';
import '../home_screen.dart';
import 'life_cycle_manager.dart';

PackageInfo? packageInfo;

class App extends StatefulWidget {
  App({super.key}) {
    _retirevePackageInfo();
  }

  @override
  State<App> createState() => _AppState();

  /// Function to retrieve package info and make it
  /// globally available across the project via [packageInfo]
  /// from file `app.dart`
  Future<void> _retirevePackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
  }
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const LifeCycleManager(
        child: HomeScreen(),
      ),
      navigatorObservers: [NavigationHistoryObserver()],
    );
  }
}
