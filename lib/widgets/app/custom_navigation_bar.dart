import 'package:flutter/material.dart';

import 'app_scaffold.dart';

class CustomNavigationBar extends StatelessWidget {
  final DroneScannerPage currentPage;
  final Function(DroneScannerPage)? onPageSelected;

  const CustomNavigationBar(
      {super.key, required this.currentPage, this.onPageSelected});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentPage.index,
      selectedFontSize: 14,
      unselectedFontSize: 14,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      onTap: (index) {
        if (onPageSelected != null) {
          onPageSelected!(DroneScannerPage.values[index]);
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.radar),
          label: 'Radar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.more),
          label: 'More',
        ),
      ],
    );
  }
}
