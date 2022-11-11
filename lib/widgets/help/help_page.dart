import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../bloc/help/help_cubit.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../../utils/drone_scanner_icon_icons.dart';
import '../app/app_scaffold.dart';
import 'help_question_widget.dart';

class HelpPage extends StatelessWidget {
  static const routeName = 'HelpPage';

  final int? highlightedQuestionIndex;
  const HelpPage({Key? key, this.highlightedQuestionIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<HelpCubit>().fetchHelp();
    return AppScaffold(
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).viewPadding.top,
          left: Sizes.preferencesMargin,
          right: Sizes.preferencesMargin,
        ),
        child: buildContent(context),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return BlocBuilder<HelpCubit, HelpState>(
      builder: (context, state) {
        if (state is HelpStateLoaded) {
          return buildLoaded(context, state);
        } else if (state is HelpStateLoading) {
          return buildLoading(context);
        } else {
          return buildFailed(context);
        }
      },
    );
  }

  Widget buildLoaded(BuildContext context, HelpStateLoaded state) {
    final itemList = [
      ...buildHeader(context),
      ...buildItems(
        context,
        state,
      ),
    ];
    return ScrollablePositionedList.builder(
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) => itemList[index],
      itemCount: itemList.length,
      physics: BouncingScrollPhysics(),
      initialScrollIndex: highlightedQuestionIndex ?? 0,
    );
  }

  List<Widget> buildItems(
    BuildContext context,
    HelpStateLoaded state,
  ) {
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: Sizes.preferencesMargin),
        child: Text(
          state.helpText,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: Sizes.preferencesMargin),
        child: Text(
          state.helpSubtext,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      ...buildQuestions(context, state),
    ];
  }

  Widget buildLoading(BuildContext context) {
    final itemList = [
      ...buildHeader(context),
      Center(child: CircularProgressIndicator()),
    ];
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) => itemList[index],
      itemCount: itemList.length,
      physics: BouncingScrollPhysics(),
    );
  }

  Widget buildFailed(BuildContext context) {
    final itemList = [
      ...buildHeader(context),
      Container(
        height: MediaQuery.of(context).size.height / 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              Icons.error,
              color: AppColors.redIcon,
              size: 36,
            ),
            Text(
              'Failed to load help section.',
              style: TextStyle(fontSize: 18),
            ),
            ElevatedButton.icon(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  AppColors.preferencesButtonColor,
                ),
              ),
              icon: Icon(
                Icons.refresh,
              ),
              label: Text('Retry'),
              onPressed: context.read<HelpCubit>().fetchHelp,
            )
          ],
        ),
      ),
    ];
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) => itemList[index],
      itemCount: itemList.length,
      physics: BouncingScrollPhysics(),
    );
  }

  List<Widget> buildHeader(BuildContext context) {
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
            'Help',
            textScaleFactor: 2,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ];
  }

  List<Widget> buildQuestions(
    BuildContext context,
    HelpStateLoaded state,
  ) {
    final res = <Widget>[];
    for (var i = 0; i < state.questions.length; ++i) {
      res.add(
        HelpQuestionWidget(
          question: state.questions[i],
          showAnswer: state.questions[i].questionId == highlightedQuestionIndex,
        ),
      );
    }
    return res;
  }
}
