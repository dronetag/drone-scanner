import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:navigation_history_observer/navigation_history_observer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bloc/help/help_question.dart';
import '../../constants/colors.dart';
import '../preferences/preferences_page.dart';

class HelpQuestionWidget extends StatefulWidget {
  final HelpQuestion question;
  final bool showAnswer;

  const HelpQuestionWidget(
      {super.key, required this.question, this.showAnswer = false});
  @override
  State<HelpQuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<HelpQuestionWidget> {
  bool showAnswer = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      showAnswer = widget.showAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    const questionStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.highlightBlue,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                showAnswer = !showAnswer;
              });
            },
            child: Row(
              children: [
                RotatedBox(
                  quarterTurns: showAnswer ? 1 : 0,
                  child: Image.asset(
                    'assets/images/chevron_right.png',
                    width: 15,
                    height: 15,
                    color: AppColors.highlightBlue,
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      widget.question.question,
                      style: questionStyle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Visibility(
              visible: showAnswer,
              child: MarkdownBody(
                data: widget.question.answer,
                onTapLink: (text, href, title) {
                  if (href == null) return;
                  if (href == 'dronescanner://preferences') {
                    final historyObserver = NavigationHistoryObserver();
                    // if page before current is preferences, just pop
                    if (historyObserver
                            .history[historyObserver.history.length - 2]
                            .settings
                            .name ==
                        PreferencesPage.routeName) {
                      Navigator.pop(context);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PreferencesPage(),
                          settings: const RouteSettings(
                            name: PreferencesPage.routeName,
                          ),
                        ),
                      );
                    }
                    return;
                  }
                  final url = Uri.parse(href);
                  canLaunchUrl(url).then(
                    (value) {
                      if (value) launchUrl(url);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
