import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

import '../bloc/showcase_cubit.dart';
import '../bloc/sliders_cubit.dart';
import '../models/home_screen_page.dart';
import 'app/app_scaffold.dart';
import 'app/home_screen_navigation_bar.dart';
import 'app/more_page.dart';
import 'map/map_page.dart';
import 'preferences/preferences_page.dart';
import 'preferences/proximity_alerts_page.dart';
import 'receiver/receiver_page.dart';
import 'receiver/receiver_page_list_content.dart';

/// HomeScreen is the main screen of the app.
///
/// It contains a page view
/// with 5 pages - map, radar, rider, settings and more. User can switch btw
/// these pages using navigation bar
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomeScreen> {
  late final PageController _pageController =
      PageController(initialPage: _currentPage.index);

  HomeScreenPage _currentPage = HomeScreenPage.map;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // hide keyboard
      child: ShowCaseWidget(
        onStart: (index, key) {
          context.read<ShowcaseCubit>().onKeyStart(context, index, key);
        },
        onComplete: (index, key) {
          context.read<ShowcaseCubit>().onKeyComplete(context, index, key);
        },
        onFinish: () {
          context.read<ShowcaseCubit>().onShowcaseFinish(context);
        },
        builder: Builder(
          builder: (context) {
            final showDroneDetail = context.select<SlidersCubit, bool>(
                (cubit) => cubit.state.showDroneDetail);
            final isPanelOpened = context
                .select<SlidersCubit, bool>((cubit) => cubit.isPanelOpened);

            return AnnotatedRegion(
              value: SystemUiOverlayStyle.dark,
              child: PopScope(
                canPop: !showDroneDetail && !isPanelOpened,
                onPopInvoked: (_) async {
                  if (showDroneDetail) {
                    await context
                        .read<SlidersCubit>()
                        .setShowDroneDetail(show: false);
                    return;
                  }

                  if (isPanelOpened) {
                    await context
                        .read<SlidersCubit>()
                        .animatePanelToSnapPoint();
                    return;
                  }
                },
                child: AppScaffold(
                  bottomNavigationBar: HomeScreenNavigationBar(
                    currentPage: _currentPage,
                    onPageSelected: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                      _pageController.jumpToPage(page.index);
                    },
                  ),
                  child: _buildContent(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() => PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          MapPage(),
          ProximityAlertsPage(),
          ReceiverPage(),
          PreferencesPage(),
          MorePage(),
        ],
      );
}
