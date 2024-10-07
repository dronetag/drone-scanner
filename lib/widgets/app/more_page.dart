import 'package:flutter/material.dart';

import '../../constants/sizes.dart';
import '../help/help_page.dart';
import 'page_list_item.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final itemList = buildItems(context);
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).viewPadding.top,
          left: Sizes.preferencesMargin,
          right: Sizes.preferencesMargin,
        ),
        child: ListView.builder(
          padding: MediaQuery.of(context).padding.copyWith(top: 0.0),
          itemBuilder: (context, index) => itemList[index],
          itemCount: itemList.length,
          physics: const BouncingScrollPhysics(),
        ),
      ),
    );
  }

  List<Widget> buildItems(BuildContext context) {
    return [
      const Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: Sizes.standard * 2),
          child: Text(
            'More',
            textScaler: TextScaler.linear(2),
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      const PageListItem(
        title: Text('Drone Scanner Pro'),
        icon: Icon(Icons.workspace_premium),
        route: HelpPage.routeName,
      ),
      const PageListItem(
        title: Text('Export Airspace Data'),
        icon: Icon(Icons.upgrade),
        route: HelpPage.routeName,
      ),
      const PageListItem(
        title: Text('Offline mode'),
        icon: Icon(Icons.shield_outlined),
        route: HelpPage.routeName,
      ),
      const PageListItem(
        title: Text('Toolbox app'),
        icon: Icon(Icons.help),
        route: HelpPage.routeName,
      ),
      const PageListItem(
        title: Text('Help'),
        icon: Icon(Icons.help_outline),
        route: HelpPage.routeName,
      ),
      const PageListItem(
        title: Text('Replay Intro'),
        icon: Icon(Icons.emoji_people),
        route: HelpPage.routeName,
      ),
      const PageListItem(
        title: Text('About'),
        icon: Icon(Icons.info_outline),
        route: HelpPage.routeName,
      ),
    ];
  }
}
