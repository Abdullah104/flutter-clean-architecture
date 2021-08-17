import '../number_trivia_bloc.dart';

class NumberTriviaRetrievalErrorState extends NumberTriviaState {
  final String _message;

  NumberTriviaRetrievalErrorState({
    required String message,
  }) : this._message = message;

  String get message => this._message;

  @override
  List<Object> get props => [this._message];
}
