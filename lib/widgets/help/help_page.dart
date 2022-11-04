import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/help/help_cubit.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../../utils/drone_scanner_icon_icons.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: ColoredBox(
        color: Theme.of(context).backgroundColor,
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).viewPadding.top,
            left: Sizes.preferencesMargin,
            right: Sizes.preferencesMargin,
          ),
          child: buildContent(context),
        ),
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
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) => itemList[index],
      itemCount: itemList.length,
      physics: BouncingScrollPhysics(),
    );
  }

  List<Widget> buildItems(
    BuildContext context,
    HelpStateLoaded state,
  ) {
    return [
      Text(state.helpText),
      Text(state.helpSubtext),
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
      Column(
        children: [
          Icon(
            Icons.error,
            color: AppColors.redIcon,
          ),
          Text('Failed to load help section.'),
          ElevatedButton.icon(
            icon: Icon(Icons.refresh),
            label: Text('Retry'),
            onPressed: context.read<HelpCubit>().fetchHelp,
          )
        ],
      )
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
    return state.questions
        .map(
          (e) => QuestionWidget(
            question: e,
          ),
        )
        .toList();
  }
}

class QuestionWidget extends StatefulWidget {
  final HelpQuestion question;

  const QuestionWidget({Key? key, required this.question}) : super(key: key);
  @override
  _QuestionWidgetState createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  bool showAnswer = false;
  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
              onPressed: () {
                setState(() {
                  showAnswer = !showAnswer;
                });
              },
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: Sizes.iconSize,
              ),
            ),
            Text(widget.question.question),
          ],
        ),
        Visibility(
          visible: showAnswer,
          child: Text(widget.question.answer),
        ),
      ],
    );
  }
}
