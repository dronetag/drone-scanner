import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import '../../constants/theme.dart';
import '../mainpage/home_page.dart';
import 'life_cycle_manager.dart';

PackageInfo? packageInfo;

class App extends StatefulWidget {
  App({
    Key? key,
  }) : super(key: key) {
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
    return LifeCycleManager(
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const MyHomePage(),
      ),
    );
  }
}
