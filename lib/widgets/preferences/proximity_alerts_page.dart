import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../bloc/help/help_cubit.dart';
import '../../bloc/proximity_alerts_cubit.dart';
import '../../bloc/showcase_cubit.dart';
import '../../bloc/sliders_cubit.dart';
import '../../bloc/standards_cubit.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../../utils/drone_scanner_icon_icons.dart';
import '../app/app_scaffold.dart';
import '../app/dialogs.dart';
import '../help/help_page.dart';
import '../showcase/showcase_item.dart';
import '../sliders/common/headline.dart';
import 'components/custom_dropdown_button.dart';
import 'components/preferences_field_with_description.dart';
import 'components/preferences_slider.dart';
import 'components/proximity_alert_distance_field.dart';
import 'components/rotating_icon.dart';
import 'components/users_device_uas_id_text_field.dart';

class ProximityAlertsPage extends StatelessWidget {
  static const routeName = 'ProximityAlertsPage';
  const ProximityAlertsPage({Key? key}) : super(key: key);

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
                    'This page let you set proximity alerts for your device',
                title: 'Proximity Alerts',
                child: ColoredBox(
                  color: Theme.of(context).backgroundColor,
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
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final itemPadding = EdgeInsets.symmetric(vertical: Sizes.standard);
    final alertsState = context.watch<ProximityAlertsCubit>().state;
    final radarIconSize = 50.0;
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
            'Drone Radar',
            textScaleFactor: 2,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.borderGray,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        padding: EdgeInsets.all(Sizes.standard * 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: Sizes.standard * 2),
                  child: PreferencesSlider(
                    getValue: () => context
                        .read<ProximityAlertsCubit>()
                        .state
                        .proximityAlertActive,
                    setValue: (c) {
                      final cubit = context.read<ProximityAlertsCubit>();
                      if (cubit.state.usersAircraftUASID != null) {
                        cubit.setProximityAlertsActive(active: c);
                      }
                    },
                    enabled: context
                            .watch<ProximityAlertsCubit>()
                            .state
                            .usersAircraftUASID !=
                        null,
                  ),
                ),
                if (alertsState.usersAircraftUASID == null)
                  Padding(
                    padding: EdgeInsets.only(bottom: Sizes.standard / 2),
                    child: Text(
                      '\"My Drone\" is not selected',
                      style: TextStyle(
                        color: AppColors.red,
                        fontSize: 10,
                      ),
                    ),
                  ),
                RichText(
                  text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.toolbarColor,
                      ),
                      children: [
                        if (alertsState.usersAircraftUASID == null) ...[
                          TextSpan(
                            text: 'Radar cannot be enabled',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.toolbarColor.withOpacity(0.5),
                            ),
                          )
                        ] else ...[
                          if (alertsState.proximityAlertActive) ...[
                            TextSpan(text: 'Radar is '),
                            TextSpan(
                              text: 'enabled',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.toolbarColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ] else
                            TextSpan(text: 'Radar is disabled')
                        ]
                      ]),
                ),
              ],
            ),
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                RotatingIcon(
                  icon: Image.asset(
                    'assets/images/radar.png',
                    width: radarIconSize,
                    height: radarIconSize,
                    color: alertsState.proximityAlertActive
                        ? Colors.black
                        : AppColors.lightGray,
                  ),
                  rotating: alertsState.proximityAlertActive,
                ),
                if (!alertsState.proximityAlertActive)
                  Transform.rotate(
                    angle: math.pi / 4,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      width: Sizes.iconSize / 3,
                      height: radarIconSize * 1.3,
                      color: Colors.white,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Sizes.panelBorderRadius),
                          color: AppColors.preferencesButtonColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      Padding(
        padding: itemPadding * 4,
        child: GestureDetector(
          onTap: (() {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HelpPage(
                  // TODO: connect to actual question
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
                'How does the Drone Radar work?',
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
        text: 'My Drone',
        color: AppColors.green,
        fontSize: 12,
        leading: const Icon(
          Icons.person,
          color: AppColors.green,
          size: 16,
        ),
      ),
      UsersDeviceUASIDTextField(),
      Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(
          top: Sizes.standard * 2,
          bottom: Sizes.standard * 4,
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.read<SlidersCubit>().setShowDroneDetail(show: false);
            context.read<SlidersCubit>().openSlider();
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              AppColors.preferencesButtonColor,
            ),
            padding: MaterialStateProperty.all(
              EdgeInsets.symmetric(
                horizontal: Sizes.standard * 4,
                vertical: Sizes.standard * 1.5,
              ),
            ),
          ),
          child: const Text(
            'Select from the visible drones',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      Headline(
        text: 'Options',
        fontSize: 12,
      ),
      Padding(
        padding: itemPadding,
        child: PreferencesFieldWithDescription(
          label: 'Send proximity push notifications',
          description:
              'Notification will be sent when there is another drone close to yours',
          child: PreferencesSlider(
              getValue: () =>
                  context.read<StandardsCubit>().state.notificationsEnabled &&
                  context.read<ProximityAlertsCubit>().state.sendNotifications,
              setValue: (c) {
                if (!context
                    .read<StandardsCubit>()
                    .state
                    .notificationsEnabled) {
                  showSnackBar(context,
                      'Unable to send notifications due to missing permission');
                  return;
                }
                context
                    .read<ProximityAlertsCubit>()
                    .setSendNotifications(send: c);
              }),
        ),
      ),
      Padding(
        padding:
            EdgeInsets.only(top: Sizes.standard, bottom: Sizes.standard * 4),
        child: ProximityAlertDistanceField(),
      ),
      Padding(
        padding: EdgeInsets.only(bottom: Sizes.standard),
        child: _buildExpirationTimeField(context),
      ),
      // TODO: put back when there are more data sources available
      /*Padding(
        padding: EdgeInsets.only(bottom: Sizes.standard * 4),
        child: PreferencesFieldWithDescription(
          label: 'Data Source',
          description: 'Select the data source to be used '
              'for the radar functionality',
          child: CustomDropdownButton(
            value: 'This phone',
            valueChangedCallback: (newValue) {
              
            },
            items: const ['This phone'],
          ),
        ),
      ),*/
    ];
  }

  Widget _buildExpirationTimeField(BuildContext context) {
    final items = const [
      '5 seconds',
      '10 seconds',
      '30 seconds',
      '1 min',
    ];
    String getValue(BuildContext context) {
      final sec = context.watch<ProximityAlertsCubit>().state.expirationTimeSec;
      if (sec == 5) {
        return items[0];
      } else if (sec == 10) {
        return items[1];
      } else if (sec == 30) {
        return items[2];
      } else if (sec == 60) {
        return items[3];
      } else {
        return items[2];
      }
    }

    return PreferencesFieldWithDescription(
      label: 'Notification display duration',
      description:
          'The duration until the radar notifications are automatically closed',
      child: CustomDropdownButton(
        value: getValue(context),
        valueChangedCallback: (newValue) {
          var sec = 0;
          if (newValue == items[0]) {
            sec = 5;
          } else if (newValue == items[1]) {
            sec = 10;
          } else if (newValue == items[2]) {
            sec = 30;
          } else if (newValue == items[3]) {
            sec = 60;
          } else {
            sec = 10;
          }
          context
              .read<ProximityAlertsCubit>()
              .setNotificationExpirationTime(sec);
        },
        items: items,
      ),
    );
  }
}
