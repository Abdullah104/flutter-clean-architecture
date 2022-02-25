import 'package:equatable/equatable.dart';

class NumberTrivia extends Equatable {
  final String _text;
  final int _number;

  const NumberTrivia({
    required int number,
    required String text,
  })  : _number = number,
        _text = text;

  String get text => _text;

  int get number => _number;

  @override
  List<Object?> get props => [_text, _number];
}
