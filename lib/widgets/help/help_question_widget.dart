import 'package:flutter/material.dart';

import '../../bloc/help/help_cubit.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';

class HelpQuestionWidget extends StatefulWidget {
  final HelpQuestion question;
  final bool showAnswer;

  const HelpQuestionWidget(
      {Key? key, required this.question, this.showAnswer = false})
      : super(key: key);
  @override
  _QuestionWidgetState createState() =>
      _QuestionWidgetState(showAnswer: showAnswer);
}

class _QuestionWidgetState extends State<HelpQuestionWidget> {
  bool showAnswer;
  _QuestionWidgetState({this.showAnswer = false});
  @override
  Widget build(BuildContext context) {
    final questionStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.highlightBlue,
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          showAnswer = !showAnswer;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            Row(
              children: [
                Align(
                  child: RotatedBox(
                    quarterTurns: showAnswer ? 3 : 2,
                    child: Icon(
                      Icons.chevron_left,
                      size: Sizes.iconSize,
                      color: AppColors.highlightBlue,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    widget.question.question,
                    style: questionStyle,
                  ),
                ),
              ],
            ),
            Visibility(
              visible: showAnswer,
              child: Text(widget.question.answer),
            ),
          ],
        ),
      ),
    );
  }
}
