part of 'help_cubit.dart';

class HelpState {}

class HelpStateLoading extends HelpState {}

class HelpStateLoaded extends HelpState {
  final String helpText;
  final String helpSubtext;
  final List<String> questions;
  final List<String> answers;

  HelpStateLoaded({
    required this.helpText,
    required this.helpSubtext,
    required this.questions,
    required this.answers,
  });

  HelpStateLoaded copyWith({
    String? helpText,
    String? helpSubtext,
    List<String>? questions,
    List<String>? answers,
  }) =>
      HelpStateLoaded(
        helpText: helpText ?? this.helpText,
        helpSubtext: helpSubtext ?? this.helpSubtext,
        questions: questions ?? this.questions,
        answers: answers ?? this.answers,
      );
}

class HelpStateFailed extends HelpState {
  final String error;

  HelpStateFailed(this.error);
}
