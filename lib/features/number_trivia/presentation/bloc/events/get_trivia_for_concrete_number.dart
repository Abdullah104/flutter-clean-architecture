import '../number_trivia_bloc.dart';

class GetTriviaForConcreteNumber extends NumberTriviaEvent {
  final String _numberString;

  const GetTriviaForConcreteNumber(this._numberString);

  @override
  List<Object> get props => [_numberString];

  String get numberString => _numberString;
}
