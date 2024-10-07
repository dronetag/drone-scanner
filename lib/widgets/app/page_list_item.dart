import 'package:flutter/material.dart';

import '../../constants/sizes.dart';
import 'list_item.dart';

class PageListItem extends StatelessWidget {
  final Widget title;
  final Widget? currentValue;

  final String? route;
  final VoidCallback? onTap;
  final Widget icon;
  final EdgeInsets? padding;
  final Widget? trailing;
  final bool? enabled;

  const PageListItem({
    super.key,
    this.currentValue,
    required this.title,
    this.route,
    required this.icon,
    this.onTap,
    this.padding,
    this.trailing,
    this.enabled,
  })  : assert(route != null || onTap != null,
            "Either route or onTap must be provided"),
        assert(
            (route == null && onTap != null) ||
                (route != null && onTap == null),
            "Only one of route or onTap must be provided");

  @override
  Widget build(BuildContext context) {
    return ListItem(
      leading: CircleLeadingIcon(
        icon: IconTheme(
          data: const IconThemeData(),
          child: icon,
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [title, currentValue ?? const SizedBox.shrink()],
      ),
      padding: padding,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) trailing!,
          const SizedBox(width: Sizes.standard),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: _getOnTap(context),
      enabled: enabled ?? true,
    );
  }

  _getOnTap(BuildContext context) {
    // TODO
    /*if (route != null) {
      return () {
        context.go(route!);
      };
    } else {
      return onTap;
    }*/
  }
}
