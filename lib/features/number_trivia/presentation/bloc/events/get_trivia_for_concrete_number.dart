import '../number_trivia_bloc.dart';

class GetTriviaForConcreteNumber extends NumberTriviaEvent {
  final String _numberString;

  GetTriviaForConcreteNumber(this._numberString);

  @override
  List<Object> get props => [this._numberString];

  String get numberString => this._numberString;
}
