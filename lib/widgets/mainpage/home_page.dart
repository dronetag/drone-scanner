import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../bloc/showcase_cubit.dart';
import '../../bloc/sliders_cubit.dart';
import '../app/app_scaffold.dart';
import 'home_body.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({
    super.key,
  });

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
                child: const AppScaffold(
                  child: HomeBody(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
