import 'package:dartz/dartz.dart';

import '../../../../core/error/failures/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../entities/number_trivia.dart';
import '../repositories/number_trivia_repository.dart';

class GetRandomNumberTrivia implements UseCase<NumberTrivia, NoParams> {
  final NumberTriviaRepository _numberTriviaRepository;

  GetRandomNumberTrivia(NumberTriviaRepository numberTriviaRepository)
      : _numberTriviaRepository = numberTriviaRepository;

  @override
  Future<Either<Failure, NumberTrivia>> call(NoParams noParams) async {
    final trivia = await _numberTriviaRepository.getRandomNumberTrivia();

    return trivia;
  }
}
