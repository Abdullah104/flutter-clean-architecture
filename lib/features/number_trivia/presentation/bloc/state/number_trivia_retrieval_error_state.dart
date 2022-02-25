import '../number_trivia_bloc.dart';

class NumberTriviaRetrievalErrorState extends NumberTriviaState {
  final String _message;

  const NumberTriviaRetrievalErrorState({
    required String message,
  }) : _message = message;

  String get message => _message;

  @override
  List<Object> get props => [_message];
}
