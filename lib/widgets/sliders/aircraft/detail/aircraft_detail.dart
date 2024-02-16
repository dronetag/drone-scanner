import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/models/message_container.dart';
import 'package:flutter_opendroneid/utils/conversions.dart';

import '../../../../bloc/aircraft/aircraft_cubit.dart';
import '../../../../bloc/aircraft/selected_aircraft_cubit.dart';
import '../../../../bloc/showcase_cubit.dart';
import '../../../../bloc/sliders_cubit.dart';
import '../../../../constants/sizes.dart';
import '../../../../models/aircraft_model_info.dart';
import '../../../showcase/showcase_item.dart';
import 'basic_fields.dart';
import 'connection_fields.dart';
import 'location_fields.dart';
import 'operator_fields.dart';

class AircraftDetail extends StatefulWidget {
  const AircraftDetail({
    super.key,
  });

  @override
  State<AircraftDetail> createState() => _AircraftDetailState();
}

class _AircraftDetailState extends State<AircraftDetail> {
  String? uasId;

  @override
  void initState() {
    super.initState();
    final selectedMac =
        context.read<SelectedAircraftCubit>().state.selectedAircraftMac;
    if (selectedMac == null) return;
    setState(
      () {
        // check if model info for current aircraft exists and fetch if not
        uasId = context
            .read<AircraftCubit>()
            .findByMacAddress(selectedMac)
            ?.basicIdMessage
            ?.uasID
            .asString();

        if (uasId == null) return;

        final modelInfo =
            context.read<AircraftCubit>().state.aircraftModelInfo[uasId];
        if (modelInfo == null) {
          context.read<AircraftCubit>().fetchModelInfo(uasId!);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedMac =
        context.watch<SelectedAircraftCubit>().state.selectedAircraftMac;
    if (selectedMac == null) return Container();
    final messagePackList =
        context.watch<AircraftCubit>().packsForDevice(selectedMac) ?? [];
    // empty or was deleted, return to list
    if (context.watch<SelectedAircraftCubit>().state.selectedAircraftMac ==
            null ||
        context.watch<AircraftCubit>().packsForDevice(
                  context
                      .watch<SelectedAircraftCubit>()
                      .state
                      .selectedAircraftMac!,
                ) ==
            null ||
        messagePackList.isEmpty) {
      context.read<SlidersCubit>().setShowDroneDetail(show: false);
      return Container();
    }
    final height = MediaQuery.of(context).size.height;

    final modelInfo =
        context.watch<AircraftCubit>().state.aircraftModelInfo[uasId];
    final dataChildren = buildChildren(context, messagePackList, modelInfo);

    return ShowcaseItem(
      showcaseKey: context.read<ShowcaseCubit>().droneDetailPanelKey,
      description: context.read<ShowcaseCubit>().droneDetailPanelDescription,
      title: 'Aircraft Detail',
      padding: EdgeInsets.only(bottom: -height / 2),
      backgroundColor: Theme.of(context).colorScheme.primary,
      textColor: Colors.white,
      opacity: 0,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 0,
          left: Sizes.detailMargin,
          right: Sizes.detailMargin,
        ),
        child: MediaQuery.of(context).orientation == Orientation.landscape
            ? GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 5,
                  mainAxisExtent: 50,
                ),
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: dataChildren.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.all(2),
                    child: dataChildren[index],
                  );
                },
              )
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: MediaQuery.of(context).padding.copyWith(top: 0.0),
                itemCount: dataChildren.length,
                itemBuilder: (context, index) => dataChildren[index],
              ),
      ),
    );
  }

  List<Widget> buildChildren(
    BuildContext context,
    List<MessageContainer> messagePackList,
    AircraftModelInfo? modelInfo,
  ) {
    final loc = messagePackList.last.locationMessage;
    final fetchInProgress = context
        .select<AircraftCubit, bool>((cubit) => cubit.state.fetchInProgress);
    return [
      ...ConnectionFields.buildConnectionFields(context, messagePackList),
      ...BasicFields.buildBasicFields(
        context: context,
        messagePackList: messagePackList,
        modelInfo: modelInfo,
        modelInfoFetchInProgress: fetchInProgress,
      ),
      ...LocationFields.buildLocationFields(context, loc),
      ...OperatorFields.buildOperatorFields(context, messagePackList.last),
    ];
  }
}
