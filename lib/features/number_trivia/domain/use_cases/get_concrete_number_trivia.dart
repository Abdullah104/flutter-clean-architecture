import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../entities/number_trivia.dart';
import '../repositories/number_trivia_repository.dart';

class GetConcreteNumberTrivia implements UseCase<NumberTrivia, Params> {
  late final NumberTriviaRepository _numberTriviaRepository;

  GetConcreteNumberTrivia(NumberTriviaRepository numberTriviaRepository)
      : _numberTriviaRepository = numberTriviaRepository;

  @override
  Future<Either<Failure, NumberTrivia>> call(Params params) async {
    final numberTrivia =
        await _numberTriviaRepository.getConcreteNumberTrivia(params.number);

    return numberTrivia;
  }
}

class Params extends Equatable {
  final int _number;

  const Params({required int number}) : _number = number;

  int get number => _number;

  @override
  List<Object?> get props => [_number];
}
