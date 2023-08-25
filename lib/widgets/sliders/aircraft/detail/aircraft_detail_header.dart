import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/models/message_container.dart';
import 'package:flutter_opendroneid/utils/conversions.dart';

import '../../../../bloc/aircraft/aircraft_cubit.dart';
import '../../../../bloc/aircraft/selected_aircraft_cubit.dart';
import '../../../../bloc/map/map_cubit.dart';
import '../../../../bloc/screen_cubit.dart';
import '../../../../bloc/showcase_cubit.dart';
import '../../../../bloc/sliders_cubit.dart';
import '../../../../bloc/standards_cubit.dart';
import '../../../../bloc/zones/selected_zone_cubit.dart';
import '../../../../bloc/zones/zone_item.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/sizes.dart';
import '../../../../extensions/string_extensions.dart';
import '../../../../utils/uasid_prefix_reader.dart';
import '../../../../utils/utils.dart';
import '../../../showcase/showcase_item.dart';
import '../../common/chevron.dart';
import '../aircraft_actions.dart';

class AircraftDetailHeader extends StatelessWidget {
  final Chevron chevron;
  const AircraftDetailHeader({Key? key, required this.chevron})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final screenCubit = context.read<ScreenCubit>();
    final zoneItem = context.watch<SelectedZoneCubit>().state.selectedZone;
    final selectedMac =
        context.watch<SelectedAircraftCubit>().state.selectedAircraftMac;
    // ignore: omit_local_variable_types
    final List<MessageContainer> messagePackList = selectedMac != null &&
            context.watch<AircraftCubit>().packsForDevice(
                      selectedMac,
                    ) !=
                null
        ? context.watch<AircraftCubit>().packsForDevice(
              selectedMac,
            )!
        : [];
    final headerHeight = calcHeaderHeight(context);
    chevron.context = context;
    chevron.color = AppColors.detailButtonsColor;

    return Container(
      padding: EdgeInsets.only(bottom: screenCubit.scaleHeight * 8),
      decoration: const BoxDecoration(
        color: AppColors.detailHeaderColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      height: headerHeight,
      width: width,
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: headerHeight / 25,
              bottom: screenCubit.scaleHeight < 0.4 ? 0 : headerHeight / 20,
            ),
            child: CustomPaint(
              painter: chevron,
              child: Container(
                margin: EdgeInsets.symmetric(
                  vertical:
                      screenCubit.scaleHeight < 0.4 ? 0 : headerHeight / 20,
                ),
                width: width / 8,
                height: headerHeight / 15,
              ),
            ),
          ),
          if (context.read<SlidersCubit>().panelController.state != null)
            messagePackList.isNotEmpty
                ? buildHeaderButtonsRow(context, messagePackList, zoneItem)
                : Container(),
        ],
      ),
    );
  }

  Widget buildHeaderButtonsRow(
    BuildContext context,
    List<MessageContainer> messagePackList,
    ZoneItem? zoneItem,
  ) {
    final width = MediaQuery.of(context).size.width;
    final headerHeight = calcHeaderHeight(context);
    final screenCubit = context.read<ScreenCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.mapContentMargin),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.detailButtonsColor,
            ),
            margin: EdgeInsets.symmetric(
              vertical: headerHeight / 20,
            ),
            height: headerHeight / 5 * 3,
            width: width / 9,
            child: IconButton(
              padding: EdgeInsets.all(screenCubit.scaleHeight * 2),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: Sizes.detailIconSize,
              ),
              onPressed: () {
                context.read<SlidersCubit>().setShowDroneDetail(show: false);
                context.read<SelectedZoneCubit>().unselectZone();
                context.read<SelectedAircraftCubit>().unselectAircraft();
                context.read<MapCubit>().turnOffLockOnPoint();
              },
            ),
          ),
          SizedBox(
            width: screenCubit.scaleWidth * 20,
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: messagePackList.last.operatorIDSet()
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                buildTitle(context, messagePackList),
                if (messagePackList.last.operatorIDSet())
                  buildSubtitle(context, messagePackList),
              ],
            ),
          ),
          ShowcaseItem(
            title: 'Aircraft Detail',
            showcaseKey: context.read<ShowcaseCubit>().droneDetailMoreKey,
            description:
                context.read<ShowcaseCubit>().droneDetailMoreDescription,
            child: Container(
              margin:
                  EdgeInsets.symmetric(vertical: 5 * screenCubit.scaleHeight),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.detailButtonsColor,
              ),
              height: headerHeight / 5 * 3,
              width: width / 9,
              child: IconButton(
                padding: EdgeInsets.symmetric(
                  horizontal: screenCubit.scaleWidth * 2,
                  vertical: screenCubit.scaleHeight * 2,
                ),
                icon: const Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                  size: Sizes.detailIconSize,
                ),
                onPressed: () {
                  displayAircraftActionMenu(context).then(
                    (value) => handleAction(context, value!),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showInfoDialog(BuildContext context, String message, String title) {
    // Create button
    final Widget okButton = TextButton(
      child: const Text('OK'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // Create AlertDialog
    final alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (context) {
        return alert;
      },
    );
  }

  Widget buildTitle(
      BuildContext context, List<MessageContainer> messagePackList) {
    String? manufacturer;
    Image? logo;
    if (messagePackList.isNotEmpty &&
        messagePackList.last.basicIdMessage?.uasID.asString() != null) {
      manufacturer = UASIDPrefixReader.getManufacturerFromUASID(
          messagePackList.last.basicIdMessage!.uasID.asString()!);
      logo =
          getManufacturerLogo(manufacturer: manufacturer, color: Colors.white);
    }
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        children: [
          if (manufacturer != null && logo != null)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: logo,
            ),
          TextSpan(
            text: messagePackList.last.basicIdMessage?.uasID.asString() ??
                'Unknown UAS ID',
          ),
        ],
      ),
    );
  }

  Widget buildSubtitle(
    BuildContext context,
    List<MessageContainer> messagePackList,
  ) {
    String? countryCode;
    final opIdMessage = messagePackList.last.operatorIdMessage;
    if (opIdMessage != null) {
      countryCode = getCountryCode(opIdMessage.operatorID);
    }
    Widget? flag;
    if (context.read<StandardsCubit>().state.internetAvailable &&
        messagePackList.last.operatorIDSet() &&
        messagePackList.last.operatorIDValid() &&
        countryCode != null) {
      flag = getFlag(countryCode);
    }
    final opIdText = messagePackList.last.operatorIDSet()
        ? flag == null
            ? opIdMessage!.operatorID.removeNonAlphanumeric()
            : ' ${opIdMessage!.operatorID.removeNonAlphanumeric()} '
        : '';
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
        children: [
          if (messagePackList.last.operatorIDSet() &&
              countryCode != null &&
              flag != null)
            WidgetSpan(
              child: flag,
              alignment: PlaceholderAlignment.middle,
            ),
          if (messagePackList.last.operatorIDSet())
            TextSpan(
              style: const TextStyle(
                color: Colors.white,
              ),
              text: opIdText,
            ),
          if (!messagePackList.last.operatorIDValid()) ...[
            TextSpan(text: ' '),
            WidgetSpan(
              child: Icon(
                Icons.warning_amber_sharp,
                size: Sizes.flagSize,
                color: Colors.white,
              ),
              alignment: PlaceholderAlignment.middle,
            ),
          ]
        ],
      ),
    );
  }
}
