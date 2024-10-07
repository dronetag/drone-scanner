import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../../models/home_screen_page.dart';

class HomeScreenNavigationBar extends StatelessWidget {
  final HomeScreenPage currentPage;
  final Function(HomeScreenPage)? onPageSelected;

  const HomeScreenNavigationBar(
      {super.key, required this.currentPage, this.onPageSelected});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentPage.index,
      selectedFontSize: 14,
      unselectedFontSize: 14,
      selectedItemColor: AppColors.blue,
      unselectedItemColor: Colors.black,
      showUnselectedLabels: true,
      onTap: (index) {
        if (onPageSelected != null) {
          onPageSelected!(HomeScreenPage.values[index]);
        }
      },
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.map),
          activeIcon: BottomNavigationBarItemFrame(child: Icon(Icons.map)),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/images/radar-icon.png',
              width: Sizes.iconSize),
          activeIcon: BottomNavigationBarItemFrame(
            child: Image.asset('assets/images/radar-icon.png',
                width: Sizes.iconSize, color: AppColors.blue),
          ),
          label: 'Radar',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          activeIcon: BottomNavigationBarItemFrame(child: Icon(Icons.settings)),
          label: 'Settings',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz),
          activeIcon:
              BottomNavigationBarItemFrame(child: Icon(Icons.more_horiz)),
          label: 'More',
        ),
      ],
    );
  }
}

class BottomNavigationBarItemFrame extends StatelessWidget {
  final Widget child;

  const BottomNavigationBarItemFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(Sizes.half / 2),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(Sizes.mapButtonBorderRadius),
          ),
          border: Border.all(color: AppColors.blue),
        ),
        child: child);
  }
}
