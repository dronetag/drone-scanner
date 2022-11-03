import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
part 'help_state.dart';

class HelpCubit extends Cubit<HelpState> {
  static const String _host = 'cms.dronetag.cz';
  static const String _path = 'items/drone_scanner_help_section';
  static const String _query =
      'fields=*,displayed_questions.question.translations.*';

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
      final response = await http.get(url);
      final loadedQuestions = <String>[];
      final loadedAnswers = <String>[];
      // map with string keys, value is another map
      final extractedData = (json.decode(response.body))['data'] as Map;
      final helpText = extractedData['excerpt'] as String;
      final helpSubtext = extractedData['text'] as String;

      final questionList = extractedData['displayed_questions'] as List;
      for (var i = 0; i < 1; ++i) {
        loadedQuestions.add(questionList[i]['question']['translations'][1]
            ['question'] as String);
        loadedAnswers.add(
            questionList[i]['question']['translations'][1]['answer'] as String);
      }
      emit(
        HelpStateLoaded(
          helpText: helpText,
          helpSubtext: helpSubtext,
          questions: loadedQuestions,
          answers: loadedAnswers,
        ),
      );
    } catch (err) {
      emit(HelpStateFailed(err.toString()));
    }
  }
}
