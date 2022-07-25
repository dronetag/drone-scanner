import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './components/toolbar_actions.dart';
import '../../bloc/showcase_cubit.dart';
import '../../constants/colors.dart' as colors;
import '../../constants/sizes.dart';
import '../showcase/showcase_item.dart';
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
    final height = MediaQuery.of(context).size.height;
    const borderRadius = Radius.circular(Sizes.panelBorderRadius);
    final toolbarColor = colors.AppColors.droneScannerDarkGray
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
          vertical: statusBarHeight + height / 20,
          horizontal: Sizes.mapContentMargin),
      height: Sizes.toolbarHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 10,
          ),
          const Expanded(
            flex: 2,
            // source: https://www.fluttercampus.com/guide/254/google-map-autocomplete-place-search-flutter/
            child: LocationSearch(),
          ),
          ShowcaseItem(
            showcaseKey: context.read<ShowcaseCubit>().scanningStateKey,
            description: context.read<ShowcaseCubit>().scanningStateDescription,
            title: 'Map Toolbar',
            child: const ScanningStateIcons(),
          ),
          const SizedBox(
            width: 5,
          ),
          ShowcaseItem(
            showcaseKey: context.read<ShowcaseCubit>().showInfoKey,
            description: context.read<ShowcaseCubit>().showInfoDescription,
            title: 'Map Toolbar',
            child: RawMaterialButton(
              onPressed: () {
                displayToolbarMenu(context).then(
                  (value) {
                    if (value != null) handleAction(context, value);
                  },
                );
              },
              elevation: 0,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              fillColor: Colors.transparent,
              child: const Icon(
                Icons.more_horiz,
                color: Colors.white,
                size: Sizes.iconSize,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }
}
