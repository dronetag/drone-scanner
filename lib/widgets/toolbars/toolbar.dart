import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/showcase_cubit.dart';
import '../../constants/colors.dart' as colors;
import '../../constants/sizes.dart';
import '../showcase/showcase_item.dart';
import './components/toolbar_actions.dart';
import 'components/location_search.dart';
import 'components/scanning_state_icons.dart';

class Toolbar extends StatefulWidget {
  const Toolbar({
    Key? key,
  }) : super(key: key);

  @override
  State<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).viewPadding.top;
    const borderRadius = Radius.circular(Sizes.panelBorderRadius);
    final toolbarColor = colors.AppColors.toolbarColor
        .withOpacity(colors.AppColors.toolbarOpacity);
    return Container(
      decoration: BoxDecoration(
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: Sizes.panelBorderRadius,
            color: Color.fromRGBO(0, 0, 0, 0.1),
          )
        ],
        borderRadius: const BorderRadius.all(
          borderRadius,
        ),
        color: toolbarColor,
      ),
      margin: EdgeInsets.symmetric(
        vertical: statusBarHeight + Sizes.mapContentMargin,
        horizontal: Sizes.mapContentMargin,
      ),
      padding: EdgeInsets.symmetric(horizontal: Sizes.toolbarMargin),
      height: Sizes.toolbarHeight,
      child: ShowcaseItem(
        showcaseKey: context.read<ShowcaseCubit>().searchKey,
        description: context.read<ShowcaseCubit>().searchDescription,
        title: 'Map Toolbar',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 2,
              child: LocationSearch(),
            ),
            Expanded(
              flex: 1,
              child: ShowcaseItem(
                showcaseKey: context.read<ShowcaseCubit>().scanningStateKey,
                description:
                    context.read<ShowcaseCubit>().scanningStateDescription,
                title: 'Map Toolbar',
                child: const ScanningStateIcons(),
              ),
            ),
            ShowcaseItem(
              showcaseKey: context.read<ShowcaseCubit>().showInfoKey,
              description: context.read<ShowcaseCubit>().showInfoDescription,
              title: 'Map Toolbar',
              child: IconButton(
                onPressed: () {
                  displayToolbarMenu(context).then(
                    (value) {
                      if (value != null) handleAction(context, value);
                    },
                  );
                },
                padding: const EdgeInsets.all(0),
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                  size: Sizes.iconSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
