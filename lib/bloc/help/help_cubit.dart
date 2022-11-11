import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'help_question.dart';
part 'help_state.dart';

class HelpCubit extends Cubit<HelpState> {
  static const String _host = 'cms.dronetag.cz';
  static const String _path = 'items/drone_scanner_help_section';
  static const String _query =
      'fields=*,displayed_questions.question.translations.*,displayed_questions.question.id';
  static const iphoneWifiQuestionIndex = 9;

  HelpCubit()
      : super(
          HelpStateLoading(),
        );

  void fetchHelp() async {
    final url = Uri(
      scheme: 'https',
      host: _host,
      path: _path,
      query: _query,
    );
    try {
      emit(HelpStateLoading());
      final response = await http.get(url);
      final loadedQuestions = <HelpQuestion>[];
      // map with string keys, value is another map
      final extractedData = (json.decode(response.body))['data'] as Map;
      final helpText = extractedData['excerpt'] as String;
      final helpSubtext = extractedData['text'] as String;

      final questionList = extractedData['displayed_questions'] as List;
      for (var i = 0; i < questionList.length; ++i) {
        // find english translation
        final questionTranslations =
            questionList[i]['question']['translations'] as List;
        var translationIndex = 0;
        var found = false;
        for (;
            translationIndex < questionTranslations.length;
            ++translationIndex) {
          if (questionTranslations[translationIndex]['languages_id'] == 'en') {
            found = true;
            break;
          }
        }
        if (!found) {
          continue;
        }
        final questionId = questionTranslations[translationIndex]
            ['frequently_asked_questions_id'] as int;
        final question =
            (questionTranslations[translationIndex]['question'] as String)
                .replaceAll('\n', '');
        final answer =
            (questionTranslations[translationIndex]['answer'] as String);
        loadedQuestions.add(HelpQuestion(questionId, question, answer));
      }
      emit(
        HelpStateLoaded(
          helpText: helpText,
          helpSubtext: helpSubtext,
          questions: loadedQuestions,
        ),
      );
    } catch (err) {
      emit(HelpStateFailed(err.toString()));
    }
  }
}
