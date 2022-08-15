import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../bloc/aircraft/aircraft_cubit.dart';
import '../../bloc/showcase_cubit.dart';
import '../../bloc/sliders_cubit.dart';
import '../../bloc/standards_cubit.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../../utils/drone_scanner_icon_icons.dart';
import '../app/dialogs.dart';
import '../showcase/showcase_item.dart';
import '../sliders/common/headline.dart';
import 'components/clean_packs_checkbox.dart';
import 'components/custom_dropdown_button.dart';
import 'components/preferences_field.dart';
import 'components/preferences_field_with_description.dart';

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StandardsCubit, StandardsState>(
      builder: (context, state) {
        final isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;
        final itemList = buildItems(
          context,
          state,
        );
        return ShowCaseWidget(
          builder: Builder(
            builder: (context) => Scaffold(
              resizeToAvoidBottomInset: true,
              body: ShowcaseItem(
                showcaseKey: context.read<ShowcaseCubit>().aboutPageKey,
                description:
                    'This page contains infomation about supported standards '
                    'on your device and additional settings',
                title: 'Preferences',
                child: ColoredBox(
                  color: Theme.of(context).backgroundColor,
                  child: Padding(
                    padding: isLandscape
                        ? EdgeInsets.only(
                            top: MediaQuery.of(context).viewPadding.top,
                            bottom: 5,
                            left: Sizes.mapContentMargin,
                            right: Sizes.mapContentMargin,
                          )
                        : EdgeInsets.only(
                            top: MediaQuery.of(context).viewPadding.top,
                            left: Sizes.mapContentMargin,
                            right: Sizes.mapContentMargin,
                          ),
                    child: isLandscape
                        ? GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisExtent: 35,
                            ),
                            shrinkWrap: true,
                            itemCount: itemList.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.all(2),
                                child: itemList[index],
                              );
                            },
                          )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) => itemList[index],
                            itemCount: itemList.length,
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> buildItems(
    BuildContext context,
    StandardsState state,
  ) {
    const positiveIcon = Icon(
      DroneScannerIcon.done,
      color: AppColors.green,
    );
    const negativeIcon = Icon(
      DroneScannerIcon.close,
      color: AppColors.red,
    );
    final width = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final btLegacyText = state.btLegacy ? 'Fully supported' : 'Not supported';
    final btExtendedText =
        state.btExtended ? 'Partially supported' : 'Not supported';
    final wifiBeaconText =
        state.wifiBeacon ? 'Fully supported' : 'Not supported';
    final wifiNanText = state.wifiNaN ? 'Fully supported' : 'Not supported';
    final maxAdvDataLenText = state.maxAdvDataLen.toString();
    final buttonStyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(
        AppColors.preferencesButtonColor,
      ),
    );
    final itemPadding = EdgeInsets.only(bottom: 8);
    return [
      Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            DroneScannerIcon.arrowBack,
            size: Sizes.iconSize,
          ),
        ),
      ),
      const Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(bottom: 15.0),
          child: Text(
            'Preferences',
            textScaleFactor: 2,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      if (isLandscape) const SizedBox(),
      const Headline(
        text: 'Standards',
        child: Tooltip(
          triggerMode: TooltipTriggerMode.tap,
          message: 'Each phone may support different standards which the '
              'application attemps to use. See which standards are supported '
              'on your device.',
          child: Icon(
            Icons.help_outline,
            color: AppColors.lightGray,
            size: Sizes.textIconSize,
          ),
        ),
      ),
      if (isLandscape) const SizedBox(),
      Padding(
        padding: itemPadding,
        child: PreferencesField(
          label: 'Bluetooth 4 Legacy',
          icon: state.btLegacy ? positiveIcon : negativeIcon,
          color: state.btLegacy ? AppColors.green : AppColors.red,
          text: btLegacyText,
        ),
      ),
      PreferencesField(
        label: 'Bluetooth 5 Extended',
        color: state.btExtended ? AppColors.orange : AppColors.red,
        text: btExtendedText,
        icon: state.btExtended
            ? const Tooltip(
                triggerMode: TooltipTriggerMode.tap,
                message:
                    'Warning: Support claimed by manufactur does not fully '
                    'guarantee that Bluetooth Extended actualy will work.',
                child: Icon(
                  Icons.error_outline,
                  color: AppColors.orange,
                ),
              )
            : negativeIcon,
      ),
      if (state.androidSystem)
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: RichText(
              textScaleFactor: 0.75,
              text: TextSpan(
                style: const TextStyle(color: AppColors.lightGray),
                children: <TextSpan>[
                  const TextSpan(text: 'Max. ad. data length is '),
                  TextSpan(
                    text: '$maxAdvDataLenText bytes',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      Padding(
        padding: itemPadding,
        child: PreferencesField(
          label: 'Wi-Fi Beacon',
          text: wifiBeaconText,
          icon: state.wifiBeacon ? positiveIcon : negativeIcon,
          color: state.wifiBeacon ? AppColors.green : AppColors.red,
        ),
      ),
      PreferencesField(
        label: 'Wi-Fi NaN',
        text: wifiNanText,
        color: state.wifiNaN ? AppColors.green : AppColors.red,
        icon: state.wifiNaN ? positiveIcon : negativeIcon,
      ),
      if (isLandscape) const SizedBox(),
      const Headline(
        text: 'Permissions',
        child: Tooltip(
          triggerMode: TooltipTriggerMode.tap,
          message:
              'See what permissions are currently granted with possibility '
              'to change them from the system settings.',
          child: Icon(
            Icons.help_outline,
            color: AppColors.lightGray,
            size: Sizes.textIconSize,
          ),
        ),
      ),
      if (isLandscape) const SizedBox(),
      Padding(
        padding: itemPadding,
        child: PreferencesField(
          label: 'Wi-Fi',
          text: state.androidSystem ? 'Granted' : 'Not Granted',
          color: state.androidSystem ? AppColors.green : AppColors.red,
          icon: state.androidSystem ? positiveIcon : negativeIcon,
        ),
      ),
      Padding(
        padding: itemPadding,
        child: PreferencesField(
          label: 'Location',
          text: state.locationEnabled ? 'Granted' : 'Not Granted',
          color: state.locationEnabled ? AppColors.green : AppColors.red,
          icon: state.locationEnabled ? positiveIcon : negativeIcon,
        ),
      ),
      Padding(
        padding: itemPadding,
        child: PreferencesField(
          label: 'Bluetooth',
          text: state.btEnabled ? 'Granted' : 'Not Granted',
          color: state.btEnabled ? AppColors.green : AppColors.red,
          icon: state.btEnabled ? positiveIcon : negativeIcon,
        ),
      ),
      if (isLandscape) const SizedBox(),
      if (state.androidSystem)
        Align(
          child: Container(
            padding: itemPadding,
            width: width / 2,
            child: ElevatedButton(
              onPressed: AppSettings.openAppSettings,
              style: buttonStyle,
              child: const Text(
                'Open app settings',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      Align(
        child: Container(
          padding: itemPadding,
          width: width / 2,
          child: ElevatedButton(
            onPressed: AppSettings.openDeviceSettings,
            style: buttonStyle,
            child: const Text(
              'Open phone settings',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      const Headline(
        text: 'Data Preferences',
        child: Tooltip(
          triggerMode: TooltipTriggerMode.tap,
          message: 'The application can delete old records after certain time '
              'passes after the last message from device is received.',
          child: Icon(
            Icons.help_outline,
            color: AppColors.lightGray,
            size: Sizes.textIconSize,
          ),
        ),
      ),
      if (isLandscape) const SizedBox(),
      Padding(
        padding: itemPadding,
        child: const PreferencesFieldWithDescription(
          label: 'Clean automatically:',
          description:
              'Aircrafts inactive for chosen time will be\nautomatically cleared',
          child: CleanPacksCheckbox(),
        ),
      ),
      Padding(
        padding: itemPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Time to clean:'),
            SizedBox(
              width: width / 3,
              child: SpinBox(
                spacing: 1,
                min: 10,
                max: 1000.0,
                value: context
                    .watch<AircraftCubit>()
                    .state
                    .cleanTimeSec
                    .toDouble(),
                step: 5,
                onChanged: (v) => context.read<AircraftCubit>().setcleanTimeSec(
                      v.toInt(),
                    ),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.only(
                    top: 5,
                  ),
                  constraints: BoxConstraints(
                    maxHeight: 40,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: itemPadding / 2,
        child: PreferencesFieldWithDescription(
          label: 'List field preference:',
          description:
              'Choose which information your prefer\nto see in the list '
              'of aircrafts',
          child: CustomDropdownButton(
            value:
                context.watch<SlidersCubit>().state.listFieldPreferenceString(),
            valueChangedCallback: (newValue) {
              if (newValue != null) {
                context.read<SlidersCubit>().setListFieldPreference(newValue);
              }
            },
            items: const [
              'Distance',
              'Location',
              'Speed',
            ],
          ),
        ),
      ),
      Align(
        child: Container(
          padding: itemPadding / 2,
          width: width / 2,
          child: ElevatedButton(
            style: buttonStyle,
            onPressed: () {
              showAlertDialog(
                context,
                'Are you sure you want to delete all gathered data?',
                () {
                  context.read<SlidersCubit>().setShowDroneDetail(show: false);
                  context.read<AircraftCubit>().clear();
                },
              );
            },
            child: const Text('Clean packs'),
          ),
        ),
      ),
      Align(
        child: Container(
          padding: itemPadding / 2,
          width: width / 2,
          child: ElevatedButton(
            style: buttonStyle,
            onPressed: () {
              context.read<AircraftCubit>().exportPacksToCSV(save: false);
            },
            child: const Text('Export all data'),
          ),
        ),
      ),
      Align(
        child: Container(
          padding: itemPadding / 2,
          width: width / 2,
          child: ElevatedButton(
            style: buttonStyle,
            onPressed: () {
              Navigator.pop(context);
              context.read<ShowcaseCubit>().restartShowcase();
            },
            child: const Text('Replay showcase'),
          ),
        ),
      ),
    ];
  }
}
