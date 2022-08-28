import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/models/message_pack.dart';

import '../../../../bloc/aircraft/aircraft_cubit.dart';
import '../../../../bloc/aircraft/selected_aircraft_cubit.dart';
import '../../../../bloc/showcase_cubit.dart';
import '../../../../bloc/sliders_cubit.dart';
import '../../../../bloc/standards_cubit.dart';
import '../../../../utils/utils.dart';
import '../../../showcase/showcase_item.dart';
import 'basic_fields.dart';
import 'connection_fields.dart';
import 'location_fields.dart';
import 'operator_fields.dart';

class AircraftDetail extends StatelessWidget {
  const AircraftDetail({
    Key? key,
  }) : super(key: key);

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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final maxSliderHeight = maxSliderSize(
      height: height,
      statusBarHeight: MediaQuery.of(context).viewPadding.top,
      androidSystem: context.read<StandardsCubit>().state.androidSystem,
    );
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final headerHeight = isLandscape ? height / 6 : height / 12;
    final dataChildren = buildChildren(context, messagePackList);
    return Padding(
      padding: EdgeInsets.only(
        top: 0,
        left: width / 20,
        right: width / 20,
      ),
      child:
          //title: buildTitle(context, messagePackList),
          MediaQuery.of(context).orientation == Orientation.landscape
              ? GridView.builder(
                  padding: EdgeInsets.only(top: headerHeight),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5,
                    mainAxisExtent: 50,
                  ),
                  shrinkWrap: true,
                  itemCount: dataChildren.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.all(2),
                      child: dataChildren[index],
                    );
                  },
                )
              : Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: headerHeight),
                      height: context.watch<SlidersCubit>().isAtSnapPoint()
                          ? maxSliderHeight * 0.3 - headerHeight
                          : maxSliderHeight - headerHeight,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: dataChildren.length,
                        itemBuilder: (context, index) => dataChildren[index],
                      ),
                    ),
                  ],
                ),
    );
  }

  List<Widget> buildChildren(
    BuildContext context,
    List<MessagePack> messagePackList,
  ) {
    final loc = messagePackList.last.locationMessage;
    return [
      ...ConnectionFields.buildConnectionFields(context, messagePackList),
      ...BasicFields.buildBasicFields(context, messagePackList),
      ...LocationFields.buildLocationFields(context, loc),
      if (context.watch<ShowcaseCubit>().state.showcaseActive)
        ShowcaseItem(
          //padding: EdgeInsets.only(top: -headerHeight),
          showcaseKey: context.read<ShowcaseCubit>().droneDetailPanelKey,
          description:
              context.read<ShowcaseCubit>().droneDetailPanelDescription,
          title: 'Aircraft Detail',
          child: Container(),
        ),
      if (messagePackList.last.systemDataValid())
        ...OperatorFields.buildOperatorFields(
          context,
          messagePackList.last.systemDataMessage!,
          messagePackList.last.operatorIDValid()
              ? messagePackList.last.operatorIdMessage!
              : null,
        ),
    ];
  }
}
