import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';

class ListItem extends StatelessWidget {
  /// A widget to display after the title.
  final Widget? trailing;

  /// A widget to display before the title.
  final Widget? leading;

  ///The primary content of the list tile.
  final Widget? title;

  /// Additional content displayed below the title.
  final Widget? subtitle;

  final void Function()? onTap;

  final bool enabled;

  final EdgeInsets? padding;

  const ListItem({
    super.key,
    this.trailing,
    this.padding,
    this.title,
    this.leading,
    this.subtitle,
    this.onTap,
    this.enabled = true,
  });

  const ListItem.withChevron({
    super.key,
    this.trailing = const Icon(Icons.chevron_right),
    this.padding,
    this.title,
    this.leading,
    this.subtitle,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        enabled
            ? InkWell(
                onTap: onTap, child: _buildContents(context, enabled: true))
            : _buildContents(context, enabled: false),
        const ListItemDivider(),
      ],
    );
  }

  Widget _buildContents(BuildContext context, {bool enabled = true}) {
    final contentPadding = padding ?? EdgeInsets.zero;

    final trailingIcon = trailing is Icon ? trailing as Icon : null;

    return Container(
      constraints: const BoxConstraints(minHeight: 50),
      child: Padding(
        padding: contentPadding,
        child: Row(children: [
          if (leading != null) ...[
            Container(
              alignment: Alignment.center,
              child: leading,
            ),
            const SizedBox(width: Sizes.standard)
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (title != null)
                  DefaultTextStyle(
                      style: DefaultTextStyle.of(context).style.copyWith(
                          color:
                              enabled ? AppColors.dark : AppColors.lightGray),
                      child: title!),
                if (subtitle != null)
                  DefaultTextStyle(
                      style: DefaultTextStyle.of(context)
                          .style
                          .copyWith(color: AppColors.dark),
                      child: subtitle!),
              ],
            ),
          ),
          // if the trailing is an icon, we want to color it gray when disabled
          if (trailingIcon != null)
            enabled
                ? trailingIcon
                : Icon(trailingIcon.icon, color: AppColors.lightGray)
          else if (trailing != null)
            trailing!,
        ]),
      ),
    );
  }
}

class ListItemDivider extends StatelessWidget {
  final double leftPadding;

  const ListItemDivider({super.key, this.leftPadding = 0.0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: const Divider(
        color: AppColors.lightGray,
        height: 1,
      ),
    );
  }
}

class CircleLeadingIcon extends StatelessWidget {
  final Color backgroundColor;
  final Widget? icon;
  final EdgeInsets padding;

  const CircleLeadingIcon({
    super.key,
    this.backgroundColor = AppColors.lightGray,
    this.icon,
    this.padding = const EdgeInsets.all(6.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(Sizes.mapButtonBorderRadius),
        ),
      ),
      alignment: Alignment.center,
      padding: padding,
      child: icon,
    );
  }
}
