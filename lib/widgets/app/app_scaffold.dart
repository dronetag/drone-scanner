import 'package:flutter/material.dart';

import '../map/map_page.dart';
import '../preferences/preferences_page.dart';
import '../preferences/proximity_alerts_page.dart';
import '../receiver/receiver_list_page.dart';
import 'custom_navigation_bar.dart';
import 'more_page.dart';

enum DroneScannerPage {
  map,
  radar,
  settings,
  more,
}

// scaffold inside safe area with bottom padding and white background
// used as root of all pages
class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  late final PageController _pageController =
      PageController(initialPage: _currentPage.index);

  DroneScannerPage _currentPage = DroneScannerPage.map;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
        color: Colors.white,
        child: Scaffold(
          // ensure the keyboard does not move the content up
          resizeToAvoidBottomInset: true,

          bottomNavigationBar: CustomNavigationBar(
              currentPage: _currentPage,
              onPageSelected: (page) {
                setState(() {
                  _currentPage = page;
                });
                _pageController.jumpToPage(page.index);
              }),
          body: _buildBody(),
        ));
  }

  Widget _buildBody() => PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          MapPage(),
          ProximityAlertsPage(),
          ReceiverListPage(),
          PreferencesPage(),
          MorePage(),
        ],
      );
}
