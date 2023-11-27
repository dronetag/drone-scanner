import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/pigeon.dart' as pigeon;
import 'package:showcaseview/showcaseview.dart';

import '../../bloc/aircraft/aircraft_cubit.dart';
import '../../bloc/aircraft/aircraft_expiration_cubit.dart';
import '../../bloc/aircraft/selected_aircraft_cubit.dart';
import '../../bloc/help/help_cubit.dart';
import '../../bloc/map/map_cubit.dart';
import '../../bloc/opendroneid_cubit.dart';
import '../../bloc/proximity_alerts_cubit.dart';
import '../../bloc/showcase_cubit.dart';
import '../../bloc/sliders_cubit.dart';
import '../../bloc/standards_cubit.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../../utils/drone_scanner_icon_icons.dart';
import '../app/app_scaffold.dart';
import '../app/custom_tooltip.dart';
import '../app/dialogs.dart';
import '../help/help_page.dart';
import '../showcase/showcase_item.dart';
import '../sliders/common/headline.dart';
import 'components/custom_dropdown_button.dart';
import 'components/custom_spinbox.dart';
import 'components/preferences_field.dart';
import 'components/preferences_field_with_description.dart';
import 'components/preferences_slider.dart';
import 'components/scanning_status_field.dart';
import 'components/screen_sleep_checkbox.dart';

class PreferencesPage extends StatelessWidget {
  static const routeName = 'PreferencesPage';
  const PreferencesPage({Key? key}) : super(key: key);

