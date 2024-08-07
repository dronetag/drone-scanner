import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/aircraft/aircraft_metadata_cubit.dart';
import '../../../constants/sizes.dart';
import 'small_circular_progress_indicator.dart';

class Flag extends StatefulWidget {
  final String alpha3CountryCode;
  final Color? color;
  final EdgeInsets? margin;
  const Flag(
      {super.key, required this.alpha3CountryCode, this.color, this.margin});

  @override
  State<Flag> createState() => _FlagState();
}

class _FlagState extends State<Flag> {
  @override
  void initState() {
    super.initState();
    context
        .read<AircraftMetadataCubit>()
        .fetchFlagForAlpha3Code(widget.alpha3CountryCode);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AircraftMetadataCubit, AircraftMetadataState>(
      builder: (context, state) {
        final bytes = state.getFlag(widget.alpha3CountryCode);
        if (bytes != null) {
          return Container(
              margin: widget.margin,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              width: Sizes.flagSize,
              height: Sizes.flagSize,
              child: CircleAvatar(backgroundImage: Image.memory(bytes).image));
        }
        if (state.fetchInProgress) {
          return SmallCircularProgressIndicator(
            size: Sizes.standard,
            color: widget.color,
            margin: const EdgeInsets.all(
              Sizes.standard / 3,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
