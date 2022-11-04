part of 'help_cubit.dart';

class HelpQuestion {
  final String question;
  final String answer;

  HelpQuestion(this.question, this.answer);
}

class HelpState {}

class HelpStateLoading extends HelpState {}

class HelpStateLoaded extends HelpState {
  final String helpText;
  final String helpSubtext;
  final List<HelpQuestion> questions;

  HelpStateLoaded({
    required this.helpText,
    required this.helpSubtext,
    required this.questions,
  });

  HelpStateLoaded copyWith({
    String? helpText,
    String? helpSubtext,
    List<HelpQuestion>? questions,
  }) =>
      HelpStateLoaded(
        helpText: helpText ?? this.helpText,
        helpSubtext: helpSubtext ?? this.helpSubtext,
        questions: questions ?? this.questions,
        //answers: answers ?? this.answers,
      );
}

class HelpStateFailed extends HelpState {
  final String error;

  HelpStateFailed(this.error);
}
