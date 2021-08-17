import 'package:equatable/equatable.dart';

class NumberTrivia extends Equatable {
  final String _text;
  final int _number;

  NumberTrivia({
    required int number,
    required String text,
  })  : this._number = number,
        this._text = text;

  String get text => this._text;

  int get number => this._number;

  @override
  List<Object?> get props => [this._text, this._number];
}
