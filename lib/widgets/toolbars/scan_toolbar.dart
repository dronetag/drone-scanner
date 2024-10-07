import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/showcase_cubit.dart';
import '../../constants/sizes.dart';
import '../showcase/showcase_item.dart';

import 'components/scanning_state_icons.dart';

/// Control of scanning, used to turned bt/Wi-Fi scan on or off
class ScanToolbar extends StatefulWidget {
  const ScanToolbar({
    super.key,
  });

  @override
  State<ScanToolbar> createState() => _ScanToolbarState();
}

class _ScanToolbarState extends State<ScanToolbar> {
  @override
  Widget build(BuildContext context) {
    const borderRadius = Radius.circular(Sizes.panelBorderRadius);

    return Container(
      decoration: const BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            blurRadius: Sizes.panelBorderRadius,
            color: Color.fromRGBO(0, 0, 0, 0.1),
          )
        ],
        borderRadius: BorderRadius.all(
          borderRadius,
        ),
        color: Colors.white,
      ),
      child: ShowcaseItem(
        showcaseKey: context.read<ShowcaseCubit>().searchKey,
        description: context.read<ShowcaseCubit>().searchDescription,
        title: 'Map Toolbar',
        child: ShowcaseItem(
          showcaseKey: context.read<ShowcaseCubit>().scanningStateKey,
          description: context.read<ShowcaseCubit>().scanningStateDescription,
          title: 'Map Toolbar',
          child: const ScanningStateIcons(),
        ),
      ),
    );
  }
}