  static const scanPriorityMapping = {
    'High': pigeon.ScanPriority.High,
    'Low': pigeon.ScanPriority.Low,
  };

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
            builder: (context) => AppScaffold(
              child: ShowcaseItem(
                showcaseKey: context.read<ShowcaseCubit>().aboutPageKey,
                description:
                    'This page contains infomation about supported standards '
                    'on your device and additional settings',
                title: 'Preferences',
                child: ColoredBox(
                  color: Theme.of(context).colorScheme.background,
                  child: Padding(
                    padding: isLandscape
                        ? EdgeInsets.only(
                            top: MediaQuery.of(context).viewPadding.top,
                            bottom: 5,
                            left: Sizes.preferencesMargin,
                            right: Sizes.preferencesMargin,
                          )
                        : EdgeInsets.only(
                            top: MediaQuery.of(context).viewPadding.top,
                            left: Sizes.preferencesMargin,
                            right: Sizes.preferencesMargin,
                          ),
                    child: isLandscape
                        ? GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisExtent:
                                  MediaQuery.of(context).size.height / 5.5,
                            ),
                            shrinkWrap: true,
                            itemCount: itemList.length,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                child: itemList[index],
                              );
                            },
                          )
                        : ListView.builder(
                            padding: MediaQuery.of(context)
                                .padding
                                .copyWith(top: 0.0),
                            itemBuilder: (context, index) => itemList[index],
                            itemCount: itemList.length,
                            physics: BouncingScrollPhysics(),
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
      color: AppColors.redIcon,
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
    final itemPadding = EdgeInsets.only(bottom: 10);

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
      if (isLandscape) const SizedBox(),
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
      Headline(
        text: 'Enabled Technologies',
      ),
      Padding(
        padding: itemPadding,
        child: ScanningStatusField(),
      ),
      Padding(
        padding: itemPadding,
        child: GestureDetector(
          onTap: (() {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HelpPage(
                  highlightedQuestionIndex: HelpCubit.iphoneWifiQuestionIndex,
                ),
                settings: RouteSettings(
                  name: HelpPage.routeName,
                ),
              ),
            );
          }),
          child: Row(
            children: [
              Icon(
                Icons.help_outline,
                color: AppColors.highlightBlue,
                size: Sizes.textIconSize,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                'Why Wi-Fi cannot be enabled on the iPhone?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.highlightBlue,
                ),
              ),
            ],
          ),
        ),
      ),
      Headline(
        text: 'Standards',
        child: CustomTooltip(
          message: 'Each phone may support different standards which the '
              'application attemps to use. See which standards are supported '
              'on your device.',
          color: AppColors.lightGray,
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
      Padding(
        padding: isLandscape ? itemPadding : EdgeInsets.zero,
        child: PreferencesField(
          label: 'Bluetooth 5 Extended',
          color: state.btExtended ? AppColors.orange : AppColors.red,
          text: btExtendedText,
          icon: state.btExtended
              ? CustomTooltip(
                  message:
                      'Warning: Support claimed by manufacturer does not fully '
                      'guarantee that Bluetooth Extended will actually work.',
                  color: AppColors.orange,
                )
              : negativeIcon,
        ),
      ),
      if (!isLandscape && state.androidSystem)
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: itemPadding,
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
      Padding(
        padding: itemPadding,
        child: PreferencesField(
          label: 'Wi-Fi NaN',
          text: wifiNanText,
          color: state.wifiNaN ? AppColors.green : AppColors.red,
          icon: state.wifiNaN ? positiveIcon : negativeIcon,
        ),
      ),
      Headline(
        text: 'Permissions',
        child: CustomTooltip(
          message:
              'See what permissions are currently granted with a possibility '
              'to change them from the system settings.',
          color: AppColors.lightGray,
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
      Padding(
        padding: itemPadding,
        child: PreferencesField(
          label: 'Notifications',
          text: state.notificationsEnabled ? 'Granted' : 'Not Granted',
          color: state.notificationsEnabled ? AppColors.green : AppColors.red,
          icon: state.notificationsEnabled ? positiveIcon : negativeIcon,
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
            onPressed: () =>
                AppSettings.openAppSettings(type: AppSettingsType.device),
            style: buttonStyle,
            child: const Text(
              'Open phone settings',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      Headline(
        text: 'Data Preferences',
        child: CustomTooltip(
          message: 'The application can delete old records after certain time '
              'passes after the last message from device is received.',
          color: AppColors.lightGray,
        ),
      ),
      if (isLandscape) const SizedBox(),
      Padding(
        padding: itemPadding / 2,
        child: PreferencesFieldWithDescription(
          label: 'Bluetooth scan priority:',
          description: 'High priority scan gathers more data but uses '
              'more battery energy',
          child: CustomDropdownButton(
            value: scanPriorityMapping.keys.firstWhere((element) =>
                scanPriorityMapping[element] ==
                context.watch<OpendroneIdCubit>().state.scanPriority),
            valueChangedCallback: (newValue) {
              if (newValue != null) {
                context
                    .read<OpendroneIdCubit>()
                    .setScanPriorityPreference(scanPriorityMapping[newValue]!);
              }
            },
            items: scanPriorityMapping.keys.toList(),
          ),
        ),
      ),
      Padding(
        padding: itemPadding,
        child: PreferencesFieldWithDescription(
          label: 'Clean automatically:',
          description: 'Aircrafts inactive for chosen time '
              'will be automatically cleared',
          child: PreferencesSlider(
              getValue: () =>
                  context.read<AircraftExpirationCubit>().state.cleanOldPacks,
              setValue: ({required value}) {
                final packs = context.read<AircraftCubit>().state.packHistory();
                context
                    .read<AircraftExpirationCubit>()
                    .setCleanOldPacks(packs, clean: value);
              }),
        ),
      ),
      Padding(
        padding: itemPadding,
        child: PreferencesFieldWithDescription(
          label: 'Expiration time (sec):',
          description: 'Set the duration between 10 and 600 seconds',
          child: Container(
            width: width / 3,
            child: CustomSpinBox(
              maxVal: AircraftExpirationCubit.maxTime,
              minVal: AircraftExpirationCubit.minTime,
              step: AircraftExpirationCubit.timeStep,
              value: context
                  .watch<AircraftExpirationCubit>()
                  .state
                  .cleanTimeSec
                  .toDouble(),
              valueSetter: (value) {
                final packs = context.read<AircraftCubit>().state.packHistory();
                context.read<AircraftExpirationCubit>().setcleanTimeSec(
                      value,
                      packs,
                    );
              },
            ),
          ),
        ),
      ),
      Padding(
        padding: itemPadding / 2,
        child: PreferencesFieldWithDescription(
          label: 'List field preference:',
          description: 'Choose which information you prefer to see in the list '
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
      Padding(
        padding: itemPadding / 2,
        child: PreferencesFieldWithDescription(
          label: 'My drone position in list:',
          description: 'Choose how your drone should be positioned in a list '
              'of all nearby drones',
          child: CustomDropdownButton(
            value:
                context.watch<SlidersCubit>().state.myDronePositioningString(),
            valueChangedCallback: (newValue) {
              if (newValue != null) {
                context.read<SlidersCubit>().setMyDronePositioning(newValue);
              }
            },
            items: const [
              'Default',
              'Always First',
              'Always Last',
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
                  context.read<ProximityAlertsCubit>().clearFoundDrones();
                  context.read<SlidersCubit>().setShowDroneDetail(show: false);
                  context.read<AircraftCubit>().clearAircraft();
                  context.read<SelectedAircraftCubit>().unselectAircraft();
                  context.read<MapCubit>().turnOffLockOnPoint();
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
              showAlertDialog(
                context,
                'Are you sure you want to delete manufacturer and model data?',
                () {
                  context.read<AircraftCubit>().clearModelInfo();
                },
              );
            },
            child: const Text('Clean model info'),
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
              context.read<AircraftCubit>().exportPacksToCSV().then(
                (value) {
                  if (value) {
                    showSnackBar(context, 'CSV shared successfuly.');
                  } else {
                    showSnackBar(
                      context,
                      'Sharing data was not succesful.',
                    );
                  }
                },
              );
            },
            child: const Text('Export all data'),
          ),
        ),
      ),
      Headline(
        text: 'Misc',
      ),
      Padding(
        padding: itemPadding,
        child: const PreferencesFieldWithDescription(
          label: 'Prevent screen sleep:',
          description: 'Your display will not turn off while using the app.',
          child: ScreenSleepCheckbox(),
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
